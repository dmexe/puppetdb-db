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

  def report_stats_attrs(options = {})
    {
      "success"   => 10,
      "failure"   => 2,
      "skipped"   => 1
    }.merge(options)
  end

  def events_attrs(options = {})
    [
      {
        "message"        => "a message",
        "new-value"      => "a new value",
        "old-value"      => 'a old value',
        "property"       => "ensure",
        "report"         => "abcd",
        "resource-title" => "/etc",
        "resource-type"  => "File",
        "status"         => "success",
        "timestamp"      => "2012-10-30T19:01:05.000Z"
      }.merge(options),
      {
        "message"        => "a message",
        "new-value"      => "a new value",
        "old-value"      => 'a old value',
        "property"       => "ensure",
        "report"         => "abcd",
        "resource-title" => "/etc",
        "resource-type"  => "File",
        "status"         => "failure",
        "timestamp"      => "2012-10-30T19:01:05.000Z"
      }.merge(options)
    ]
  end

  def node_attrs(options = {})
    {
      "name"              => "example.com",
      "deactivated"       => nil,
      "catalog_timestamp" => "2013-03-11T15:00:13.458Z",
      "facts_timestamp"   => "2013-03-11T15:00:10.754Z",
      "report_timestamp"  => "2013-03-11T15:00:18.000Z"
    }.merge(options)
  end

  def from_fixture(name)
    File.read File.expand_path(__FILE__ + "/../../fixtures/#{name}")
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
