require 'jekyll'
require 'rspec'
require 'nokogiri'
require_relative '../lib/jekyll-markdown-responsive-image'

RSpec.describe 'process_post' do
  def create_post(content)
    site = Jekyll::Site.new(Jekyll.configuration)
    post = Jekyll::Document.new("test.md", { :site => site, :collection => site.posts })
    post.content = content
    post
  end

  def remove_nomarkdown_tags(string)
    # Hacky
    string.gsub(/\{\:\/\}/, '').gsub(/\{\:\:nomarkdown\}/, '').strip
  end

  def process_post_and_remove_nomarkdown_tags(post)
    result = process_post(post)
    remove_nomarkdown_tags(result)
end
  
  it 'converts image tag without alt text' do
    post = create_post('![](image.png)')
    result = process_post_and_remove_nomarkdown_tags(post)
    expect(result.strip).to eq '{% jmri jmri "image.png" alt="image" %}'
  end

  it 'converts image tag with alt text' do
    post = create_post('![Alt text](image.png)')
    result = process_post_and_remove_nomarkdown_tags(post)
    expect(result.strip).to eq '{% jmri jmri "image.png" alt="Alt text" %}'
  end

  it 'converts image tag with special characters in alt text' do
    special_chars = ['!', '\'', '"', '@', '#', '$', '%', '^', '&', '*']
    
    special_chars.each do |char|
      alt_text = "Alt text#{char}"
      post = create_post("![#{alt_text}](image.png)")
      result = process_post_and_remove_nomarkdown_tags(post)
      expect(result.strip).to eq "{% jmri jmri \"image.png\" alt=\"#{alt_text}\" %}"
    end
  end

  it 'converts linked image tag' do
    post = create_post('[![Alt Text](image.png)](https://example.com)')
    result = process_post_and_remove_nomarkdown_tags(post)
    expect(result.strip).to eq '[{% jmri jmri "image.png" alt="Alt Text" %}](https://example.com)'
  end

  it 'converts quoted linked image tag' do
    post = create_post('> [![Alt Text](image.png)](https://example.com)')
    result = process_post_and_remove_nomarkdown_tags(post)
    expect(result.strip).to eq '> [{% jmri jmri "image.png" alt="Alt Text" %}](https://example.com)'
  end

  it "doesn't convert SVGs" do
    post = create_post('![](image.svg)')
    result = process_post_and_remove_nomarkdown_tags(post)
    expect(result.strip).to eq '![](image.svg)'
  end

  it "doesn't convert external images" do
    post = create_post('![](https://example.com/image.png)')
    result = process_post_and_remove_nomarkdown_tags(post)
    expect(result.strip).to eq '![](https://example.com/image.png)'
  end
end
