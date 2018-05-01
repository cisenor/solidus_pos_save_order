class AddAddressIdToSpreeStores < ActiveRecord::Migration[5.1]
  def change
    add_column :spree_stores, :address_id, :number
  end
end
