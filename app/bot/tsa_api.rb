require 'httparty'
require 'nokogiri'
require 'open-uri'

def tsa_url_generator(airport)
  return "http://apps.tsa.dhs.gov/MyTSAWebService/GetWaitTimes.ashx?ap=" + airport
end

def max_wait_time(url)
  # Takes the max of all the wait times.
  parse_page = Nokogiri::XML(open(url))

  wait_times = []
  parse_page.css('WaitTimeIndex').map do |a|
    wait_times.push(a.text.to_i())
  end
  return wait_times.max
end

def get_tsa_data_from_airport(airport)
  url = tsa_url_generator(airport)
  return max_wait_time(url)
end