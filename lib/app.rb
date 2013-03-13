require 'sinatra'
require 'pathname'

module App
  class Base < ::Sinatra::Base
    set :root,    App.root.to_s
    set :views,   App.root.join("views").to_s
    set :logging, true
  end
end
