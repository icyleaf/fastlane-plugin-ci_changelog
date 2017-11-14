# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/ci_changelog/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-ci_changelog'
  spec.version       = Fastlane::CiChangelog::VERSION
  spec.author        = %q{icyleaf}
  spec.email         = %q{icyleaf.cn@gmail.com}

  spec.summary       = %q{Automate generate changelog between previous build failed and the latest commit of scm in CI}
  spec.homepage      = "https://github.com/icyleaf/fastlane-plugin-ci_changelog"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'http', '~> 2.2.2'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'fastlane', '>= 1.103.0'
end
