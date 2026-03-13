# frozen_string_literal: true

require "spec_helper"

RSpec.describe Jira::PaginatedResponse do
  subject(:paginated_response) { described_class.new(hash) }

  let(:hash) do
    {
      isLast:     true,
      maxResults: 100,
      nextPage:   "https://jira.atlassian.net/rest/api/3/project/search",
      self:       "https://jira.atlassian.net/rest/api/3/project/search",
      startAt:    0,
      total:      1,
      values:     [1, 2, 3, 4]
    }
  end

  describe "initialization" do
    it "sets basic attributes", :aggregate_failures do
      expect(paginated_response.total).to eq(1)
      expect(paginated_response.max_results).to eq(100)
      expect(paginated_response.start_at).to eq(0)
      expect(paginated_response.to_ary).to eq([1, 2, 3, 4])
    end

    it "detects items from non-:values key", :aggregate_failures do
      response = described_class.new({ issues: [{ key: "ED-1" }], startAt: 0, maxResults: 50, total: 1 })
      expect(response.first[:key]).to eq("ED-1")
      expect(response.total).to eq(1)
    end

    it "computes isLast when not present in body", :aggregate_failures do
      # 1 item, startAt 0, total 1 → last page
      response = described_class.new({ issues: [1], startAt: 0, maxResults: 50, total: 1 })
      expect(response.last_page?).to be(true)

      # 1 item, startAt 0, total 2 → not last page
      response2 = described_class.new({ issues: [1], startAt: 0, maxResults: 1, total: 2 })
      expect(response2.last_page?).to be(false)
    end
  end

  describe "array-like behavior" do
    it "delegates array methods" do
      expect(paginated_response.map { |value| value * 2 }).to eq([2, 4, 6, 8])
      expect(paginated_response.select { |value| value > 2 }).to eq([3, 4])
    end
  end

  describe "pagination status methods" do
    it "returns first and last page status" do
      expect(paginated_response.first_page?).to be(true)
      expect(paginated_response.last_page?).to be(true)
      expect(paginated_response.next_page?).to be(false)
    end
  end

  describe "#each_page" do
    let(:first_hash) do
      { isLast: false, nextPage: "https://jira.atlassian.net/rest/api/3/project/search?startAt=4",
        total: 6, maxResults: 4, startAt: 0, values: [1, 2, 3, 4] }
    end
    let(:second_hash) { { isLast: true, total: 6, maxResults: 4, startAt: 4, values: [5, 6] } }
    let(:first_page) { described_class.new(first_hash) }
    let(:second_page) { described_class.new(second_hash) }
    let(:mock_client) { instance_double(Jira::Request, api_request_path: "/rest/api/3") }

    before do
      first_page.client = mock_client
      allow(mock_client).to receive(:get).and_return(second_page)
    end

    it "iterates through pages" do
      expect { |block| first_page.each_page(&block) }
        .to yield_successive_args(first_page, second_page)
    end
  end

  describe "#auto_paginate" do
    let(:first_hash) do
      { isLast: false, nextPage: "https://jira.atlassian.net/rest/api/3/project/search?startAt=4",
        total: 6, maxResults: 4, startAt: 0, values: [1, 2, 3, 4] }
    end
    let(:second_hash) { { isLast: true, total: 6, maxResults: 4, startAt: 4, values: [5, 6] } }
    let(:first_page) { described_class.new(first_hash) }
    let(:second_page) { described_class.new(second_hash) }
    let(:mock_client) { instance_double(Jira::Request, api_request_path: "/rest/api/3") }

    before do
      first_page.client = mock_client
      allow(mock_client).to receive(:get).and_return(second_page)
    end

    it "returns flattened array" do
      expect(first_page.auto_paginate).to contain_exactly(1, 2, 3, 4, 5, 6)
    end
  end

  describe "#paginate_with_limit" do
    let(:first_hash) do
      { isLast: false, nextPage: "https://jira.atlassian.net/rest/api/3/project/search?startAt=4",
        total: 6, maxResults: 4, startAt: 0, values: [1, 2, 3, 4] }
    end
    let(:second_hash) { { isLast: true, total: 6, maxResults: 4, startAt: 4, values: [5, 6] } }
    let(:first_page) { described_class.new(first_hash) }
    let(:second_page) { described_class.new(second_hash) }
    let(:mock_client) { instance_double(Jira::Request, api_request_path: "/rest/api/3") }

    before do
      first_page.client = mock_client
      allow(mock_client).to receive(:get).and_return(second_page)
    end

    it "returns a limited array" do
      expect(first_page.paginate_with_limit(3)).to contain_exactly(1, 2, 3)
    end
  end

  describe "fetcher-based pagination (startAt without nextPage URL)" do
    let(:first_hash) { { issues: [{ key: "ED-1" }], startAt: 0, maxResults: 1, total: 2 } }
    let(:second_hash) { { issues: [{ key: "ED-2" }], startAt: 1, maxResults: 1, total: 2 } }
    let(:first_page) { described_class.new(first_hash) }
    let(:second_page) { described_class.new(second_hash) }

    before do
      first_page.next_page_fetcher = ->(start_at) { start_at == 1 ? second_page : nil }
    end

    it "next_page? is true when not last page and fetcher is set" do
      expect(first_page.next_page?).to be(true)
    end

    it "next_page? is false when last page" do
      expect(second_page.next_page?).to be(false)
    end

    it "next_page calls fetcher with start_at + max_results" do
      expect(first_page.next_page).to eq(second_page)
    end

    it "auto_paginate collects all items" do
      all = first_page.auto_paginate
      expect(all.map { |i| i[:key] }).to eq(%w[ED-1 ED-2])
    end

    it "raises when fetcher returns a page without progress" do
      first_page.next_page_fetcher = ->(_start_at) { first_page }

      expect { first_page.auto_paginate }
        .to raise_error(Jira::Error::Pagination, /did not advance/)
    end
  end

  describe "#client_relative_path" do
    it "removes api base path from pagination link" do
      mock_client = instance_double(Jira::Request, api_request_path: "/rest/api/3")
      paginated_response.client = mock_client

      result = paginated_response.client_relative_path("https://jira.atlassian.net/rest/api/3/project/search?startAt=50")

      expect(result).to eq("/project/search?startAt=50")
    end
  end
end
