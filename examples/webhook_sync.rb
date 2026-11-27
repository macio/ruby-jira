# frozen_string_literal: true

# Parses a Jira webhook delivery and prints a summary. Jira posts the delivery body
# to an HTTP endpoint you own; this script shows only the parsing step, so it can be
# run against a saved payload without a server.
#
# Usage:
#   bundle exec ruby examples/webhook_sync.rb path/to/payload.json
#   cat payload.json | bundle exec ruby examples/webhook_sync.rb
#
# In an HTTP handler, pass the raw request body to Jira::Webhook::Event.parse.

require "jira"

body = ARGV[0] ? File.read(ARGV[0]) : $stdin.read
event = Jira::Webhook::Event.parse(body)

if event.is_a?(Jira::Webhook::Event)
  puts "event:  #{event.webhook_event}"
  puts "issue:  #{event.issue[:key]} - #{event.issue.dig(:fields, :summary)}"
  puts "by:     #{event.user && event.user[:displayName]}"
  event.changelog&.dig(:items)&.each do |item|
    puts "change: #{item[:field]}: #{item[:fromString].inspect} -> #{item[:toString].inspect}"
  end
else
  puts "unsupported event, raw payload:"
  puts event.inspect
end
