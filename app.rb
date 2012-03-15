require 'sinatra'
require 'sinatra/config_file'
require 'sinatra/content_for'
require 'mongoid'
require 'sinatra/reloader' if development?
require 'google/api_client'
require 'haml'
require './lib/contact_spreadsheet'

use Rack::Session::Pool, :expire_after => 86400 # 1 day

config_file settings.root + '/config/config.yml'

Mongoid.load!(settings.root + '/config/mongoid.yml')

# Set up our token store
class TokenPair
  include Mongoid::Document

  field :refresh_token, type: String
  field :access_token, type: String
  field :expires_in, type: Integer
  field :issued_at, type: Integer

  def update_token!(object)
    self.refresh_token = object.refresh_token
    self.access_token = object.access_token
    self.expires_in = object.expires_in
    self.issued_at = object.issued_at
  end

  def to_hash
    return {
      refresh_token: refresh_token,
      access_token: access_token,
      expires_in: expires_in,
      issued_at: Time.at(issued_at)
    }
  end
end

module Faraday
  class Connection
    alias :ssl_aliased :ssl
    def ssl
      @ssl[:ca_file] = settings.root + '/cacert.pem' unless @ssl[:ca_file]
      @ssl
    end
  end
end

helpers do
  def access_spreadsheet
    @google_client = Google::APIClient.new
    @google_client.authorization.client_id = settings.google_api_client_id
    @google_client.authorization.client_secret = settings.google_api_client_secret
    @google_client.authorization.scope = 'https://spreadsheets.google.com/feeds'
    @google_client.authorization.redirect_uri = to('/oauth2callback')
    @google_client.authorization.code = params[:code] if params[:code]
    if session[:token_id]
      # Load the access token here if it's available
      token_pair = TokenPair.find(session[:token_id])
      @google_client.authorization.update_token!(token_pair.to_hash)
    end
    if @google_client.authorization.refresh_token && @google_client.authorization.expired?
      @google_client.authorization.fetch_access_token!
    end
    unless @google_client.authorization.access_token || request.path_info =~ /^\/oauth2/
      redirect to('/oauth2authorize')
    end
  end
end

get '/oauth2authorize' do
  access_spreadsheet
  redirect @google_client.authorization.authorization_uri.to_s, 303
end

get '/oauth2callback' do
  access_spreadsheet
  # Request the access token
  @google_client.authorization.fetch_access_token!
  # Persist the token here
  token_pair = session[:token_id] ? TokenPair.find(session[:token_id]) : TokenPair.new
  token_pair.update_token!(@google_client.authorization)
  token_pair.save
  session[:token_id] = token_pair.id
  redirect to('/contact_quorum')
end

get '/' do
  # Load a random quote
  quotes_filename = settings.root + '/quotes.yml'
  quotes = YAML.load_file quotes_filename
  @quote = quotes[rand(quotes.size)]

  haml :index
end

get '/contact_quorum' do
  access_spreadsheet

  sheet = ContactSpreadsheet.new @google_client.authorization.access_token

  @contacts = sheet.list_contacts.sort { |x, y| x['lastname'] <=> y['lastname'] }

  @contact_groups = @contacts.map do |contact|
    supervisor = contact["htdistrictsupervisor"]
    supervisor.empty? ? nil : supervisor
  end.uniq.compact.sort

  haml :contact_quorum
end

