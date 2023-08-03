require 'jekyll'
require 'rspec'
require 'nokogiri'
require_relative '../lib/jekyll-markdown-responsive-image'

RSpec.describe 'jmri plugin' do
  let(:config) do
    Jekyll.configuration({
      "source"      => source_dir,
      "destination" => dest_dir,
    })
  end
  let(:site) { Jekyll::Site.new(config) }
  let(:source_dir) { File.join(__dir__, 'source') }
  let(:dest_dir) { File.join(__dir__, 'dest') }

  
  before(:each) do
    FileUtils.rm_rf(dest_dir)
    FileUtils.mkdir_p(source_dir)
  end

  after(:each) do
    FileUtils.rm_rf(source_dir)
    # FileUtils.rm_rf(dest_dir)
  end

  it 'converts image tag without alt text' do
    write_and_process_page('![](image.png)')
    expect_rendered_output('{% jmri jmri "/image.png" alt="" %}')
  end

  it 'converts image tag with alt text' do
    write_and_process_page('![Alt text](image.png)')
    expect_rendered_output('{% jmri jmri "/image.png" alt="Alt text" %}')
  end

  it 'converts image tag with special characters in alt text' do
    special_chars = ['!', '\'', '"', '@', '#', '$', '%', '^', '&', '*']
    
    special_chars.each do |char|
      alt_text = "Alt text#{char}"
      write_and_process_page("![#{alt_text}](image.png)")
  
      # Special handling for ampersand, which gets converted to &amp; in HTML
      expected_char = char == '&' ? '&amp;' : char

      expected_output = "{% jmri jmri \"/image.png\" alt=\"Alt text#{expected_char}\" %}"
      expect_rendered_output(expected_output)
    end
  end

  it 'converts linked image tag' do
    write_and_process_page('[![Alt Text](image.png)](https://example.com)')
    expect_rendered_output('<a href="https://example.com">{% jmri jmri "/image.png" alt="Alt Text" %}</a>')
  end

  it 'converts quoted linked image tag' do
    write_and_process_page('> [![Alt Text](image.png)](https://example.com)')
    expect_rendered_output('<blockquote><a href="https://example.com">{% jmri jmri "/image.png" alt="Alt Text" %}</a></blockquote>')
  end

  it 'converts image tag with alt text and link defined elsewhere' do
    write_and_process_page(<<~MARKDOWN)
    [![Alt Text][image]][link]

    [image]: image.jpg

    [link]: https://example.com
    MARKDOWN
    expect_rendered_output('<a href="https://example.com">{% jmri jmri "/image.jpg" alt="Alt Text" %}</a>')
  end

  it 'converts image tag without alt text and link defined elsewhere' do
    write_and_process_page(<<~MARKDOWN)
    [![image]][link]

    [image]: image.jpg

    [link]: https://example.com
    MARKDOWN
    expect_rendered_output('<a href="https://example.com">{% jmri jmri "/image.jpg" alt="image" %}</a>')
  end

  it "doesn't convert SVGs" do
    write_and_process_page('![](image.svg)')
    expect_rendered_output('<img src="image.svg" alt="">')
  end

  it "doesn't convert external images" do
    write_and_process_page('![](https://example.com/image.png)')
    expect_rendered_output('<img src="https://example.com/image.png" alt="">')
  end

  def write_and_process_page(content, page_path='page.md')
    File.write(File.join(source_dir, page_path), <<~MARKDOWN)
      ---
      ---
      #{content}
    MARKDOWN
  
    site.process
  end

  def expect_rendered_output(expected, page_path='page.html')
    html = File.read(File.join(dest_dir, page_path))
    doc = Nokogiri::HTML::DocumentFragment.parse(html)
  
    # Remove  <p> tags
    doc.css('p').each do |p|
      p.replace p.inner_html
    end
  
    # Normalize HTML
    doc.traverse do |node|
      if node.text?
        node.content = node.content.strip
      end
    end

    expect(doc.to_html.strip).to eq(expected)
    end
end