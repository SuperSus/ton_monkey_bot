class CreatePurchases < ActiveRecord::Migration[7.0]
  def change
    create_table :purchases do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :quantity
      t.string :comment, index: { unique: true }
      t.string :status
      t.decimal :price

      t.timestamps
    end
  end
end
