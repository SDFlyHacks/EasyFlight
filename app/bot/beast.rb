require 'flight_data_api'
require 'maps_api'
require 'tsa_api'

include Facebook::Messenger

Facebook::Messenger.configure do |config|
  config.access_token = ENV['messenger_bot_access_token']
  config.app_secret = ENV['messenger_bot_app_secret']
  config.verify_token = ENV['messenger_bot_verify_token']
end

# Facebook::Messenger::Subscriptions.subscribe

def deliver_invalid_message(to_sender)
  Bot.deliver(
    recipient: to_sender,
    message: {
      text: 'Sorry, that input is invalid. Please try again.'
    }
  )
end

def time_from_now_until_boarding(departure_time)
  boarding = departure_time - 30.minutes
  (boarding - Time.now).round
end

Bot.on :message do |message|
  puts 'INCOMING MESSAGE:'
  puts message.id
  puts message.sender
  puts message.seq
  puts message.sent_at
  puts message.text
  puts message.attachments
  puts 'END MESSAGE'

  sender = message.sender
  sender_id = sender['id']
  convo = Conversation.where(sender: sender_id).order(created_at: :desc).first
  # Query for the convo....
  # - What uniquely identifies a convo?
  #   - (sender, starting_time_of_first_convo)

  if convo.nil?
    convo = Conversation.new(sender: sender_id, state: 0)
    Bot.deliver(
      recipient: sender,
      message: {
        text: 'Hello! When and where will you be flying?
               Please respond in the following form:
               [Flight Number] (e.g. UAL1183)'
      }
    )
    convo.save
  else
    state = convo.state

    case state
    when 0
      # We get the flight data, and then follow-up by asking the user
      # for their location.

      flight_num = message.text
      convo.flight_number = flight_num

      # Execute parser here. Get the flight data.
      begin
        flight_data = get_flight_data_from_number(flight_num)
      rescue NoMethodError
        deliver_invalid_message(sender)
      else
        Bot.deliver(
          recipient: sender,
          message: {
            text: 'Please share your location! :-)',
            quick_replies: [
              {
                content_type: 'location'
              }
            ]
          }
        )

        convo.flight_data = flight_data
        convo.state += 1
        convo.save
      end
    when 1
      # We give the user:
      #   - A map indicating the trip from origin to airport of departure
      #   - A check-in card.

      # PULL OUT ORIGIN FROM CALLBACK
      # Warning: It MUST be the case that the user went ahead and
      # shared their location through the quick reply option given above.
      # If they did not, we cannot advance just yet.
      if !message.attachments.nil? &&
         !message.attachments['payload'].nil? &&
         !message.attachments['payload']['coordinates'].nil?
        lat = message.attachments['payload']['coordinates']['lat']
        lng = message.attachments['payload']['coordinates']['long']

        map_link = url_generator('#{lat},#{lng}',
                                 convo.flight_data[:depart_airport])

        # Send the user the map!
        Bot.deliver(
          recipient: sender,
          sender_action: 'typing_on',
          message: {
            attachment: {
              type: 'template',
              payload: {
                template_type: 'button',
                text: 'See the map of your trip!',
                buttons: [
                  {
                    type: 'web_url',
                    url: map_link,
                    title: 'View Map',
                    webview_height_ratio: 'compact'
                  }
                ]
              }
            }
          }
        )

        # Send the user the check-in card.
        Bot.deliver(
          recipient: sender,
          message: {
            text: "Here's your check-in.
                   When you're at the airport, enter 'okay' to continue.",
            attachment: {
              type: 'template',
              payload: {
                template_type: 'airline_checkin',
                intro_message: 'Check-in is available now.',
                locale: 'en_US',
                pnr_number: 'ABCDEF',
                flight_info: [
                  {
                    flight_number: convo.flight_data[:flight_number],
                    departure_airport: {
                      airport_code: convo.flight_data[:depart_iata],
                      city: convo.flight_data[:depart_city],
                      terminal: '',
                      gate: convo.flight_data[:departing_terminal]
                    },
                    arrival_airport: {
                      airport_code: convo.flight_data[:arrival_iata],
                      city: convo.flight_data[:arrival_city],
                      terminal: '',
                      gate: convo.flight_data[:arrival_terminal]
                    },
                    flight_schedule: {
                      boarding_time: '2016-01-05T15:05',
                      departure_time: convo.flight_data[:takeoff_iso_time],
                      arrival_time: convo.flight_data[:arrival_iso_time]
                    }
                  }
                ],
                checkin_url: convo.flight_data[:airline_link]
              }
            }
          }
        )

        convo.state += 1
        convo.save

        Thread.new do
          # Sleep until its time to board!
          sleep(time_from_now_until_boarding(convo.flight_data[:takeoff_iso_time]))

          Bot.deliver(
            recipient: sender,
            message: {
              text: 'Please go to gate #{gate_number}. Enjoy your flight!'
            }
          )
        end
      else
        deliver_invalid_message(sender)
      end
    when 2
      # We tell the user the expected TSA Screening time.
      okay_message = message.text
      if okay_message.casecmp('okay').zero?
        expected_wait_time =
          get_tsa_data_from_airport(convo.flight_data[:depart_iata])

        Bot.deliver(
          recipient: sender,
          message: {
            text: 'Great! Now, head over to the screening area.
                   Note that the expected wait time
                   right now is #{expected_wait_time}.
                   Hope you have something to do in the meantime!'
          }
        )

        convo.state += 1
        convo.save
      else
        deliver_invalid_message(sender)
      end
    when 3
      # Message 30 minutes before departure time.
      # The user does not need to message for us to trigger this.
      # We should tell the user to go to gate (...).
      # 'Have a good flight!'
      Bot.deliver(
        recipient: sender,
        message: {
          text: 'Please go to gate #{gate_number}. Enjoy your flight!'
        }
      )
      convo.state += 1
      convo.save
    end
  end
end
