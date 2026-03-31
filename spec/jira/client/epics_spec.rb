# frozen_string_literal: true

RSpec.describe Jira::Client::Epics do
  describe ".issues_without_epic" do
    it "returns paginated issues that have no epic", :aggregate_failures do
      stub_agile_get("/epic/none/issue", "board_issues")

      result = Jira.issues_without_epic

      expect(a_agile_get("/epic/none/issue")).to have_been_made
      expect(result).to be_a(Jira::PaginatedResponse)
      expect(result.total).to eq(1)
      expect(result.first[:key]).to eq("HSP-1")
    end

    it "passes query options" do
      stub_agile_get("/epic/none/issue?maxResults=10", "board_issues")
      Jira.issues_without_epic(maxResults: 10)
      expect(a_agile_get("/epic/none/issue?maxResults=10")).to have_been_made
    end
  end

  describe ".unassign_issues_from_epic" do
    it "removes issues from their epic", :aggregate_failures do
      stub_agile_post("/epic/none/issue", "empty", status_code: 204)

      Jira.unassign_issues_from_epic(issues: %w[TEST-1 TEST-2])

      expect(a_agile_post("/epic/none/issue")).to have_been_made
    end
  end

  describe ".epic" do
    it "returns a single epic", :aggregate_failures do
      stub_agile_get("/epic/37", "epic")

      result = Jira.epic(37)

      expect(a_agile_get("/epic/37")).to have_been_made
      expect(result[:id]).to eq(37)
      expect(result[:name]).to eq("epic 1")
      expect(result[:summary]).to eq("epic 1 summary")
    end

    it "accepts a string key" do
      stub_agile_get("/epic/TEST-1", "epic")
      Jira.epic("TEST-1")
      expect(a_agile_get("/epic/TEST-1")).to have_been_made
    end
  end

  describe ".update_epic" do
    it "partially updates an epic", :aggregate_failures do
      stub_agile_post("/epic/37", "epic")

      result = Jira.update_epic(37, { name: "epic 1 updated" })

      expect(a_agile_post("/epic/37")).to have_been_made
      expect(result[:id]).to eq(37)
    end
  end

  describe ".epic_issues" do
    it "returns paginated issues for an epic", :aggregate_failures do
      stub_agile_get("/epic/37/issue", "epic_issues")

      result = Jira.epic_issues(37)

      expect(a_agile_get("/epic/37/issue")).to have_been_made
      expect(result).to be_a(Jira::PaginatedResponse)
      expect(result.total).to eq(1)
      expect(result.first[:key]).to eq("HSP-1")
    end

    it "passes query options" do
      stub_agile_get("/epic/37/issue?maxResults=25", "epic_issues")
      Jira.epic_issues(37, maxResults: 25)
      expect(a_agile_get("/epic/37/issue?maxResults=25")).to have_been_made
    end
  end

  describe ".move_issues_to_epic" do
    it "moves issues to the epic", :aggregate_failures do
      stub_agile_post("/epic/37/issue", "empty", status_code: 204)

      Jira.move_issues_to_epic(37, issues: %w[TEST-1 TEST-2])

      expect(a_agile_post("/epic/37/issue")).to have_been_made
    end
  end

  describe ".rank_epic" do
    it "ranks the epic before another epic", :aggregate_failures do
      stub_agile_put("/epic/37/rank", "empty", status_code: 204)

      Jira.rank_epic(37, { rankBeforeEpic: 42 })

      expect(a_agile_put("/epic/37/rank")).to have_been_made
    end
  end
end
