source "https://rubygems.org"

gem "jekyll", ">= 3.8.6", "< 5.0"

# plugins
group :jekyll_plugins do
  gem "jekyll-paginate"
  gem "jekyll-redirect-from"
  gem "jekyll-seo-tag", "~> 2.6.1"
  gem "jekyll-archives"
end

group :test do
  gem "html-proofer", "~> 3.19"
end

# Windows and JRuby does not include zoneinfo files, so bundle the tzinfo-data gem
# and associated library.
install_if -> { RUBY_PLATFORM =~ %r!mingw|mswin|java! } do
  gem "tzinfo", "~> 1.2"
  gem "tzinfo-data"
end

# Performance-booster for watching directories on Windows
# Windows file watcher (only for local `jekyll serve --livereload`)
gem "wdm", "~> 0.1", platforms: [:mingw, :windows, :mswin]

# nokogumbo is obsolete — nokogiri >= 1.12 includes gumbo parser
# gem "nokogumbo"   # ← 务必注释掉或删除