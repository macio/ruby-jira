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

  describe "#client_relative_path" do
    it "removes api base path from pagination link" do
      mock_client = instance_double(Jira::Request, api_request_path: "/rest/api/3")
      paginated_response.client = mock_client

      result = paginated_response.client_relative_path("https://jira.atlassian.net/rest/api/3/project/search?startAt=50")

      expect(result).to eq("/project/search?startAt=50")
    end
  end
end
