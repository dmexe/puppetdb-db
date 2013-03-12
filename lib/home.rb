require 'slim'

module Application
  class Home < Application::Base
    get '/' do
      redirect '/ui'
    end

    get '/ui' do
      slim :index
    end

    get '/ui/*' do
      slim :index
    end

    get '/tests' do
      slim :tests
    end
  end
end
