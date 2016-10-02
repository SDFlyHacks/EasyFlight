require 'httparty'
require 'nokogiri'
require 'time'
require 'pry'

def flight_data_url_generator(flight_no)
  # Return the url of the flight data source.
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
  depart_city, _ , depart_iata = /\(((\w|\s)+),\s\w{2}\)\s-\sK(\w{3})/.match(parse_page.css('span')[8].values[1]).captures

  # Arrival airport
  arrival_city, _ , arrival_iata = /\(((\w|\s)+),\s\w{2}\)\s-\sK(\w{3})/.match(parse_page.css('span')[9].values[1]).captures

  # Departing terminal
  departing_terminal = parse_page.css('#slideOutPanel').css('.pageContainer').css('.layout-table').css('tbody').css('tr').css('.track-panel-departure').css('.track-panel-terminal').children().text

  # Arrival terminal
  arrival_terminal = parse_page.css('#slideOutPanel').css('.pageContainer').css('.layout-table').css('tbody').css('tr').css('.track-panel-arrival').css('.track-panel-terminal').children().text

  # Takeoff time
  takeoff_time = parse_page.css('#slideOutPanel').css('.pageContainer').css('.layout-table').css('tbody').css('tr').css('.track-panel-scheduledtime').css('td')[0].text.strip().split(" ")[0]
  takeoff_iso_time = Time.strptime(takeoff_time, "%I:%M%P").strftime('%Y-%m-%dT%H:%M')

  #Arrival time
  arrival_time = parse_page.css('#slideOutPanel').css('.pageContainer').css('.layout-table').css('tbody').css('tr').css('.track-panel-scheduledtime').css('td')[1].text.strip().split(" ")[0]
  arrival_iso_time = Time.strptime(arrival_time, "%I:%M%P").strftime('%Y-%m-%dT%H:%M')

  if (arrival_iso_time < takeoff_iso_time)
    arrival_iso_time = arrival_iso_time + (12 * 60)
  end

  return {:airline_link => airline_link, :depart_city => depart_city, :depart_iata => depart_iata,
          :arrival_city => arrival_city, :arrival_iata => arrival_iata,
          :departing_terminal => departing_terminal, :arrival_terminal => arrival_terminal,
          :takeoff_iso_time => takeoff_iso_time, :arrival_iso_time => arrival_iso_time}
end

def get_flight_data_from_number(flight_no)
  url = flight_data_url_generator(flight_no)
  return extractor(url)
end
