class Book < ActiveRecord::Base

  belongs_to :content_page, class_name: "Page"
  has_many :chapter_pages, -> { order :id }, class_name: "Page"

  validates :content_page, presence: true
  before_save :fetch_title

  def doc
    @doc ||= Nokogiri::HTML::Document.parse "<html><body></body></html>"
  end

  def dir_name
    "book_#{title.parameterize}"
  end

  def generate
    self.title = content_page.title
    self.generate_chapters
    self.generate_content
  end

  def generate_chapters
    Dir.mkdir dir_name unless File.exists? dir_name

    content_page.links.each.with_index do |link,i|
      next if File.exists? "#{dir_name}/chapter_#{i+1}.html"
      puts "Generating chapter #{i+1}"
      page = Page.create book: self, url: link
      page.save_page "#{dir_name}/chapter_#{i+1}.html"
    end
  end

  def generate_content
    @doc = Nokogiri::HTML::Document.parse "<html><body></body></html>"

    body = doc.at_css "body"

    h1 = Nokogiri::XML::Node.new "h1", doc
    h1.content =  content_page.title

    body.add_child h1

    h2 = Nokogiri::XML::Node.new "h2", doc
    h2.content =  "Table of Contents"

    h1.add_next_sibling h2

    p = Nokogiri::XML::Node.new "p", doc
    p['style'] = "text-indent:0pt"

    h2.add_next_sibling p

    chapter_pages.each_with_index do |page, i|
      a = Nokogiri::XML::Node.new "a", doc
      a['href'] = page.filename || "#{dir_name}/chapter_#{i+1}.html"
      a.content = page.title #"Chapter #{i+1}: #{page.title}"
      p.add_child a
      br = Nokogiri::XML::Node.new "br", doc
      p.add_child br
      p.add_child "\n"
    end

    File.open('content.html', 'w') do |file|
      file.write doc.to_html
    end
  end

  private

  def fetch_title
    self.title = content_page.title
  end
end
