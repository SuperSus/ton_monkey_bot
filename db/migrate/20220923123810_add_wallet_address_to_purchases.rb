class AddWalletAddressToPurchases < ActiveRecord::Migration[7.0]
  def change
    add_column :purchases, :wallet_address, :string
  end
end
