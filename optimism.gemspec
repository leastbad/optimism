lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "optimism/version"

Gem::Specification.new do |spec|
  spec.name          = "optimism"
  spec.version       = Optimism::VERSION
  spec.authors       = ["leastbad"]
  spec.email         = ["hello@leastbad.com"]

  spec.summary       = %q{Drop-in Rails form validations}
  spec.description   = %q{Realtime remote form input validations delivered via websockets}
  spec.homepage      = "https://github.com/leastbad/optimism"
  spec.license       = "MIT"

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-nav"
  spec.add_development_dependency "standardrb"
  spec.add_dependency "rack"
  spec.add_dependency "rails", ">= 5.2"
  spec.add_dependency "cable_ready", "~> 4.0.9"
end
