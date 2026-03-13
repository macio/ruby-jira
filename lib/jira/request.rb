# frozen_string_literal: true

require "base64"
require "httparty"
require "json"
require "time"
require "uri"

require_relative "logging"
require_relative "request/authentication"
require_relative "request/rate_limiting"
require_relative "request/request_building"
require_relative "request/response_parsing"

module Jira
  # @private
  class Request
    include HTTParty
    include Logging

    OAUTH_MISSING_CREDENTIALS_MESSAGE = Authenticator::OAUTH_MISSING_CREDENTIALS_MESSAGE

    format :json
    maintain_method_across_redirects true
    headers "Accept" => "application/json", "Content-Type" => "application/json"
    parser(proc { |body, _| parse(body) })

    attr_accessor :endpoint,
      :auth_type,
      :email,
      :api_token,
      :oauth_access_token,
      :oauth_client_id,
      :oauth_client_secret,
      :oauth_refresh_token,
      :oauth_grant_type,
      :oauth_token_endpoint,
      :oauth_access_token_expires_at,
      :cloud_id,
      :httparty,
      :ratelimit_retries,
      :ratelimit_base_delay,
      :ratelimit_max_delay

    class << self
      def parse(body)
        ResponseParser.parse(body)
      end

      def decode(response)
        ResponseParser.decode(response)
      end
    end

    %w[get post put patch delete].each do |method|
      define_method(method) do |path, options = {}|
        execute_request(method, path, options)
      end
    end

    def validate(response)
      error_klass = Error.klass(response)
      raise error_klass, response if error_klass

      parsed = response.parsed_response
      parsed.client = self if parsed.respond_to?(:client=)
      parsed
    end

    def request_defaults
      validate_endpoint!
      authenticator.validate!
    end

    def api_request_path
      url_builder.api_request_path
    end

    private

    def execute_request(method, path, options)
      params = params_builder.build(options)
      retries_left = retries_left_for(params)
      log "#{method.upcase} #{path} #{options.inspect}"
      result = perform_request_with_retry(method, path, params, retries_left)
      log "→ #{result.class}"
      setup_pagination_fetcher!(result, method, path, options)
      result
    end

    def perform_request_with_retry(method, path, params, retries_left)
      response = perform_request(method, path, params)
      validate(response)
    rescue Jira::Error::TooManyRequests, Jira::Error::ServiceUnavailable => e
      raise e unless should_retry?(e, method, response, retries_left)

      wait = retry_policy.wait_seconds(response: response, retries_left: retries_left - 1)
      log "rate limited (HTTP #{response.code}), retrying in #{wait.round(1)}s (#{retries_left - 1} retries left)"
      retry_policy.sleep_before_retry(response: response, retries_left: retries_left - 1)
      retries_left -= 1
      retry
    end

    def setup_pagination_fetcher!(result, method, path, options)
      case result
      when PaginatedResponse
        setup_fetcher_for(result:, method:, path:, options:, key: :startAt)
      when CursorPaginatedResponse
        return unless result.fetcher_based_pagination?
        return if result.cursor_parameter_key.nil?

        setup_fetcher_for(result:, method:, path:, options:, key: result.cursor_parameter_key)
      end
    end

    def setup_fetcher_for(result:, method:, path:, options:, key:)
      result.next_page_fetcher = lambda do |value|
        merged = duplicate_request_options(options)
        inject_pagination_parameter!(options: merged, method:, key:, value:)
        send(method, path, merged)
      end
    end

    def duplicate_request_options(options)
      duplicated = options.dup
      duplicated[:query] = options[:query].dup if options[:query].is_a?(Hash)
      duplicated[:body] = options[:body].dup if options[:body].is_a?(Hash)
      duplicated
    end

    def inject_pagination_parameter!(options:, method:, key:, value:)
      target = pagination_parameter_target(method:, options:)
      options[target] = (options[target] || {}).merge(key => value)
    end

    def pagination_parameter_target(method:, options:)
      return :query if method.to_s == "get"
      return :body if options[:body].is_a?(Hash)

      :query
    end

    def perform_request(method, path, params)
      self.class.send(method, build_url(path), params)
    end

    def retries_left_for(params)
      params.delete(:ratelimit_retries) || ratelimit_retries || Configuration::DEFAULT_RATELIMIT_RETRIES
    end

    def build_url(path) = url_builder.build(path)

    def authorization_header = authenticator.authorization_header

    def should_retry?(error, method, response, retries_left)
      retry_policy.retryable?(error: error, method: method, response: response, retries_left: retries_left)
    end

    def validate_endpoint!
      return unless endpoint.to_s.strip.empty?

      raise Error::MissingCredentials, "Please set an endpoint to API"
    end

    def authenticator
      @authenticator ||= Authenticator.new(request: self)
    end

    def retry_policy
      @retry_policy ||= RetryPolicy.new(request: self)
    end

    def params_builder
      @params_builder ||= ParamsBuilder.new(request: self, authenticator: authenticator)
    end

    def url_builder
      @url_builder ||= UrlBuilder.new(request: self, authenticator: authenticator)
    end
  end
end
