require 'open-uri'

class Page < ActiveRecord::Base
  before_validation :fetch_title, :fetch_links, :fetch_content

  def doc
    @doc ||= Nokogiri::HTML(open(url))
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

  end
end
