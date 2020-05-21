lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "optimism/version"

Gem::Specification.new do |spec|
  spec.name = "optimism"
  spec.version = Optimism::VERSION
  spec.authors = ["leastbad"]
  spec.email = ["hello@leastbad.com"]

  spec.summary = "Drop-in Rails form validations"
  spec.description = "Realtime remote form input validations delivered via websockets"
  spec.homepage = "https://github.com/leastbad/optimism"
  spec.license = "MIT"

  spec.files = Dir.chdir(File.expand_path("..", __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "pry", "~> 0.12.2"
  spec.add_development_dependency "pry-nav", "~> 0.3.0"
  spec.add_development_dependency "standardrb", "~> 1.0.0"
  spec.add_dependency "rack", "~> 2.0"
  spec.add_dependency "rails", [">= 5.2", ">= 6"]
  spec.add_dependency "cable_ready", ">= 4"
end
