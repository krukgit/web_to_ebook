require 'open-uri'

class Page < ActiveRecord::Base
  before_validation :fetch_title, :fetch_links, :fetch_content
  attr_accessor :filename, :javascript

  belongs_to :book

  CONTENT_TAGS = ['#con_L', '#content', '#main', 'article', '.post-body', '.entry-content', '#chapterContent', '.yd_text2']
  REMOVE_TAGS = ['a', 'script', 'aside','footer', 'header', 'img', '.toplink', '.adsbygoogle']
  REMOVE_KEYWORDS = ['adsbygoogle', 'Share this:', 'Like this:']
  INSPECT_TAGS = ['tbody','div','table']
  def browser
    @@browser ||= Watir::Browser.new :chrome
  end

  def doc
    return @doc if @doc
    if javascript
      browser.goto url
      @doc ||= Nokogiri::HTML.parse(browser.html)
    else
      @doc ||= Nokogiri::HTML.parse(open(url))
    end
  end

  def fetch_title
    self.title ||= Pismo::Document.new(doc.to_html).title
  end

  def fetch_links
    return if self.links.present?
    self.links = doc.css('a').map{|link| link['href']}
    self.links = links.compact.select{|link| !link.include? 'javascript'}
    self.links = links.compact.map{|link| link.include?('http') ? link : /(.*\/).*$/.match(url)[1] + link }
  end

  def fetch_content
    html = ''
    CONTENT_TAGS.each do |css|
      candidate = doc.css(css)
      html = [html, candidate].select(&:present?).sort_by{|el| el.try(:to_html).length}.first
    end
    return if !html.present?
    REMOVE_TAGS.each do |css|
      html.css(css).each do |node|
        node.remove
      end
    end
    return if !html.present?
    REMOVE_KEYWORDS.each do |keyword|
      INSPECT_TAGS.each do |tag|
        html.css(tag).each do |node|
          node.remove if node.to_html.include? keyword
        end
      end
    end
    html = Sanitize.document(html.to_html, Sanitize::Config::RELAXED)
    self.content = html
  end

  def save_page path="page.html"
    self.filename = path
    File.open(path, 'w') do |file|
      file.write self.content
    end
    save
  end
end
