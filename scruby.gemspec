# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "scruby/version"

Gem::Specification.new do |s|
  s.name        = "scruby"
  s.version     = Scruby::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Macario Ortega', 'Nicola Bernardini']
  s.email       = ['macarui@gmail.com', 'nicb@sme-ccppd.org']
  s.homepage    = 'http://github.com/nicb/scruby'
  s.summary     = %q{SuperCollider client for Ruby}
  s.description = %q{SuperCollider client for Ruby}

  s.rubyforge_project = "scruby"

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'byebug'
  s.add_dependency 'ruby-osc', '~> 0.31'
  s.add_dependency 'arguments', '~> 0.6'
  s.add_dependency 'live', '~> 0.1'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
