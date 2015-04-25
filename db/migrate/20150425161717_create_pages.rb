class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string :title
      t.string :url
      t.text :links, array: true, default: []
      t.text :content

      t.timestamps
    end
  end
end
