require 'kramdown'
require 'jekyll_picture_tag'

Jekyll::Hooks.register [:pages, :documents], :pre_render do |post, payload|
  file_ext = post.extname.tr('.', '')

  # Only process if we deal with a markdown file
  if payload['site']['markdown_ext'].include? file_ext
    post.content = process_post(post)
  end
end

# An alias ensures our plugin can be used alongside jekyll_picture_tag.
class JMRITag < PictureTag::Picture
end

Liquid::Template.register_tag('jmri', JMRITag)


def process_node(node, post, images=[])
  node.children.map! do |child|
    if child.type == :img
      

      alt_text = child.attr['alt']
      src = child.attr['src']

      alt_text = child.attr['alt']
      src = child.attr['src']
      start_location = child.options[:location] # Assuming this returns the start location
      images << {node: child, src: src, alt: alt_text, location: start_location}


      # SVGs are not supported by jekyll_picture_tag
      if src.end_with?('.svg')
        next child
      end

      # If the alt text is empty, use the filename
      if alt_text.empty?
        alt_text = File.basename(src, '.*')
      end

      # Skip external files. jekyll_picture_tag cannot download and process these.
      if src.start_with?("http://", "https://", "ftp://", "ssh://")
        next child
      end

      # This allows us to specify in our markdown files
      # the image path relative to the location of the markdown file.
      # That's the format that GUI markdown editors expect.
      if src.start_with?('/')
        src_from_root = src
      else
        src_from_root = "#{File.dirname(post.relative_path)}/#{src}"
      end

      # Change the node type to :raw and set the value to the new string
      # The first 'jmri' is the name of the tag registered below, the second is the name of the
      # preset that needs to be defined in `data/_picture.yml`
      new_str = "{% jmri jmri \"#{src_from_root}\" alt=\"#{alt_text}\" %}"
      
      Kramdown::Element.new(:raw, new_str)
    else
      process_node(child, post) # Process the child node
      child
    end
  end
end

def process_post(post)
  # It's crucial to override the line width, otherwise kramdown will split our Liquid tags!
  # An alternative may be to convert to HTML instead of kramdown.
  document = Kramdown::Document.new(post.content, options = {line_width: 99999})
  process_node(document.root, post) # Start processing from the root node

  # Get the image nodes and their locations
  images = process_node(document.root, post)
  puts "Images: #{images}"
  
  puts "Input: #{post.content}"
  puts "Output: #{document.to_kramdown}"
  return document.to_kramdown
end