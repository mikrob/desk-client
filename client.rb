
require 'rest-client'
require 'pp'
require 'json'
require "addressable/uri"
require 'csv'

def date_to_timestamp date
  date.to_time.to_i
end

date = Date.new(2017,01,01)
csv_headers = %w(id created_at subject blurb)

url = "https://clicrdv.desk.com/api/v2/cases/search?labels=bug&subject=sms&since_created_at=#{date_to_timestamp(date)}&fields=id,created_at,subject,blurb&per_page=100"
url_all_bugs = "https://clicrdv.desk.com/api/v2/cases/search?labels=bug&since_created_at=#{date_to_timestamp(date)}&fields=id,created_at,subject,blurb&per_page=100"
# search_url = "https://clicrdv.desk.com/api/v2/cases/search?labels=bug&subject=sms&since_created_at=#{date_to_timestamp(date)}&fields=id,created_at,subject,blurb"

parsed_url = Addressable::URI.parse(url).normalize.to_str
parsed_url_all_bugs = Addressable::URI.parse(url_all_bugs).normalize.to_str

username = ENV["DESK_USERNAME"]
password = ENV["DESK_PASSWORD"]

@response = RestClient::Request.execute method: :get, url: parsed_url, user: username, password: password
@response_all_bugs = RestClient::Request.execute method: :get, url: parsed_url_all_bugs, user: username, password: password

tickets =  JSON.parse(@response.body)
tickets_all_bugs = JSON.parse(@response_all_bugs.body)

tickets_array = tickets["_embedded"]["entries"]
number = tickets["total_entries"].to_i
number_all_bugs = tickets_all_bugs["total_entries"].to_i
pp "We have #{number} tickets matching and we had #{number_all_bugs} tickets total it is : #{((number.to_f/number_all_bugs.to_f)*100).round(2)}%"

page_index = 1
max_pages = number / 100

CSV.open("./desk_ticket_extract.csv", "wb", {col_sep: ';'}) do |csv|
  csv << csv_headers # write header
  tickets_array.each do |row|
    row_sliced = row.delete_if {|k,v| !csv_headers.include?(k) }
    row_sliced["blurb"] = row_sliced["blurb"].tr("\n", '  ')
    csv << row_sliced.values
  end

  while page_index <= max_pages
    next_page_url = parsed_url + "page=#{page_index}"

    @response = RestClient::Request.execute method: :get, url: next_page_url, user: username, password: password

    tickets =  JSON.parse(@response.body)

    puts "tickets fetched for page (#{page_index}): #{tickets.size}"

    page_index += 1
    row = tickets["_embedded"]["entries"]
    row_sliced = row.delete_if {|k,v| !csv_headers.include?(k) }
    row_sliced["blurb"] = row_sliced["blurb"].tr("\n", '  ')
    csv << row_sliced.values
  end
end
