module FixturesSpecHelper
  def report_attrs(options = {})
    tm = options.delete("timestamp") || Time.now
    {
      "report"    => "abcd",
      "timestamp" => tm.to_s
    }.merge(options)
  end

  def node_report_attrs(options = {})
    node = options.delete("certname") || 'example.com'
    tm = options.delete("start-time") || Time.now
    {
      "hash"       => "abcd",
      "certname"   => node,
      "start-time" => tm.to_s,
      "end-time"   => (tm + 10).to_s
    }.merge(options)
  end

  def report_summary_attrs(options = {})
    tm = options.delete("timestamp") || Time.now
    {
      "hash"      => "abcd",
      "timestamp" => tm.to_i,
      "duration"  => 10,
      "success"   => 10,
      "failed"    => 2,
      "skipped"   => 1
    }.merge(options)
  end

  def json_fixture(name)
    File.read File.expand_path(__FILE__ + "/../../fixtures/#{name}.json")
  end


  def mock_puppetdb_reports_request(node_name)
    stub_request(:get, "http://localhost:8080/experimental/reports?query=%5B%22=%22,%22certname%22,%22#{node_name}%22%5D%20").
      with(:headers => {'Accept'=>'application/json' }).
      to_return(:status => 200,
                :body => json_fixture('puppetdb/reports'),
                :headers => {
                  'Content-Type' => 'application/json;charset=ISO-8859-1'
                })
  end

  def mock_puppetdb_events_request(hash)
    stub_request(:get, "http://localhost:8080/experimental/events?query=%5B%22=%22,%22report%22,%22#{hash}%22%5D%20").
      with(:headers => {'Accept'=>'application/json'}).
      to_return(:status => 200,
                :body => json_fixture('puppetdb/events'),
                :headers => {
                  'Content-Type' => 'application/json;charset=ISO-8859-1'
                })
  end
end
