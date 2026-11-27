# frozen_string_literal: true

module Jira
  class Client < API
    Dir[File.expand_path("client/*.rb", __dir__)].each { |file| require file }

    include AgileIssues
    include Boards
    include Epics
    include IssueComments
    include IssueSearch
    include Issues
    include IssueWorklogs
    include ProjectCategories
    include ProjectPermissionSchemes
    include ProjectProperties
    include Projects
    include Sprints
    include TimeTracking

    # Text representation of the client, masking auth secrets.
    #
    # @return [String]
    def inspect
      inspected = super
      inspected = redact_secret(inspected, :api_token, @api_token) if @api_token
      inspected = redact_secret(inspected, :oauth_access_token, @oauth_access_token) if @oauth_access_token
      inspected = redact_secret(inspected, :oauth_client_secret, @oauth_client_secret) if @oauth_client_secret
      inspected = redact_secret(inspected, :oauth_refresh_token, @oauth_refresh_token) if @oauth_refresh_token
      inspected
    end

    # Utility method for URL encoding of a string.
    #
    # @return [String]
    def url_encode(url)
      url.to_s.b.gsub(/[^a-zA-Z0-9_\-.~]/n) { |match| format("%%%02X", match.unpack1("C")) }
    end

    private

    def redact_secret(inspected, key, secret)
      redacted = only_show_last_four_chars(secret)
      inspected.sub %(@#{key}="#{secret}"), %(@#{key}="#{redacted}")
    end

    def only_show_last_four_chars(token)
      return "****" if token.size <= 4

      "#{"*" * (token.size - 4)}#{token[-4..]}"
    end
  end
end
