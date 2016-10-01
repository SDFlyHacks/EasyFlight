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
      text: 'Hello, human!'
    }
  )
end