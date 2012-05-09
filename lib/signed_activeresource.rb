require 'active_support/core_ext/string/inflections'
require 'active_resource'

module SignedActiveResource
  class Base < ActiveResource::Base
    cattr_accessor :request_signer

    def self.connection(refresh = false)
      @connection = Connection.new(site, format) if @connection.nil? || refresh
      @connection.request_signer = request_signer
      @connection.timeout = timeout if timeout
      return @connection
    end
  end

  class Connection < ActiveResource::Connection
    attr_accessor :request_signer

    def logger
      @logger ||= Logger.new(STDOUT)
    end

    private
    # Makes request to remote service.
    def request(method, path, *arguments)
      logger.info "#{method.to_s.upcase} #{site.scheme}://#{site.host}:#{site.port}#{path}" if logger
      result = nil
      ms = Benchmark.ms {
        data = arguments.shift
        request = "Net::HTTP::#{method.to_s.titleize}".constantize.new(path, arguments.first)
        res = nil

        request_signer.sign!(request) if request_signer

        result = http.request request, data
      }
      logger.info "--> %d %s (%d %.0fms)" % [result.code, result.message, result.body ? result.body.length : 0, ms] if logger
      handle_response(result)
    rescue Timeout::Error => e
      raise TimeoutError.new(e.message)
    rescue OpenSSL::SSL::SSLError => e
      raise SSLError.new(e.message)
    end
  end
end