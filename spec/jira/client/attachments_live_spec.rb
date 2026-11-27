# frozen_string_literal: true

require "live_helper"
require "tempfile"

RSpec.describe Jira::Client do
  let(:scope) { Jira::Live::RunScope.new(project: Jira::Live::PROJECT_KEY) }
  let(:content) { "ruby-jira live attachment\n" }
  let(:file) do
    Tempfile.new(["ruby-jira-live", ".txt"]).tap do |f|
      f.write(content)
      f.flush
    end
  end

  after do
    file.close!
    scope.cleanup!
  end

  it "uploads, reads, downloads and deletes an attachment", :aggregate_failures do
    key = scope.create_issue("attachment")

    uploaded = record_fixture("add_attachment") { Jira.add_attachment(key, file.path) }
    id = uploaded.first[:id]
    scope.on_cleanup("attachment #{id}") { Jira.delete_attachment(id) }
    metadata = record_fixture("attachment") { Jira.attachment(id) }

    expect(uploaded.first[:filename]).to eq(File.basename(file.path))
    expect(metadata[:size]).to eq(content.bytesize)
    expect(Jira.attachment_content(id)).to eq(content)

    Jira.delete_attachment(id)
    expect { Jira.attachment(id) }.to raise_error(Jira::Error::NotFound)
  end
end
