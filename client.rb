
require 'rest-client'
require 'pp'
require 'json'
require "addressable/uri"

module Category
  BAD_PHONE_NUMBER = 0
end

class Ticket
  attr_accessor :id, :received_date, :description, :subject
end


def date_to_timestamp date
  date.to_time.to_i
end


date = Date.new(2017,01,01)


search_url = "https://clicrdv.desk.com/api/v2/cases/search?subject=SMS&since_created_date=#{date_to_timestamp(date)}&fields=id,created_at,subject,blurb"

# search_url = "https://clicrdv.desk.com/api/v2/cases/search?labels=bug&subject=sms&since_created_at=#{date_to_timestamp(date)}&fields=id,created_at,subject,blurb"
parsed_url = Addressable::URI.parse(search_url).normalize.to_str

username = ENV["DESK_USERNAME"]
password = ENV["DESK_PASSWORD"]

response = RestClient::Request.execute method: :get, url: parsed_url, user: username, password: password

tickets =  JSON.parse(response.body)


tickets_array = tickets["_embedded"]["entries"]
number = tickets["total_entries"]

pp "We have #{number} tickets matching"

#  tickets_per_month = tickets["cases"].group_by { |record| record["created_at"].to_date.strftime("%m-%y") }
#  tickets_per_month.each do |month_year, tickets|
#    puts "#{month_year} : #{tickets.count}"
#  end
