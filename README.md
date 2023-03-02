Generate [responsive images](https://developer.mozilla.org/en-US/docs/Learn/HTML/Multimedia_and_embedding/Responsive_images) in Jekyll from pure markdown, without any Liquid tags. A simple wrapper around [jekyll_picture_tag](https://github.com/rbuchberger/jekyll_picture_tag/).

⚠️ Warning: this is alpha-level software, with several problems and no formal tests. See TODOs below ⚠️

# Installation and usage
Install [`libvips`](https://www.libvips.org/install.html). (For example, with Homebrew `brew vips` should suffice, or on Ubuntu `apt install libvips libvips-tools`. Note that if you use a deployment or CI service, these dependencies will be required there as well).

Add the gem to your Gemfile:
```
group :jekyll_plugins do
	# other jekyll plugins
	gem 'jekyll-markdown-responsive-image', github: 'tadamcz/jekyll-markdown-responsive-image'
end
```

Run `bundle install`. That's it! You don't need to configure anything or modify your source files.

# Configuration
All configuration is optional.

To override the configuration that is passed to `jekyll_picture_tag`, you must supply a `_data/picture.yml` file ([docs](http://rbuchberger.github.io/jekyll_picture_tag/users/presets/)) and define the `jmri` preset. For example:

```yaml
# _data/picture.yml
presets:
  jmri:
    widths: [400, 600, 800, 1000, 1500, 2000]
    formats: [ webp, jpeg ]
    format_quality:
      webp: 75
    dimension_attributes: true
```

Any keys that are not provided will use the `jekyll_picture_tag` [default preset](http://rbuchberger.github.io/jekyll_picture_tag/users/presets/default.html).

# How it works
At build time, uses regular expressions to replace your markdown `![Alt](/path/to/img.jpg)` with `{% jmri jmri /path/to/img.jpg alt=\"Alt\" %}`. The gem [`jekyll_picture_tag`](https://github.com/rbuchberger/jekyll_picture_tag/) then does the rest.

# TODO, PRs welcome!
- add tests
- do not match markdown image tags that are inside code blocks, which is obviously undesirable.
- [maybe?] respect (some?) kramdown extensions such as [inline attribute lists](https://kramdown.gettalong.org/syntax.html#inline-attribute-lists)
- decide what to do about markdown inside HTML blocks (e.g. [see Kramdown](https://kramdown.gettalong.org/syntax.html#html-blocks))