require 'open-uri'

class Page < ActiveRecord::Base
  before_validation :fetch_title, :fetch_links, :fetch_content

  def browser
    @@browser ||= Watir::Browser.new :chrome
  end

  def doc
    return @doc if @doc
    @@browser.goto url
    @doc ||= Nokogiri::HTML(open(@@browser.html))
  end

  def fetch_title
    self.title ||= doc.title
  end

  def fetch_links
    return if self.links.present?
    self.links = doc.css('a').map{|link| link['href']}
    self.links.select!{|link| !link.include? 'javascript'}
    self.links.map!{|link| link.include?('http') ? link : "#{url}#{link}"}
  end

  def fetch_content
    doc.css('#content')
  end
end
