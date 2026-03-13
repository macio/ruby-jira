# frozen_string_literal: true

module Jira
  # Provides a #log helper that delegates to the configured logger.
  # Mixed into Request and pagination classes to emit debug information.
  #
  # @example Enable logging
  #   require "logger"
  #   Jira.configure { |c| c.logger = Logger.new($stdout) }
  module Logging
    def log(message)
      Jira.logger&.debug("[ruby-jira] #{message}")
    end
  end
end
