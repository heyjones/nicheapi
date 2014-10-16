class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products, id: false do |t|
      t.integer :id
      t.string :code
      t.timestamps
    end
  end
end