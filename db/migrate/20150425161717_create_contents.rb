class CreateContents < ActiveRecord::Migration
  def change
    create_table :contents do |t|
      t.string :title
      t.string :url
      t.text :links, array: true, default: []

      t.timestamps
    end
  end
end
