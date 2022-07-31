class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :username
      t.string :telegram_id, index: { unique: true }
      t.references :referrer, foreign_key: { to_table: :users }
      t.boolean :admin

      t.timestamps
    end
  end
end
