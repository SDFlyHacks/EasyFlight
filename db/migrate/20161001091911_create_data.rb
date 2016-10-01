class CreateData < ActiveRecord::Migration[5.0]
  def change
    create_table :data do |t|
      t.string :passenger_name
      t.string :flight_number
      t.timestamp :start_time
      t.timestamp :lineup_time
      t.timestamp :departure_time

      t.timestamps
    end
  end
end
