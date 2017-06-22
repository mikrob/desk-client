
require 'rest-client'

url = "https://clicrdv.desk.com/api/v2/cases"
username = ENV["DESK_USERNAME"]
password = ENV["DESK_PASSWORD"]

RestClient::Request.execute method: :get, url: url, user: username, password: password

