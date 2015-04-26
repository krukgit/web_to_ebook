class Book

  attr_accessor :title, :content_page, :chapter_pages

  def doc
    @doc ||= Nokogiri::HTML::Document.parse "<html><body></body></html>"
  end

  def dir_name
    "book_#{title.parameterize}"
  end

  def generate_chapters
    Dir.mkdir dir_name unless File.exists? dir_name

    self.chapter_pages = []
    content_page.links.each_with_index do |link,i|
      page = Page.create url: link
      self.chapter_pages << page
      page.save_page "#{dir_name}/chapter_#{i+1}.html"
    end
  end

  def generate_content
    body = doc.at_css "body"

    h1 = Nokogiri::XML::Node.new "h1", doc
    h1.content =  "Table of Contents"

    body.add_child h1

    p = Nokogiri::XML::Node.new "p", doc
    p['style'] = "text-indent:0pt"

    h1.add_next_sibling p

    chapter_pages.each_with_index do |page, i|
      a = Nokogiri::XML::Node.new "a", doc
      a['href'] = page.filename
      a.content = "Chapter #{i+1}: #{page.title}"
      p.add_child a
      br = Nokogiri::XML::Node.new "br", doc
      p.add_child br
    end

    File.open('content.html', 'w') do |file|
      file.write doc.to_html
    end
  end
end
