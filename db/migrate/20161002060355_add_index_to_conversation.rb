class AddIndexToConversation < ActiveRecord::Migration[5.0]
  def change
    add_index :conversations, :sender
  end
end
