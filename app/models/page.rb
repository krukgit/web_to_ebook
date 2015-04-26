class Page < ActiveRecord::Base
  before_validation :fetch_title, :fetch_links, :fetch_content

  CONTENT_TAGS = ['#content', '#main', 'article', '.post-body', '.entry-content', '#chapterContent']
  REMOVE_TAGS = ['.toplink', '.adsbygoogle']
  REMOVE_KEYWORDS = ['adsbygoogle', 'Share this:', 'Like this:']
  INSPECT_TAGS = ['tbody','div','table']
  def browser
    @@browser ||= Watir::Browser.new :chrome
  end

  def doc
    return @doc if @doc
    browser.goto url
    @doc ||= Nokogiri::HTML.parse(browser.html)
  end

  def fetch_title
    self.title ||= doc.title
  end

  def fetch_links
    return if self.links.present?
    self.links = doc.css('a').map{|link| link['href']}
    self.links.compact.select!{|link| !link.include? 'javascript'}
    self.links.compact.map!{|link| link.include?('http') ? link : "#{url}#{link}"}
  end

  def fetch_content
    html = ''
    CONTENT_TAGS.each do |css|
      candidate = doc.css(css)
      html = [html, candidate].select(&:present?).sort_by{|el| el.try(:to_html).length}.first
    end
    REMOVE_TAGS.each do |css|
      html.css(css).each do |node|
        node.remove
      end
    end
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

  def save_page
    File.open("page_#{id}.html", 'w') do |file|
      file.write self.content
    end
  end
end
