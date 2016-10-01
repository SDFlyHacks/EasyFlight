require 'httparty'
require 'nokogiri'
require 'open-uri'

def url_generator(origin, destination)
  return "https://www.google.com/maps/dir/" + origin + "/" + destination
end

# API required to get travel time
def travel_time(origin, destination)
  url = "https://maps.googleapis.com/maps/api/distancematrix/xml?units=imperial&origins=" + origin + "&destinations=" + destination + "&key=" + ENV["GOOGLE_MAPS_API"]
  parse_page = Nokogiri::XML(open(url))

  return parse_page.css('duration').css('value').text.to_i
end
