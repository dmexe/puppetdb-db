require './boot'

map '/assets' do
  environment = Sprockets::Environment.new
  environment.append_path     'assets/javascripts'
  environment.append_path     'assets/stylesheets'
  environment.append_path     'assets/images'
  # environment.js_compressor = Uglifier.new(:copyright => false)
  # environment.css_compressor = YUI::CssCompressor.new
  run environment
end

map '/api' do
  run Application::Api
end

map '/' do
  run Application::Home
end

