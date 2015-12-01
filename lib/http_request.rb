require 'faraday'
require 'typhoeus/adapters/faraday'

module Http
  class Request
    # params hash takes: :method, :url, :headers, :params, :body
    def self.request(opts)
      conn = Faraday.new(url: opts[:url]) do |faraday|
        faraday.adapter :excon
      end
      begin
        conn.headers = opts[:headers] if opts[:headers]
        conn.params = opts[:params] if opts[:params]
        if not opts[:body].nil?
          if opts[:headers].nil? || opts[:headers]['Content-Type'].nil?
            body = URI::encode_www_form opts[:body]
          elsif opts[:headers]['Content-Type'].eql? 'application/json'
            body = opts[:body].to_json
          elsif opts[:headers]['Content-Type'].include? 'multipart/form-data'
            body = opts[:body]
          else
            body = URI::encode_www_form opts[:body]
          end
          body.force_encoding("utf-8")
        end
        response = conn.send opts[:method], opts[:url], body do |request|
          request.options[:timeout] = 60
          request.options[:open_timeout] = 60
        end
      rescue Faraday::Error::ClientError
        response = Faraday::Response.new(status: 0)
      end
      response
    end
  end
end