require 'nokogiri'
require 'faraday'

# Documentation on the Google Spreadsheet API:
# https://developers.google.com/google-apps/spreadsheets/

class ContactSpreadsheet
  def initialize(access_token)
    @access_token = access_token
  end

  def get_doc(url)
    # Create the connection
    conn = Faraday.new(url: 'https://spreadsheets.google.com')

    # Make the request
    response = conn.get(url + "?access_token=#{@access_token}", { 'GData-Version' => '3.0' })

    # Parse it
    doc = Nokogiri::XML.parse(response.body)
  end

  def list_title_and_url(url)
    doc = get_doc url

    doc.xpath('//xmlns:entry').map do |entry|
      {
        title: entry.xpath('.//xmlns:title').first.content,
        url: entry.xpath('.//xmlns:content').first['src'],
      }
    end
  end

  def list_data(url)
    doc = get_doc url

    doc.xpath('//xmlns:entry').map do |entry|
      data = {}

      # Look for all the nodes in the gsx namespace (http://schemas.google.com/spreadsheets/2006/extended)
      entry.xpath(".//*[namespace-uri()='http://schemas.google.com/spreadsheets/2006/extended']").each do |col|
        data[col.name] = col.content
      end

      data
    end
  end

  def list_contacts
    # Find the spreadsheet
    spreadsheet_url = nil
    list_title_and_url('/feeds/spreadsheets/private/full').each do |sheet|
      if sheet[:title] == "Jessie's Brook EQ Contacts"
        spreadsheet_url = sheet[:url]
        break
      end
    end

    # Find the worksheet
    worksheet_url = nil
    list_title_and_url(spreadsheet_url).each do |sheet|
      if worksheet_url.nil? || sheet[:title] == "ELDERSQUORUM"
        worksheet_url = sheet[:url]
        break
      end
    end

    # Get the data out of the worksheet
    list_data(worksheet_url)
  end
end

