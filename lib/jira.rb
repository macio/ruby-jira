# frozen_string_literal: true

require_relative "jira/version"
require_relative "jira/configuration"
require_relative "jira/logging"
require_relative "jira/error"
require_relative "jira/objectified_hash"
require_relative "jira/pagination/collection_behavior"
require_relative "jira/pagination/paginated_response"
require_relative "jira/pagination/cursor_paginated_response"
require_relative "jira/request"
require_relative "jira/api"
require_relative "jira/client"

module Jira
  extend Configuration

  # Alias for Jira::Client.new
  #
  # @return [Jira::Client]
  def self.client(options = {})
    Jira::Client.new(options)
  end

  def self.method_missing(method, ...)
    return super unless client.respond_to?(method)

    client.send(method, ...)
  end

  def self.respond_to_missing?(method_name, include_private = false)
    client.respond_to?(method_name) || super
  end

  # Delegate to HTTParty.http_proxy
  def self.http_proxy(address = nil, port = nil, username = nil, password = nil) # rubocop:disable Metrics/ParameterLists
    Jira::Request.http_proxy(address, port, username, password)
  end

  # Returns an unsorted array of available client methods.
  #
  # @return [Array<Symbol>]
  def self.actions # rubocop:disable Metrics/MethodLength
    hidden = Regexp.union(
      /endpoint/,
      /auth_type/,
      /email/,
      /api_token/,
      /oauth_access_token/,
      /oauth_client_id/,
      /oauth_client_secret/,
      /oauth_refresh_token/,
      /oauth_grant_type/,
      /oauth_token_endpoint/,
      /cloud_id/,
      /user_agent/,
      /get/,
      /post/,
      /put/,
      /patch/,
      /\Adelete\z/,
      /validate\z/,
      /httparty/
    )
    (Jira::Client.instance_methods - Object.methods).reject { |method_name| method_name[hidden] }
  end
end
