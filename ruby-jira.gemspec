# frozen_string_literal: true

require_relative "lib/jira/version"

Gem::Specification.new do |spec|
  spec.name = "ruby-jira"
  spec.version = Jira::VERSION
  spec.authors = ["Maciej Kozak"]
  spec.email = ["maciej.kozak@gmail.com"]

  spec.summary = "Ruby client and CLI for Jira Cloud API"
  spec.description = "A Ruby wrapper for Jira Cloud API"
  spec.homepage = "https://github.com/macio/ruby-jira"
  spec.license = "BSD-2-Clause"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir["{exe,lib}/**/*", "LICENSE.txt", "README.md", "CHANGELOG.md"]
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "httparty"
end
