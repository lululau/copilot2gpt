# frozen_string_literal: true

require_relative "lib/copilot2gpt/version"

Gem::Specification.new do |spec|
  spec.name = "copilot2gpt"
  spec.version = Copilot2gpt::VERSION
  spec.authors = ["Liu Xiang"]
  spec.email = ["liuxiang921@gmail.com"]

  spec.summary = "Proxy Copilot API to GPT-4 API"
  spec.description = "Proxy Copilot API to GPT-4 API"
  spec.homepage = "https://github.com/lululau/copilot2gpt"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/lululau/copilot2gpt"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "sinatra", "~> 3.1.0"
  spec.add_dependency "puma", "~> 6.3.0"
  spec.add_dependency "activesupport", "~> 7.0.0"
  spec.add_dependency "faraday", "~> 2.8.1"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
