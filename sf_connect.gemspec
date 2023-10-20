# frozen_string_literal: true

require_relative "lib/sf_connect/version"

Gem::Specification.new do |spec|
  spec.name = "sf_connect"
  spec.version = SfConnect::VERSION
  spec.authors = ["Masa (Aileron inc)"]
  spec.email = ["masa@aileron.cc"]

  spec.summary       = "ActiveRecord and Salesforce integration gem"
  spec.description   = "A gem for integrating ActiveRecord and Salesforce using Restforce"
  spec.homepage      = "https://github.com/aileron-inc/sf_connect"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/aileron-inc/sf_connect"
  spec.metadata["changelog_uri"] = "https://github.com/aileron-inc/sf_connect/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_runtime_dependency "restforce", ">= 2.0"
  spec.add_dependency "activesupport", ">= 6.0.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata["rubygems_mfa_required"] = "true"
end
