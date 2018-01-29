class AddLineDisplayNameToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :line_display_name, :string
  end
end
