Generate responsive images in Jekyll from pure markdown, without any Liquid tags. A simple wrapper around [jekyll_picture_tag](https://github.com/rbuchberger/jekyll_picture_tag/).

# How it works
At build time, uses regular expressions to replace your markdown `![Alt](/path/to/img.jpg)` with `{% jmri jmri /path/to/img.jpg alt=\"Alt\" %}`. The gem [`jekyll_picture_tag`](https://github.com/rbuchberger/jekyll_picture_tag/) then does the rest.

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