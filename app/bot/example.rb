# include Facebook::Messenger

# Facebook::Messenger.configure do |config|
#   config.access_token = ENV['messenger_bot_access_token']
#   config.app_secret = ENV["messenger_bot_app_secret"]
#   config.verify_token = ENV['messenger_bot_verify_token']
# end

# Facebook::Messenger::Subscriptions.subscribe

# Bot.on :message do |message|
#   sender = message.sender

#   Bot.deliver(
#     recipient: message.sender,
#     message: {
#       text: 'Hello! When and where will you be flying? Please respond in the following form: [Flight Number] (e.g. UAL1183)'
#     }
#   )
# end