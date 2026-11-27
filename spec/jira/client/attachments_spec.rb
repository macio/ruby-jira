# frozen_string_literal: true

require "spec_helper"
require "tempfile"

RSpec.describe Jira::Client do
  let(:content_url) { "#{Jira.endpoint}/rest/api/3/attachment/content/10001" }

  describe ".add_attachment" do
    let(:file) do
      Tempfile.new(["screenshot", ".png"]).tap do |f|
        f.binmode
        f.write("PNGDATA")
        f.flush
      end
    end

    after { file.close! }

    it "uploads the file as multipart with the XSRF bypass header", :aggregate_failures do
      stub_request(:post, "#{Jira.endpoint}/rest/api/3/issue/ED-1/attachments")
        .with(headers: {
          "Authorization" => basic_authorization_value,
          "X-Atlassian-Token" => "no-check"
        }
             ) { |req| req.headers["Content-Type"].start_with?("multipart/form-data") }
        .to_return(body: load_fixture("add_attachment.json"), status: 200)

      result = Jira.add_attachment("ED-1", file.path)

      expect(a_request(:post, "#{Jira.endpoint}/rest/api/3/issue/ED-1/attachments")).to have_been_made
      expect(result).to be_an(Array)
      expect(result.first[:filename]).to eq("screenshot.png")
    end
  end

  describe ".attachment" do
    it "returns attachment metadata" do
      stub_get("/attachment/10001", "attachment.json")

      expect(Jira.attachment(10_001)[:mimeType]).to eq("image/png")
    end
  end

  describe ".attachment_content" do
    it "returns the raw binary body without JSON parsing" do
      stub_request(:get, content_url)
        .with(headers: { "Authorization" => basic_authorization_value })
        .to_return(body: "\x89PNG\r\n".b, status: 200)

      expect(Jira.attachment_content(10_001)).to eq("\x89PNG\r\n".b)
    end
  end

  describe ".delete_attachment" do
    it "deletes an attachment" do
      stub_request(:delete, "#{Jira.endpoint}/rest/api/3/attachment/10001")
        .with(headers: { "Authorization" => basic_authorization_value })
        .to_return(status: 204, body: "")

      Jira.delete_attachment(10_001)

      expect(a_request(:delete, "#{Jira.endpoint}/rest/api/3/attachment/10001")).to have_been_made
    end
  end
end
