# frozen_string_literal: true

# Copies all attachments from one issue to another. Downloads each file to a temporary
# directory and uploads it to the target issue. The source attachments are not changed.
#
# Requires permission to view the source issue and to create attachments on the target.
#
# Basic auth:
#   JIRA_ENDPOINT=https://your-domain.atlassian.net \
#   JIRA_EMAIL=you@example.com \
#   JIRA_API_TOKEN=your-api-token \
#   bundle exec ruby examples/attachments_migrate.rb SOURCE-1 TARGET-1

require "jira"
require "tmpdir"

source_key, target_key = ARGV
abort "usage: #{$PROGRAM_NAME} SOURCE_KEY TARGET_KEY" if source_key.nil? || target_key.nil?

attachments = Jira.issue(source_key, fields: "attachment").dig(:fields, :attachment) || []
puts "#{attachments.size} attachment(s) on #{source_key}"

Dir.mktmpdir("jira-attachments") do |dir|
  attachments.each do |attachment|
    content = Jira.attachment_content(attachment[:id])
    path = File.join(dir, attachment[:filename])
    File.binwrite(path, content)
    Jira.add_attachment(target_key, path)
    puts "copied #{attachment[:filename]} (#{content.bytesize} bytes)"
  end
end
