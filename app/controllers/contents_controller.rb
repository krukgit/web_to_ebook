class ContentsController < ApplicationController
  def new
    @content = Content.new
  end

  def create
    @content = Content.create content_params
    @content.fetch_links
    render 'contents/show'
  end

  private

  def content_params
    params.require(:content).permit(:url)
  end
end
