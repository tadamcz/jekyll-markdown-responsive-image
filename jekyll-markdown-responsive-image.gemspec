# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name             = "jekyll-markdown-responsive-image"
  spec.homepage         = "https://github.com/tadamcz/jekyll-markdown-responsive-image"
  spec.license          = "MIT"
  spec.version          = "0.0.1"
  spec.authors          = ["tadamcz"]
  spec.email            = ["tadamczewskipublic@gmail.com"]
  spec.summary          = "
  Generate responsive images from pure markdown, without any Liquid tags.
  A simple wrapper around jekyll_picture_tag."

  spec.files            = Dir["lib/**/*"]
  spec.require_paths    = ["lib"]

  spec.add_dependency "jekyll_picture_tag", "~> 2"
  spec.add_development_dependency 'rspec', '~> 3.10'
  spec.add_development_dependency 'nokogiri', '~> 1.15'
end