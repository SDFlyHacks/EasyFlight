class AddConversationToData < ActiveRecord::Migration[5.0]
  def change
    add_column :data, :sender, :text
    add_column :data, :state, :integer
    remove_column :data, :passenger_name
  end
end
