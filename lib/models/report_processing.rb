require 'yaml'
require 'json'
require 'digest'

class ReportProcessing
  def initialize(content)
    @content = content
  end

  def process_delayed!
    true
  end

  def proccess!
    true
  end

  def body
    @body ||= YAML.load sanitize(@content)
  end

  def hash
    Digest::SHA256.hexdigest(@content)
  end

  def resources
    @resources ||= body["resource_statuses"].map do |resource, report|
      Resource.new report["resource_type"],
                   report["title"],
                   report["time"],
                   extract_message(report),
                   extract_status(report)
    end
  end

  def time
    body["time"]
  end

  def version
    body["configuration_version"]
  end

  def host
    body["host"]
  end

  def environment
    body["environment"]
  end

  def duration
    total = body["metrics"]["time"]["values"].find do |val|
      val[0] == "total"
    end
    total[2]
  end

  class Resource < Struct.new(:type, :title, :time,
                              :message, :status)
    def to_json
      { :type    => type,
        :title   => title,
        :time    => time.utc,
        :message => message,
        :status  => status }.to_json
    end
  end

  private
    def sanitize(body)
      body.to_s.gsub(/!ruby\/.+$/, '')
    end

    def extract_message(report)
      report["events"].map{|h| h["message"] }.join(", ")
    end

    def extract_status(report)
      changed = report["changed"]
      failed  = report["failed"]

      if changed && !failed
        :changed
      elsif failed
        :failed
      else
        :skipped
      end
    end

end
