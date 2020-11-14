source "https://rubygems.org"

gem "jekyll", ">=3.8.6"

# Official Plugins
group :jekyll_plugins do
  gem 'wdm', '>= 0.1.0' if Gem.win_platform?
  gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw]
  gem "tzinfo"
  gem "jekyll-paginate"
  gem "jekyll-redirect-from"
  gem "jekyll-seo-tag", "~> 2.6.1"
end

group :test do
  gem "html-proofer"
end
