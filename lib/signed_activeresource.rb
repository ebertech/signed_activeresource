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

    def request(method, path, *arguments)
      result = ActiveSupport::Notifications.instrument("request.active_resource") do |payload|
        payload[:method] = method
        payload[:request_uri] = "#{site.scheme}://#{site.host}:#{site.port}#{path}"

        if arguments.size > 1
          data = arguments.shift
        end
        initheader = arguments.shift

        request = "Net::HTTP::#{method.to_s.titleize}".constantize.new(path, initheader)
        request_signer.sign!(request) if request_signer

        payload[:result] = http.request request, data
      end
      handle_response(result)
    rescue Timeout::Error => e
      raise TimeoutError.new(e.message)
    rescue OpenSSL::SSL::SSLError => e
      raise SSLError.new(e.message)
    end
  end
end