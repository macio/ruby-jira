# frozen_string_literal: true

require "spec_helper"

RSpec.describe Jira::CursorPaginatedResponse do
  subject(:response) { described_class.new(body) }

  let(:body) do
    {
      nextPageToken: "token-abc",
      total:         50,
      issues:        [
        { id: "1", key: "TEST-1" },
        { id: "2", key: "TEST-2" }
      ]
    }
  end

  describe "initialization" do
    it "exposes next_page_token and total" do
      expect(response.next_page_token).to eq("token-abc")
      expect(response.total).to eq(50)
    end

    it "detects the items array (issues)" do
      expect(response.to_ary.length).to eq(2)
    end

    it "wraps hash items in ObjectifiedHash" do
      expect(response.first).to be_a(Jira::ObjectifiedHash)
      expect(response.first.key).to eq("TEST-1")
    end
  end

  describe "array delegation" do
    it "delegates enumerable methods to items" do
      expect(response.map(&:key)).to eq(%w[TEST-1 TEST-2])
    end
  end

  describe "pagination status" do
    it "reports next page when token is present" do
      expect(response.next_page?).to be(true)
      expect(response.has_next_page?).to be(true)
    end

    it "reports no next page when token is absent" do
      r = described_class.new({ nextPageToken: nil, issues: [] })
      expect(r.next_page?).to be(false)
    end
  end

  describe "#next_page" do
    it "raises when fetcher is not set" do
      expect { response.next_page }.to raise_error(Jira::Error::MissingCredentials, /next_page_fetcher/)
    end

    it "calls the fetcher with the token" do
      fetcher = instance_double(Proc)
      allow(fetcher).to receive(:call).with("token-abc").and_return(:next_page_result)
      response.next_page_fetcher = fetcher

      expect(response.next_page).to eq(:next_page_result)
    end
  end

  describe "#each_page" do
    it "iterates through pages using the fetcher" do
      second_page = described_class.new({ nextPageToken: nil, issues: [{ id: "3", key: "TEST-3" }] })
      response.next_page_fetcher = ->(_token) { second_page }

      pages = []
      response.each_page { |page| pages << page }

      expect(pages).to eq([response, second_page])
    end
  end

  describe "#auto_paginate" do
    it "collects all items across pages" do
      second_page = described_class.new({ nextPageToken: nil, issues: [{ id: "3", key: "TEST-3" }] })
      response.next_page_fetcher = ->(_token) { second_page }

      all = response.auto_paginate
      expect(all.length).to eq(3)
      expect(all.last.key).to eq("TEST-3")
    end

    it "raises when cursor does not advance" do
      repeated_page = described_class.new({ nextPageToken: "token-abc", issues: [{ id: "3", key: "TEST-3" }] })
      response.next_page_fetcher = ->(_token) { repeated_page }

      expect { response.auto_paginate }
        .to raise_error(Jira::Error::Pagination, /did not advance/)
    end
  end

  describe "body with no array field" do
    it "defaults items to empty array" do
      r = described_class.new({ nextPageToken: "x", total: 0 })
      expect(r.to_ary).to eq([])
    end
  end

  describe "url-based cursor pagination" do
    it "uses client with nextPage URL" do
      page = described_class.new(
        {
          lastPage: false,
          nextPage: "https://jira.atlassian.net/rest/api/3/worklog/deleted?since=10",
          values:   [{ id: "1" }]
        }
      )
      next_page = described_class.new({ lastPage: true, values: [] })
      client = instance_double(Jira::Request, api_request_path: "/rest/api/3")
      page.client = client
      allow(client).to receive(:get).and_return(next_page)

      expect(page.next_page).to eq(next_page)
      expect(client).to have_received(:get).with("/worklog/deleted?since=10")
    end
  end
end
