# frozen_string_literal: true

require "yaml"

module Jira
  module Configuration
    VALID_OPTIONS_KEYS = %i[
      endpoint
      user_agent
      httparty
      auth_type
      email
      api_token
      oauth_access_token
      oauth_client_id
      oauth_client_secret
      oauth_refresh_token
      oauth_grant_type
      oauth_token_endpoint
      cloud_id
      ratelimit_retries
      ratelimit_base_delay
      ratelimit_max_delay
      logger
    ].freeze

    DEFAULT_USER_AGENT = "Ruby Jira Gem #{Jira::VERSION}".freeze
    DEFAULT_AUTH_TYPE = :basic
    DEFAULT_RATELIMIT_RETRIES = 4
    DEFAULT_RATELIMIT_BASE_DELAY = 2.0
    DEFAULT_RATELIMIT_MAX_DELAY = 30.0
    DEFAULT_OAUTH_TOKEN_ENDPOINT = "https://auth.atlassian.com/oauth/token"

    attr_accessor(*VALID_OPTIONS_KEYS)

    def self.extended(base)
      base.reset
    end

    def configure
      yield self
    end

    def options
      VALID_OPTIONS_KEYS.to_h do |key|
        [key, send(key)]
      end
    end

    def reset # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      self.endpoint = ENV.fetch("JIRA_ENDPOINT", nil)
      self.auth_type = (ENV["JIRA_AUTH_TYPE"] || DEFAULT_AUTH_TYPE).to_sym
      self.email = ENV.fetch("JIRA_EMAIL", nil)
      self.api_token = ENV.fetch("JIRA_API_TOKEN", nil)
      self.oauth_access_token = ENV.fetch("JIRA_OAUTH_ACCESS_TOKEN", nil)
      self.oauth_client_id = ENV.fetch("JIRA_OAUTH_CLIENT_ID", nil)
      self.oauth_client_secret = ENV.fetch("JIRA_OAUTH_CLIENT_SECRET", nil)
      self.oauth_refresh_token = ENV.fetch("JIRA_OAUTH_REFRESH_TOKEN", nil)
      self.oauth_grant_type = ENV.fetch("JIRA_OAUTH_GRANT_TYPE", nil)
      self.oauth_token_endpoint = ENV.fetch("JIRA_OAUTH_TOKEN_ENDPOINT", DEFAULT_OAUTH_TOKEN_ENDPOINT)
      self.cloud_id = ENV.fetch("JIRA_CLOUD_ID", nil)
      self.ratelimit_retries = integer_env("JIRA_RATELIMIT_RETRIES", DEFAULT_RATELIMIT_RETRIES)
      self.ratelimit_base_delay = float_env("JIRA_RATELIMIT_BASE_DELAY", DEFAULT_RATELIMIT_BASE_DELAY)
      self.ratelimit_max_delay = float_env("JIRA_RATELIMIT_MAX_DELAY", DEFAULT_RATELIMIT_MAX_DELAY)
      self.httparty = get_httparty_config(ENV.fetch("JIRA_HTTPARTY_OPTIONS", nil))
      self.user_agent = DEFAULT_USER_AGENT
      self.logger = nil
    end

    private

    def get_httparty_config(options)
      return nil if options.nil? || options.empty?

      config = YAML.safe_load(options, permitted_classes: [Symbol], aliases: false)
      raise ArgumentError, "HTTParty config should be a Hash." unless config.is_a?(Hash)

      symbolize_keys(config)
    end

    def symbolize_keys(value)
      return value unless value.is_a?(Hash)

      value.each_with_object({}) do |(key, nested_value), output|
        output[key.to_sym] = nested_value.is_a?(Hash) ? symbolize_keys(nested_value) : nested_value
      end
    end

    def integer_env(key, default)
      value = ENV.fetch(key, nil)
      value ? Integer(value, 10) : default
    rescue ArgumentError
      default
    end

    def float_env(key, default)
      value = ENV.fetch(key, nil)
      value ? Float(value) : default
    rescue ArgumentError
      default
    end
  end
end
