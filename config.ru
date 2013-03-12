require './boot'
require 'sidekiq'
require 'sidekiq/web'

map '/assets' do
  run Application.assets
end

map '/sidekiq' do
  run Sidekiq::Web
end

map '/api' do
  run Application::Api
end

map '/' do
  run Application::Home
end

