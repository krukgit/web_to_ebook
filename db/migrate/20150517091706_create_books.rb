class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.string :title
      t.integer :content_page_id

      t.timestamps
    end
  end
end
