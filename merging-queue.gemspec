# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "merging-queue/version"

Gem::Specification.new do |s|
  s.name        = "merging-queue"
  s.version     = MergingQueue::VERSION
  s.authors     = ["Andreas Saebjoernsen"]
  s.email       = ["andreas.saebjoernsen@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{QueuedTask Streams for rails}
  s.description = %q{MergingQueue is a simple gem for grouping tasks by type and time using the ActiveRecord ODM framework and background jobs}
  s.homepage    = 'https://github.com/digitalplaywright/merging-queue'
  s.license     = 'MIT'

  s.rubyforge_project = "merging-queue"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.required_ruby_version = '>= 1.9.3'

  s.add_dependency 'activerecord', '>= 3'
  s.add_dependency 'activesupport', '>= 3'
  s.add_dependency 'actionpack', '>= 3'
  s.add_development_dependency 'rake'

end
