require 'nokogiri'
require 'faraday'

class ContactSpreadsheet
  def initialize(access_token)
    @access_token = access_token
  end

  def do_request(url)
    conn = Faraday.new(url: 'https://spreadsheets.google.com')
    conn.get(url + "?access_token=#{@access_token}", { 'GData-Version' => '3.0' })
  end

  def list_spreadsheets
    # Make the request
    response = do_request('/feeds/spreadsheets/private/full')

    # Parse it
    doc = Nokogiri::XML.parse(response.body)

    doc.xpath('//xmlns:entry').map do |entry|
      {title: entry.xpath('.//xmlns:title').first.content, url: entry.xpath('.//xmlns:id').first.content}
    end
  end

  def list_contacts
    list_spreadsheets.each do
      break
    end
  end
end

