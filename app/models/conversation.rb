class Conversation < ApplicationRecord
  serialize :flight_data, Hash
end
