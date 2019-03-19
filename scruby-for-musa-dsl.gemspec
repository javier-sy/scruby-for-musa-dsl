# -*- encoding: utf-8 -*-
require_relative 'lib/scruby/version'

Gem::Specification.new do |s|
  s.name        = "scruby-for-musa-dsl"
  s.version     = Scruby::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Javier Sánchez Yeste']
  s.email       = ['javier.sy@gmail.com']
  s.homepage    = 'https://github.com/javier-sy/scruby'
  s.summary     = 'Ruby SuperCollider client for Musa-DSL based on scruby by Macario Ortega'
  s.description = 'Ruby SuperCollider client for Musa-DSL based on scruby by Macario Ortega'

  s.rubyforge_project = 'scruby-for-musa-dsl'

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rspec'

  s.add_dependency 'ruby-osc', '~> 0.40'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']
end
