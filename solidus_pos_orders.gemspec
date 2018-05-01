$:.push File.expand_path('lib', __dir__)

require 'solidus_pos_orders/version'

Gem::Specification.new do |s|
  s.name        = 'solidus_pos_orders'
  s.version     = SolidusPosOrders::VERSION
  s.summary     = 'Create orders from a POS'
  s.description = 'Create orders from a POS'
  s.license     = 'BSD-3-Clause'

  s.author    = 'Craig'
  s.email     = 'craig@stembolt.com'

  s.files = Dir["{app,config,db,lib}/**/*", 'LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['test/**/*']

  s.add_dependency 'solidus_core', '~> 2.0'

  s.add_development_dependency 'capybara'
  s.add_development_dependency 'coffee-rails'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_girl'
  s.add_development_dependency 'poltergeist'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'rubocop', '~> 0.49.0'
  s.add_development_dependency 'rubocop-rspec', '1.4.0'
  s.add_development_dependency 'sass-rails'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'sqlite3'
end
