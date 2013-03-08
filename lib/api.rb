require 'json'
require "sinatra/json"

module Application
  class Api < Application::Base
    helpers Sinatra::JSON
    set :json_encoder, :to_json

    get '/nodes' do
      json client.nodes
    end

    get '/nodes/:node/facts' do |node|
      json client.facts(node)
    end

    get '/nodes/:node/reports' do |node|
      json client.reports(node)
    end

    get '/nodes/:node/reports/:report' do |node, report|
      json client.report(report)
    end

    private
      def client
        PuppetDB::Client.inst
      end
  end
end
