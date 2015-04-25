class HomeController < ApplicationController
  def index
    @content ||= Content.new
  end
end
