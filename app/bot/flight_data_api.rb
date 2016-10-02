require 'httparty'
require 'nokogiri'


def flight_data_url_generator(flight_no)
  return "http://flightaware.com/live/flight/" + flight_no
end


def extractor(url)
  # Scrapes data from the specified site and generates a JSON with:
  # - Departing airport name
  # - Departure terminal
  # - Depature time
  # - Airline link
  page = HTTParty.get(url)
  parse_page = Nokogiri::HTML(page)
  # Airline link
  airline_link = parse_page.css('#slideOutPanel').css('.pageContainer').css('.layout-table').css('.track-details').css('.track-panel-header-content').css('.track-panel-header-subhead')[0].text.split()[-1]

  # Departure airport
  airport_info = parse_page.css('#slideOutPanel').css('.pageContainer').css('.layout-table').css('tbody').css('.track-panel-airport-subhead').text

  # Departing terminal
  terminal_info = parse_page.css('#slideOutPanel').css('.pageContainer').css('.layout-table').css('tbody').css('tr').css('.track-panel-departure').css('.track-panel-terminal').children().text

  # Takeoff time
  time_info = parse_page.css('#slideOutPanel').css('.pageContainer').css('.layout-table').css('tbody').css('tr').css('.track-panel-scheduledtime').css('td')[0].text.strip()
  return {:airline_link => airline_link, :airport_info => airport_info, :terminal_info => terminal_info, :time_info => time_info}
end

def get_flight_data_from_number(flight_no)
  url = flight_data_url_generator(flight_no)
  return extractor(url)
end