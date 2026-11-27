# frozen_string_literal: true

module Jira
  # @private
  class API < Request
    attr_accessor(*Configuration::VALID_OPTIONS_KEYS)

    # Creates a new API.
    # @raise [Jira::Error::MissingCredentials]
    def initialize(options = {}) # rubocop:disable Lint/MissingSuper
      options = Jira.options.merge(options)
      Configuration::VALID_OPTIONS_KEYS.each do |key|
        send("#{key}=", options[key]) if options.key?(key)
      end

      request_defaults
      self.class.headers "User-Agent" => user_agent
    end
  end
end
