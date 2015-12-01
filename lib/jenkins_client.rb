require 'jenkins_api_client'
require 'date'

module JenkinsApi
  class Client
    def get_jenkins_version
      '1.518'
    end
  end
end

class JenkinsClient

  def initialize

    Rails.env ||= :development

    yml = YAML.load(ERB.new(File.read('config/jenkins.yml')).result)[Rails.env]
    @client = JenkinsApi::Client.new(:server_url => yml['server_url'],
                                     :username => yml['username'], :password => yml['password'],
                                     :ssl => yml['ssl'],
                                     :proxy_ip => yml['proxy_ip'], :proxy_port => yml['proxy_port'])
  end

  def last_x_builds(job_name, n=1)
    @client.job.get_builds(job_name)[0..n-1]
  end

  def avg_build_duration(job_name)
    durations = []
    @client.job.get_x_builds(job_name, 10).each do |build|
      hash = @client.job.get_build_details(job_name, build["number"])
      durations << hash["duration"]/1000 if hash['building'] == false
    end
    durations.inject{|sum,x| sum + x } / durations.count
  end

  def build_details(job_name, build_number)
    hash = @client.job.get_build_details(job_name, build_number)

    details = {
      build_str: hash["id"],
      full_name: hash["fullDisplayName"],
      number: hash["number"],
      start_time: Time.at(hash["timestamp"]/1000).utc,
      elapsed_time: Time.now.utc - Time.at(hash["timestamp"]/1000).utc,
      duration: hash["duration"]/1000,
      building: hash["building"]
    }

    details[:result] = hash["building"] ? "RUNNING" : hash["result"]

    gr_count = cases_gr_count(job_name, build_number)
    details[:success_cases_count] = gr_count[1].to_i
    details[:failed_cases_count] = gr_count[2].to_i

    details
  end

  def cases_gr_count(job_name, build_number)

    output = @client.job.get_console_output(job_name, build_number)['output']

    scan = output.scan(/\[ TOTAL -(\d+)- PASSED -(\d+)- FAILED -(\d+)- \]/)[-1]

    return scan.nil? ? [0,0,0] : scan
  end


  def kick_build(job_name)
    build_opts = {
        'build_start_timeout' => 10
    }
    @client.job.unblock_build_when_upstream_building(job_name)
    @client.job.execute_concurrent_builds(job_name, true)
    build_id = @client.job.build(job_name, {job_name: job_name}, build_opts)

    build_id
  end

  private

  def seconds_in_hms(seconds)
    Time.at(seconds).utc.strftime("%H:%M:%S")
  end

  def find_latest_pattern(pattern)
    "*****RUNTIME STATUS******:  5/2"
  end
end
