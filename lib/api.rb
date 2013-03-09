require 'json'

module Application
  class Api < Application::Base

    before do
      content_type 'application/json'
    end

    get '/metrics' do
      json client.metrics
    end

    get '/nodes' do
      json client.nodes
    end

    get '/nodes/:node/facts' do |node|
      json client.facts(node)
    end

    get '/nodes/:node/reports' do |node|
      json client.reports(node)
    end

    get '/nodes/:node/reports/summary' do |node|
      json client.reports_summary(node)
    end

    get '/nodes/:node/reports/:report' do |node, report|
      json client.report(report)
    end

    private
      def json(body)
        body.to_json
      end

      def client
        PuppetDB::Client.inst
      end
  end
end
