class PagesController < ApplicationController
  def new
    @page = Page.new
  end

  def create
    @page = Page.create page_params
    puts @page.as_json
    render 'pages/show'
  end

  def show
    @pages = Page.find(params[:id])
  end

  def update
    @page = Page.find(params[:id])
    @page.update_attributes page_params
    links =  params[:links].map{|k,v| @page.links[k.to_i]}
    @page.update_attributes links: links if links
    render 'pages/show'
  end

  private

  def page_params
    params.require(:page).permit(:url, :title)
  end
end