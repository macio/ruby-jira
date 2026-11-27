# frozen_string_literal: true

module Jira
  class Client
    # Defines methods related to issue attachments.
    #
    # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issue-attachments/
    module Attachments
      # Uploads a file as an attachment to an issue
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issue-attachments/#api-rest-api-3-issue-issueidorkey-attachments-post
      #
      # @param issue_id_or_key [Integer, String] The ID or key of the issue
      # @param file_path [String] Path to the local file to upload
      # @return [Array<Hash>]
      def add_attachment(issue_id_or_key, file_path)
        File.open(file_path, "rb") do |file|
          post(
            "/issue/#{url_encode(issue_id_or_key)}/attachments",
            body:      { file: file },
            multipart: true,
            headers:   { "X-Atlassian-Token" => "no-check" }
          )
        end
      end

      # Returns the metadata of an attachment
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issue-attachments/#api-rest-api-3-attachment-id-get
      #
      # @param id [Integer, String] The ID of the attachment
      # @return [Hash]
      def attachment(id)
        get("/attachment/#{url_encode(id)}")
      end

      # Downloads the content of an attachment
      #
      # The body is returned as raw bytes, not parsed as JSON.
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issue-attachments/#api-rest-api-3-attachment-content-id-get
      #
      # @param id [Integer, String] The ID of the attachment
      # @return [String] Binary content
      def attachment_content(id)
        get("/attachment/content/#{url_encode(id)}", parser: ->(body, _format) { body })
      end

      # Deletes an attachment
      #
      # @url https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issue-attachments/#api-rest-api-3-attachment-id-delete
      #
      # @param id [Integer, String] The ID of the attachment
      # @return [Hash]
      def delete_attachment(id)
        delete("/attachment/#{url_encode(id)}")
      end
    end
  end
end
