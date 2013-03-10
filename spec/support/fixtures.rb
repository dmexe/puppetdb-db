module FixturesSpecHelper
  def report_attrs(options = {})
    tm = options.delete("timestamp") || Time.now
    {
      "report"    => "abcd",
      "timestamp" => tm.to_s
    }.merge(options)
  end

  def node_report_attrs(options = {})
    node = 'example.com'
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
end
