class AddBookIdToPages < ActiveRecord::Migration
  def change
    add_column :pages, :book_id, :integer
  end
end
