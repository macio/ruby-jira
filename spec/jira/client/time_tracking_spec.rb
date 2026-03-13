# frozen_string_literal: true

require "spec_helper"

RSpec.describe Jira::Client do
  describe ".time_tracking_provider" do
    it "returns the selected time tracking provider", :aggregate_failures do
      stub_get("/configuration/timetracking", "time_tracking_provider")

      result = Jira.time_tracking_provider

      expect(a_get("/configuration/timetracking")).to have_been_made
      expect(result[:key]).to eq("Jira")
      expect(result[:name]).to eq("JIRA provided time tracking")
    end
  end

  describe ".select_time_tracking_provider" do
    it "selects a time tracking provider", :aggregate_failures do
      payload = { key: "Jira" }
      stub_put("/configuration/timetracking", "empty")

      Jira.select_time_tracking_provider(payload)

      expect(a_put("/configuration/timetracking").with(body: payload.to_json)).to have_been_made
    end
  end

  describe ".time_tracking_providers" do
    it "returns all available time tracking providers", :aggregate_failures do
      stub_get("/configuration/timetracking/list", "time_tracking_providers")

      result = Jira.time_tracking_providers

      expect(a_get("/configuration/timetracking/list")).to have_been_made
      expect(result).to be_an(Array)
      expect(result.first[:key]).to eq("Jira")
    end
  end

  describe ".time_tracking_settings" do
    it "returns the shared time tracking settings", :aggregate_failures do
      stub_get("/configuration/timetracking/options", "time_tracking_settings")

      result = Jira.time_tracking_settings

      expect(a_get("/configuration/timetracking/options")).to have_been_made
      expect(result[:defaultUnit]).to eq("hour")
      expect(result[:timeFormat]).to eq("pretty")
    end
  end

  describe ".set_time_tracking_settings" do
    it "sets the shared time tracking settings", :aggregate_failures do
      payload = { defaultUnit: "hour", timeFormat: "pretty" }
      stub_put("/configuration/timetracking/options", "time_tracking_settings")

      result = Jira.set_time_tracking_settings(payload)

      expect(a_put("/configuration/timetracking/options").with(body: payload.to_json)).to have_been_made
      expect(result[:defaultUnit]).to eq("hour")
    end
  end
end
