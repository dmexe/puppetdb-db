require './boot'
require 'sidekiq'
require 'sidekiq/web'

map '/assets' do
  run App.assets
end

map '/sidekiq' do
  run Sidekiq::Web
end

map '/api' do
  run App::Api
end

map '/reports' do
  run App::Reports
end

map '/' do
  run App::Home
end

