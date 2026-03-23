# frozen_string_literal: true

RSpec.describe Jira::Client::Boards do
  describe ".boards" do
    it "returns paginated boards", :aggregate_failures do
      stub_agile_get("/board", "boards")

      result = Jira.boards

      expect(a_agile_get("/board")).to have_been_made
      expect(result).to be_a(Jira::PaginatedResponse)
      expect(result.total).to eq(5)
      expect(result.first[:id]).to eq(84)
      expect(result.first[:name]).to eq("scrum board")
    end

    it "passes query options" do
      stub_agile_get("/board?type=scrum", "boards")
      Jira.boards(type: "scrum")
      expect(a_agile_get("/board?type=scrum")).to have_been_made
    end
  end

  describe ".create_board" do
    it "creates a board", :aggregate_failures do
      stub_agile_post("/board", "board")

      result = Jira.create_board({ name: "scrum board", type: "scrum", filterId: 1 })

      expect(a_agile_post("/board")).to have_been_made
      expect(result[:id]).to eq(84)
      expect(result[:name]).to eq("scrum board")
    end
  end

  describe ".boards_for_filter" do
    it "returns paginated boards for a filter", :aggregate_failures do
      stub_agile_get("/board/filter/1001", "boards")

      result = Jira.boards_for_filter(1001)

      expect(a_agile_get("/board/filter/1001")).to have_been_made
      expect(result).to be_a(Jira::PaginatedResponse)
      expect(result.total).to eq(5)
    end

    it "passes query options" do
      stub_agile_get("/board/filter/1001?maxResults=10", "boards")
      Jira.boards_for_filter(1001, maxResults: 10)
      expect(a_agile_get("/board/filter/1001?maxResults=10")).to have_been_made
    end
  end

  describe ".board" do
    it "returns a single board", :aggregate_failures do
      stub_agile_get("/board/84", "board")

      result = Jira.board(84)

      expect(a_agile_get("/board/84")).to have_been_made
      expect(result[:id]).to eq(84)
      expect(result[:name]).to eq("scrum board")
      expect(result[:type]).to eq("scrum")
    end
  end

  describe ".delete_board" do
    it "deletes the board", :aggregate_failures do
      stub_agile_delete("/board/84", "empty", status_code: 204)

      Jira.delete_board(84)

      expect(a_agile_delete("/board/84")).to have_been_made
    end
  end

  describe ".board_backlog" do
    it "returns paginated backlog issues", :aggregate_failures do
      stub_agile_get("/board/84/backlog", "board_backlog")

      result = Jira.board_backlog(84)

      expect(a_agile_get("/board/84/backlog")).to have_been_made
      expect(result).to be_a(Jira::PaginatedResponse)
      expect(result.total).to eq(1)
      expect(result.first[:key]).to eq("HSP-1")
    end

    it "passes query options" do
      stub_agile_get("/board/84/backlog?maxResults=10", "board_backlog")
      Jira.board_backlog(84, maxResults: 10)
      expect(a_agile_get("/board/84/backlog?maxResults=10")).to have_been_made
    end
  end

  describe ".board_configuration" do
    it "returns board configuration", :aggregate_failures do
      stub_agile_get("/board/84/configuration", "board_configuration")

      result = Jira.board_configuration(84)

      expect(a_agile_get("/board/84/configuration")).to have_been_made
      expect(result[:id]).to eq(10_000)
      expect(result[:name]).to eq("Board")
    end
  end

  describe ".board_epics" do
    it "returns paginated epics", :aggregate_failures do
      stub_agile_get("/board/84/epic", "board_epics")

      result = Jira.board_epics(84)

      expect(a_agile_get("/board/84/epic")).to have_been_made
      expect(result).to be_a(Jira::PaginatedResponse)
      expect(result.total).to eq(5)
      expect(result.first[:name]).to eq("epic 1")
    end

    it "passes query options" do
      stub_agile_get("/board/84/epic?done=false", "board_epics")
      Jira.board_epics(84, done: false)
      expect(a_agile_get("/board/84/epic?done=false")).to have_been_made
    end
  end

  describe ".board_issues_without_epic" do
    it "returns paginated issues without an epic", :aggregate_failures do
      stub_agile_get("/board/84/epic/none/issue", "board_issues")

      result = Jira.board_issues_without_epic(84)

      expect(a_agile_get("/board/84/epic/none/issue")).to have_been_made
      expect(result).to be_a(Jira::PaginatedResponse)
      expect(result.first[:key]).to eq("HSP-1")
    end

    it "passes query options" do
      stub_agile_get("/board/84/epic/none/issue?maxResults=5", "board_issues")
      Jira.board_issues_without_epic(84, maxResults: 5)
      expect(a_agile_get("/board/84/epic/none/issue?maxResults=5")).to have_been_made
    end
  end

  describe ".board_epic_issues" do
    it "returns paginated issues for an epic", :aggregate_failures do
      stub_agile_get("/board/84/epic/37/issue", "board_issues")

      result = Jira.board_epic_issues(84, 37)

      expect(a_agile_get("/board/84/epic/37/issue")).to have_been_made
      expect(result).to be_a(Jira::PaginatedResponse)
      expect(result.first[:key]).to eq("HSP-1")
    end

    it "passes query options" do
      stub_agile_get("/board/84/epic/37/issue?maxResults=5", "board_issues")
      Jira.board_epic_issues(84, 37, maxResults: 5)
      expect(a_agile_get("/board/84/epic/37/issue?maxResults=5")).to have_been_made
    end
  end

  describe ".board_features" do
    it "returns board features", :aggregate_failures do
      stub_agile_get("/board/84/features", "board_features")

      result = Jira.board_features(84)

      expect(a_agile_get("/board/84/features")).to have_been_made
      expect(result[:features]).to be_an(Array)
      expect(result[:features].first[:boardFeature]).to eq("BACKLOG")
    end
  end

  describe ".toggle_board_feature" do
    it "toggles a board feature", :aggregate_failures do
      stub_agile_put("/board/84/features", "board_features")

      result = Jira.toggle_board_feature(84, { feature: "BACKLOG", state: "ENABLED" })

      expect(a_agile_put("/board/84/features")).to have_been_made
      expect(result[:features]).to be_an(Array)
    end
  end

  describe ".board_issues" do
    it "returns paginated board issues", :aggregate_failures do
      stub_agile_get("/board/84/issue", "board_issues")

      result = Jira.board_issues(84)

      expect(a_agile_get("/board/84/issue")).to have_been_made
      expect(result).to be_a(Jira::PaginatedResponse)
      expect(result.total).to eq(1)
      expect(result.first[:key]).to eq("HSP-1")
    end

    it "passes query options" do
      stub_agile_get("/board/84/issue?jql=project+%3D+TEST", "board_issues")
      Jira.board_issues(84, jql: "project = TEST")
      expect(a_agile_get("/board/84/issue?jql=project+%3D+TEST")).to have_been_made
    end
  end

  describe ".move_issues_to_board" do
    it "moves issues to the board backlog", :aggregate_failures do
      stub_agile_post("/board/84/issue", "empty", status_code: 204)

      Jira.move_issues_to_board(84, issues: %w[TEST-1 TEST-2])

      expect(a_agile_post("/board/84/issue")).to have_been_made
    end
  end

  describe ".board_projects" do
    it "returns paginated board projects", :aggregate_failures do
      stub_agile_get("/board/84/project", "board_projects")

      result = Jira.board_projects(84)

      expect(a_agile_get("/board/84/project")).to have_been_made
      expect(result).to be_a(Jira::PaginatedResponse)
      expect(result.first[:key]).to eq("EX")
    end

    it "passes query options" do
      stub_agile_get("/board/84/project?maxResults=50", "board_projects")
      Jira.board_projects(84, maxResults: 50)
      expect(a_agile_get("/board/84/project?maxResults=50")).to have_been_made
    end
  end

  describe ".board_projects_full" do
    it "returns paginated board projects with full details", :aggregate_failures do
      stub_agile_get("/board/84/project/full", "board_projects")

      result = Jira.board_projects_full(84)

      expect(a_agile_get("/board/84/project/full")).to have_been_made
      expect(result).to be_a(Jira::PaginatedResponse)
      expect(result.first[:key]).to eq("EX")
    end
  end

  describe ".board_property_keys" do
    it "returns board property keys", :aggregate_failures do
      stub_agile_get("/board/84/properties", "board_property_keys")

      result = Jira.board_property_keys(84)

      expect(a_agile_get("/board/84/properties")).to have_been_made
      expect(result[:keys]).to be_an(Array)
      expect(result[:keys].first[:key]).to eq("issue.support")
    end
  end

  describe ".board_property" do
    it "returns a board property", :aggregate_failures do
      stub_agile_get("/board/84/properties/issue.support", "board_property")

      result = Jira.board_property(84, "issue.support")

      expect(a_agile_get("/board/84/properties/issue.support")).to have_been_made
      expect(result[:key]).to eq("issue.support")
      expect(result[:value]).to be_a(Jira::ObjectifiedHash)
    end
  end

  describe ".set_board_property" do
    it "sets a board property", :aggregate_failures do
      stub_agile_put("/board/84/properties/issue.support", "empty", status_code: 200)

      Jira.set_board_property(84, "issue.support", { system: "https://example.com" })

      expect(a_agile_put("/board/84/properties/issue.support")).to have_been_made
    end
  end

  describe ".delete_board_property" do
    it "deletes a board property", :aggregate_failures do
      stub_agile_delete("/board/84/properties/issue.support", "empty", status_code: 204)

      Jira.delete_board_property(84, "issue.support")

      expect(a_agile_delete("/board/84/properties/issue.support")).to have_been_made
    end
  end

  describe ".board_quick_filters" do
    it "returns paginated quick filters", :aggregate_failures do
      stub_agile_get("/board/84/quickfilter", "board_quick_filters")

      result = Jira.board_quick_filters(84)

      expect(a_agile_get("/board/84/quickfilter")).to have_been_made
      expect(result).to be_a(Jira::PaginatedResponse)
      expect(result.total).to eq(5)
      expect(result.first[:name]).to eq("Bugs")
    end
  end

  describe ".board_quick_filter" do
    it "returns a single quick filter", :aggregate_failures do
      stub_agile_get("/board/84/quickfilter/1", "board_quick_filter")

      result = Jira.board_quick_filter(84, 1)

      expect(a_agile_get("/board/84/quickfilter/1")).to have_been_made
      expect(result[:id]).to eq(1)
      expect(result[:name]).to eq("Bugs")
      expect(result[:jql]).to eq("issueType = bug")
    end
  end

  describe ".board_reports" do
    it "returns board reports", :aggregate_failures do
      stub_agile_get("/board/84/reports", "board_reports")

      result = Jira.board_reports(84)

      expect(a_agile_get("/board/84/reports")).to have_been_made
      expect(result[:reports]).to be_an(Array)
    end
  end

  describe ".board_sprints" do
    it "returns paginated sprints", :aggregate_failures do
      stub_agile_get("/board/84/sprint", "board_sprints")

      result = Jira.board_sprints(84)

      expect(a_agile_get("/board/84/sprint")).to have_been_made
      expect(result).to be_a(Jira::PaginatedResponse)
      expect(result.total).to eq(5)
      expect(result.first[:id]).to eq(37)
      expect(result.first[:name]).to eq("sprint 1")
    end

    it "passes query options" do
      stub_agile_get("/board/84/sprint?state=active", "board_sprints")
      Jira.board_sprints(84, state: "active")
      expect(a_agile_get("/board/84/sprint?state=active")).to have_been_made
    end
  end

  describe ".board_sprint_issues" do
    it "returns paginated issues for a sprint on the board", :aggregate_failures do
      stub_agile_get("/board/84/sprint/37/issue", "board_issues")

      result = Jira.board_sprint_issues(84, 37)

      expect(a_agile_get("/board/84/sprint/37/issue")).to have_been_made
      expect(result).to be_a(Jira::PaginatedResponse)
      expect(result.first[:key]).to eq("HSP-1")
    end

    it "passes query options" do
      stub_agile_get("/board/84/sprint/37/issue?maxResults=25", "board_issues")
      Jira.board_sprint_issues(84, 37, maxResults: 25)
      expect(a_agile_get("/board/84/sprint/37/issue?maxResults=25")).to have_been_made
    end
  end

  describe ".board_versions" do
    it "returns paginated versions", :aggregate_failures do
      stub_agile_get("/board/84/version", "board_versions")

      result = Jira.board_versions(84)

      expect(a_agile_get("/board/84/version")).to have_been_made
      expect(result).to be_a(Jira::PaginatedResponse)
      expect(result.total).to eq(5)
      expect(result.first[:id]).to eq(10_000)
      expect(result.first[:name]).to eq("Version 1")
    end

    it "passes query options" do
      stub_agile_get("/board/84/version?released=true", "board_versions")
      Jira.board_versions(84, released: true)
      expect(a_agile_get("/board/84/version?released=true")).to have_been_made
    end
  end
end
