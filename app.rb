require 'sinatra'
require 'sinatra/content_for'
require 'sinatra/reloader' if development?

require 'haml'

get '/' do
  # Load a random quote
  quotes_filename = File.expand_path(File.dirname(__FILE__)) + '/quotes.yml'
  quotes = YAML.load_file quotes_filename
  @quote = quotes[rand(quotes.size)]

  haml :index
end

