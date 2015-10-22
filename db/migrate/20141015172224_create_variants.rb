class CreateVariants < ActiveRecord::Migration
  def change
    create_table :variants, id: false do |t|
      t.integer :id
      t.string :barcode
      t.timestamps
    end
  end
end
