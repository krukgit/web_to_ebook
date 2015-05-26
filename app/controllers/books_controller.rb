class BooksController < ApplicationController

  def create
    page = Page.find(params[:page_id])
    book = Book.create(content_page: page)
    book.generate
    redirect_to page_path(page)
  end
end
