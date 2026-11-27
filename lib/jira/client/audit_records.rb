# frozen_string_literal: true

module Jira
  class Client
    # Defines read-only methods for the audit log.
    #
    # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-audit-records/
    module AuditRecords
      # Returns audit records. The entries are under the `records` key.
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-audit-records/#api-rest-api-3-auditing-record-get
      #
      # @param options [Hash] Query parameters (e.g. :from, :to, :filter, :offset, :limit)
      # @return [Hash]
      def audit_records(options = {})
        get("/auditing/record", query: options)
      end
    end
  end
end
