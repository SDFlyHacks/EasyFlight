include Facebook::Messenger

Bot.on :message do |message|
  Bot.deliver(
    recipient: message.sender,
    message: {
      text: 'Hello, human!'
    }
  )
end