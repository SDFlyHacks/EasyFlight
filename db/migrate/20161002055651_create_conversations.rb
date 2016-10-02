class CreateConversations < ActiveRecord::Migration[5.0]
  def change
    create_table :conversations do |t|
      t.integer :state
      t.text :sender
      t.text :flight_number
      t.text :flight_data
      t.timestamp :starting_time

      t.timestamps
    end
  end
end
