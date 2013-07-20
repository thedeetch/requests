source 'https://rubygems.org'

gem 'rails', '3.2.8'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

#gem 'sqlite3'
#gem 'pg'

group :development, :test do
   # Sqlite support for test
   gem 'sqlite3'
end
group :production do
  # Postgres support for Heroku
  gem 'pg'

  # Compress pages and assets
  gem 'heroku_rails_deflate'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  
  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'

end

gem 'jquery-rails'
gem 'therubyracer'
gem 'less-rails'

# Twitter Bootstrap
gem 'twitter-bootstrap-rails'

# Bootstrap datepicker
gem 'bootstrap-datepicker-rails'

# Fontawesome icons
gem 'font-awesome-rails'

# To use fancy jQuery datatables
gem 'jquery-datatables-rails'

# To use LDAP queries
gem 'net-ldap'

# To use file uploads in models
gem 'carrierwave'

# To use model version history
gem 'paper_trail'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'
