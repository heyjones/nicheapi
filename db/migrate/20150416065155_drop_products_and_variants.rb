class DropProductsAndVariants < ActiveRecord::Migration
  def change
	  drop_table :products
	  drop_table :variants
  end
end
