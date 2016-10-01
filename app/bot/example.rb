include Facebook::Messenger

Facebook::Messenger.configure do |config|
  config.access_token = ENV['messenger_bot_access_token']
  config.app_secret = ENV["SECRET_KEY_BASE"]
  config.verify_token = ENV['messenger_bot_verify_token']
end

Bot.on :message do |message|
  Bot.deliver(
    recipient: message.sender,
    message: {
      text: 'Hello, human!'
    }
  )
end