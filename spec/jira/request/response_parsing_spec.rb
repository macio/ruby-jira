# frozen_string_literal: true

require "spec_helper"

RSpec.describe Jira::Request::ResponseParser do
  describe ".parse" do
    it "returns PaginatedResponse for page bean payload" do
      body = JSON.generate(startAt: 0, maxResults: 2, total: 10, isLast: false, values: [{ id: "1" }])

      parsed = described_class.parse(body)

      expect(parsed).to be_a(Jira::PaginatedResponse)
      expect(parsed.first[:id]).to eq("1")
    end

    it "returns PaginatedResponse for legacy offset payload" do
      body = JSON.generate(startAt: 0, maxResults: 2, total: 10, comments: [{ id: "1" }])

      parsed = described_class.parse(body)

      expect(parsed).to be_a(Jira::PaginatedResponse)
      expect(parsed.first[:id]).to eq("1")
    end

    it "returns CursorPaginatedResponse for nextPageToken payload" do
      body = JSON.generate(nextPageToken: "token-123", isLast: false, issues: [{ id: "1" }])

      parsed = described_class.parse(body)

      expect(parsed).to be_a(Jira::CursorPaginatedResponse)
      expect(parsed.next_page_token).to eq("token-123")
    end

    it "returns CursorPaginatedResponse for token pagination last page without token" do
      body = JSON.generate(isLast: true, issues: [{ id: "1" }])

      parsed = described_class.parse(body)

      expect(parsed).to be_a(Jira::CursorPaginatedResponse)
      expect(parsed.next_page?).to be(false)
    end

    it "returns CursorPaginatedResponse for nextPageCursor payload" do
      body = JSON.generate(nextPageCursor: "cursor-123", cursor: "cursor-123", last: false, values: [{ id: "1" }])

      parsed = described_class.parse(body)

      expect(parsed).to be_a(Jira::CursorPaginatedResponse)
      expect(parsed.next_page_cursor).to eq("cursor-123")
    end

    it "returns CursorPaginatedResponse for worklog/deleted URL-based payload" do
      body = JSON.generate(
        lastPage: false,
        nextPage: "https://jira.atlassian.net/rest/api/3/worklog/deleted?since=12345",
        values:   [{ id: "1" }],
        since:    12_345,
        until:    12_346
      )

      parsed = described_class.parse(body)

      expect(parsed).to be_a(Jira::CursorPaginatedResponse)
      expect(parsed.next_page_url).to include("/worklog/deleted")
      expect(parsed.fetcher_based_pagination?).to be(false)
    end

    it "returns ObjectifiedHash for non-paginated object payload" do
      body = JSON.generate(id: "1000", key: "TEST-1")

      parsed = described_class.parse(body)

      expect(parsed).to be_a(Jira::ObjectifiedHash)
      expect(parsed.key).to eq("TEST-1")
    end
  end
end
