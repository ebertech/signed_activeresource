require 'active_support/core_ext/string/inflections'
require 'active_resource'

module SignedActiveResource
  class SignedRequestHandler
    def initialize(request_signer = nil, object_instance = nil)
      @request_signer = request_signer
      @object_instance = object_instance
    end

    def handle_request(http, method, path, *arguments)
      request = build_request(method, path, *arguments)
      @request_signer.sign!(request) if @request_signer

      http.request request
    end

    def build_request(method, path, *arguments)
      if arguments.size > 1
        data = arguments.shift
      end
      init_header = arguments.shift

      "Net::HTTP::#{method.to_s.titleize}".constantize.new(path, init_header).tap do |request|
        request.body = data
      end
    end
  end

  class Base < ActiveResource::Base
    def self.connection(refresh = false)
      @connection = Connection.new(site, format) if @connection.nil? || refresh
      @connection.request_handler = request_handler
      @connection.timeout = timeout if timeout
      return @connection
    end

    def self.request_handler(object_instance = nil)
      SignedRequestHandler.new(request_signature, object_instance)
    end

    protected

    def connection(refresh = false)
      self.class.connection(refresh).tap do |c|
        c.request_handler = request_handler
      end
    end

    def request_handler
      self.class.request_handler(self)
    end
  end

  class Connection < ActiveResource::Connection
    attr_accessor :request_handler

    def logger
      @logger ||= Logger.new(STDOUT)
    end

    private

    def request(method, path, *arguments)
      result = ActiveSupport::Notifications.instrument("request.active_resource") do |payload|
        payload[:method] = method
        payload[:request_uri] = "#{site.scheme}://#{site.host}:#{site.port}#{path}"
        payload[:result] = request_handler.handle_request http, method, path, *arguments
      end
      handle_response(result)
    rescue Timeout::Error => e
      raise TimeoutError.new(e.message)
    rescue OpenSSL::SSL::SSLError => e
      raise SSLError.new(e.message)
    end
  end
end