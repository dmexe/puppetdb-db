module Application
  class Api < Application::Base

    before do
      content_type 'application/json'
    end

    get '/metrics' do
      json client.metrics
    end

    get '/stats/monthly' do
      json MonthlyReport.stats
    end

    get '/nodes' do
      json client.nodes
    end

    get '/nodes/:node/stats/monthly' do |node|
      json MonthlyReport.stats(node: node)
    end

    get '/nodes/:node/facts' do |node|
      json client.facts(node)
    end

    get '/nodes/:node/reports' do |node|
      json NodeReport.find_by_node_with_summary(node, limit: 100)
    end

    get '/nodes/:node/reports/:report' do |node, report|
      json Report.first(report)
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
