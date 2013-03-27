require 'yaml'
require 'json'
require 'digest'

class ReportProcessing
  def initialize(content)
    @content = content
  end

  def body
    @body ||= (YAML.load(sanitize(@content)) || {})
  end

  def digest
    Digest::SHA256.hexdigest(@content)
  end

  def resources
    if body["resource_statuses"] && body["resource_statuses"].respond_to?(:map)
      @resources ||= body["resource_statuses"].map do |resource, report|
        Resource.new report["resource_type"],
                     report["title"],
                     report["time"],
                     extract_message(report),
                     extract_status(report)
      end
    else
      []
    end
  end

  def stats
    @stats ||= begin
      s = resources.group_by{|i| i.status }.map{|k,v| [k,v.size] }.sort
      s = Hash[s]
      Stats.new(s[:success], s[:failed], s[:skipped])
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
    if body["metrics"] && body["metrics"]["time"] && body["metrics"]["time"]["values"]
      total = body["metrics"]["time"]["values"].find do |val|
        val[0] == "total"
      end
      total[2]
    end
  end

  def to_hash
    {
      :node     => host,
      :time     => time,
      :version  => version,
      :duration => duration,
      :digest   => digest,
      :events   => resources.map{|i| i.to_hash },
      :success  => stats.success,
      :failed   => stats.failed,
      :skipped  => stats.skipped
    }
  end

  class Stats < Struct.new(:success, :failed, :skipped)
  end

  class Resource < Struct.new(:type, :title, :time,
                              :message, :status)
    def to_hash
      { :type    => type,
        :title   => title,
        :time    => time.utc,
        :message => message,
        :status  => status }
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
        :success
      elsif failed
        :failed
      else
        :skipped
      end
    end

end
