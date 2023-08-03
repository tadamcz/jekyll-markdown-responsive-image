require 'jekyll_picture_tag'
require 'uri'

# The Jekyll hook we want to use. It runs after the page has been converted to HTML,
# but before Liquid tags are processed.
Jekyll::Hooks.register [:pages, :documents], :post_render do |doc, payload|
  
  # We only want to process HTML files
  if doc.output_ext == '.html' or doc.permalink&.end_with?('/')

    # The regular expression used to find the <img> tags in the HTML.
    img_tag_pattern = /<img src="([^"]*)" alt="([^"]*)"[^>]*>/

    # The gsub method replaces all instances of the regular expression with the result of the block.
    doc.output = doc.output.gsub(img_tag_pattern) do |match|
      
      # The block is passed the MatchData object. 
      # The $1, $2, etc. variables contain the parts of the string that matched the parts of the regex inside ().
      src = $1
      # Default to image filename if no alt text is provided.
      alt_text = $2 || File.basename(src, '.*')


      # We don't want to process SVGs or external files, so we skip those.
      if src =~ /\.(svg)$/i or src =~ /\A#{URI::DEFAULT_PARSER.make_regexp}\z/
        match  # Return the original match to leave it unchanged
      else

      # The URL for the image could be relative to the site root or the current page.
      # We construct the URL accordingly.
      src_from_root = if src.start_with?('/') # handle site-root-relative paths
                        src
                      else
                        File.join('/', File.dirname(doc.url), src)
                      end

      # We replace the <img> tag with the Liquid tag.
      # The Liquid tag will be processed in the next step of the Jekyll build process.
      "{% jmri jmri \"#{src_from_root}\" alt=\"#{alt_text}\" %}"
      end
    end
  end
end

# An alias ensures our plugin can be used alongside jekyll_picture_tag.
class JMRITag < PictureTag::Picture
end

# We register the new Liquid tag with Jekyll, so it knows about it and can process it.
Liquid::Template.register_tag('jmri', JMRITag)