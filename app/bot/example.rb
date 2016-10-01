include Facebook::Messenger

Facebook::Messenger.configure do |config|
  config.access_token = ENV['messenger_bot_access_token']
  config.app_secret = ENV["messenger_bot_app_secret"]
  config.verify_token = ENV['messenger_bot_verify_token']
end

Facebook::Messenger::Subscriptions.subscribe

Bot.on :message do |message|
  Bot.deliver(
    recipient: message.sender,
    message: {
      text: 'Hello! When and where will you be flying? Please respond in the folloinwg form: [Flight Number] (e.g. UAL1183)'
    }
  )
end

# Bot.on :message do |message|
#   Bot.deliver(
#     recipient: message.sender,
#     message: {
#       attachment: {
#         type: "template",
#         payload: {
#           template_type: "airline_checkin",
#           intro_message: "Check-in is available now.",
#           locale: "en_US",
#           pnr_number: "ABCDEF",
#           flight_info: [
#             {
#               flight_number: "f001",
#               departure_airport: {
#                 airport_code: "SFO",
#                 city: "San Francisco",
#                 terminal: "T4",
#                 gate: "G8"
#               },
#               arrival_airport: {
#                 airport_code: "SEA",
#                 city: "Seattle",
#                 terminal: "T4",
#                 gate: "G8"
#               },
#               flight_schedule: {
#                 boarding_time: "2016-01-05T15:05",
#                 departure_time: "2016-01-05T15:45",
#                 arrival_time: "2016-01-05T17:30"
#               }
#             }
#           ],
#           checkin_url: "https:\/\/www.airline.com\/check-in"
#         }
#       }
#     }
#   )
# end