# require './flight_data_api'
# require './maps_api'
# require './tsa_api'

# def deliver_invalid_message(to_sender)
#   Bot.deliver(
#     recipient: to_sender,
#     message: {
#       text: "Sorry, that input is invalid. Please try again."
#     }
#   )

# Bot.on :message do |message|

#   sender = message.sender
#   convo = nil
#   #Query for the convo....
#   # - What uniquely identifies a convo?
#   #   - (sender, starting_time_of_first_convo)

#   if convo.nil?
#     convo = Conversation.new(sender_id: sender, state: 0)
#     Bot.deliver(
#       recipient: sender,
#       message: {
#         text: 'Hello! When and where will you be flying? Please respond in the following form: [Flight Number] (e.g. UAL1183)'
#       }
#     )
#   else
#     state = convo.state

#     case state
#     when 0
#       # Here, we need to look at the flight number the user sent.
#       # validate?
#       flight_num = message.text
#       convo.flight_number = flight_num

#       # Execute parser here. Get the flight data.
#       begin
#         flight_data = get_flight_data_from_number(flight_num)
#       rescue NoMethodError
#         deliver_invalid_message(sender)
#         return

#       Bot.deliver(
#         recipient: sender,
#         message: {
#           text: "Please share your location! :-)"
#           quick_replies: [
#             {
#               content_type: "location",
#             }
#           ]
#         }
#       )

#       # TODO: Deal with the location message callback.

#       convo.flight_data = flight_data
#       convo.state += 1
#       convo.save()
#     when 1
#       # Send the user the map!
#       Bot.deliver(
#         recipient: sender,
#         sender_action: 'typing_on',
#         message: {
#           attachment: {
#             type: "template",
#             payload: {
#               template_type: "button",
#               text: "See the map of your trip!",
#               buttons: [
#                 {
#                   type: "web_url",
#                   url: "lol.com",
#                   title: "View Map",
#                   webview_height_ratio: "compact"
#                 }
#               ]
#             }
#           }
#         }
#       )

#       # Send the user the check-in card.
#       Bot.deliver(
#         recipient: sender,
#         message: {
#           text: "Here's your check-in. When you're at the airport, enter 'okay' to continue."
#           attachment: {
#             type: "template",
#             payload: {
#               template_type: "airline_checkin",
#               intro_message: "Check-in is available now.",
#               locale: "en_US",
#               pnr_number: "ABCDEF",
#               flight_info: [
#                 {
#                   flight_number: "f001",
#                   departure_airport: {
#                     airport_code: "SFO",
#                     city: "San Francisco",
#                     terminal: "T4",
#                     gate: "G8"
#                   },
#                   arrival_airport: {
#                     airport_code: "SEA",
#                     city: "Seattle",
#                     terminal: "T4",
#                     gate: "G8"
#                   },
#                   flight_schedule: {
#                     boarding_time: "2016-01-05T15:05",
#                     departure_time: "2016-01-05T15:45",
#                     arrival_time: "2016-01-05T17:30"
#                   }
#                 }
#               ],
#               checkin_url: "https:\/\/www.airline.com\/check-in"
#             }
#           }
#         }
#       )

#       convo.state += 1
#       convo.save()
#     when 2
#       okay_message = message.text
#       if okay_message.casecmp("okay") == 0
#         # Let them know the TSA Screening time
#         # Call kevin's magical API CAll here
#         expected_wait_time = get_tsa_data_from_airport(convo.airport)

#         Bot.deliver(
#           recipient: sender,
#           message: {
#             text: "Great! Now, head over to the screening area. Note that the expected wait time right now is #{expected_wait_time}. Hope you have something to do in the meantime!"
#           }
#         )

#         convo.state += 1
#         convo.save()
#     when 3:
#       # Message 30 minutes before departure time.
#       # The user does not need to message for us to trigger this.
#       # We should tell the user to go to gate (...).
#       # "Have a good flight!"
#       Bot.deliver(
#         recipient: sender,
#         message: {
#           text: "Please go to gate #{gate_number}. Enjoy your flight!",
#         }
#       )
#   end
# end