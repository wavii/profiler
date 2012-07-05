# -*- encoding: utf-8 -*-
require File.expand_path("../lib/profiler/version", __FILE__)

Gem::Specification.new do |gem|
  gem.name        =  "profiler"
  gem.description =  "A simple block/method profiler to help you get to the bottom of what is going on."
  gem.summary     =  "A simple code profiler."
  gem.authors     = ["Wavii, Inc."]
  gem.email       = ["info@wavii.com"]
  gem.homepage    =  "http://wavii.com/"

  gem.version  = Profiler::VERSION
  gem.platform = Gem::Platform::RUBY

  gem.files      = `git ls-files`.split("\n")
  gem.test_files = `git ls-files -- {spec}/*`.split("\n")

  gem.require_paths = ["lib"]
end
