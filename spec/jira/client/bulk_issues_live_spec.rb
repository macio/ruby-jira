# frozen_string_literal: true

require "live_helper"

RSpec.describe Jira::Client do
  let(:final_statuses) { %w[COMPLETE FAILED CANCELLED DEAD] }
  let(:scope) { Jira::Live::RunScope.new(project: Jira::Live::PROJECT_KEY) }

  after { scope.cleanup! }

  # The gem has no method for the bulk queue, so the task is polled through the raw client.
  def wait_for_bulk_task(task_id, timeout: 60)
    deadline = Time.now + timeout
    loop do
      task = Jira.client.get("/bulk/queue/#{task_id}")
      return task if final_statuses.include?(task[:status])
      raise "Bulk task #{task_id} still #{task[:status]} after #{timeout}s" if Time.now > deadline

      Kernel.sleep(2)
    end
  end

  describe ".bulk_delete_issues" do
    it "submits a task that deletes the issues", :aggregate_failures do
      keys = [scope.create_issue("bulk delete 1"), scope.create_issue("bulk delete 2")]

      result = record_fixture("bulk_delete_issues") { Jira.bulk_delete_issues(keys) }
      task = wait_for_bulk_task(result[:taskId])

      expect(result[:taskId]).to be_a(String)
      expect(task[:status]).to eq("COMPLETE")
      keys.each { |key| expect { Jira.issue(key) }.to raise_error(Jira::Error::NotFound) }
    end
  end
end
