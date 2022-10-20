Jekyll::Hooks.register [:pages, :documents], :pre_render do |post, payload|
  file_ext = post.extname.tr('.', '')

  # This regex will match all of the following correctly:
  #
  # ![](image.png)
  # ![Alt text](image.png)
  # ![Alt text!'"@#$%^&*](image.png)
  # [![Alt Text](image.png)](https://example.com)
  # > [![Alt Text](image.png)](https://example.com)
  image_markdown = /!\[([^()]*)\]\(([^()]+)\)/

  # Only process if we deal with a markdown file
  if payload['site']['markdown_ext'].include? file_ext

    post.content = post.content.gsub(image_markdown) do
      match = Regexp.last_match
      alt_text = match[1]
      src = match[2]
      src_extension = File.extname(src)

      # SVGs are not supported by jekyll_picture_tag
      if src_extension == ".svg"
        next match
      end

      # Skip external files. jekyll_picture_tag cannot download and process these.
      if src.start_with?("http://", "https://", "ftp://", "ssh://")
        next match
      end

      # This allows us to specify in our markdown files
      # the image path relative to the location of the markdown file.
      # That's the format that GUI markdown editors expect.
      src_from_root = "#{File.dirname(post.relative_path)}/#{src}"

      "{% jmri jmri \"#{src_from_root}\" alt=\"#{alt_text}\" %}"
    end
  end
end


require 'jekyll_picture_tag'

class JMRITag < PictureTag::Picture
end

Liquid::Template.register_tag('jmri', JMRITag)