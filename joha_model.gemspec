# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "joha_model/version"

Gem::Specification.new do |s|
  s.name        = "joha_model"
  s.version     = JohaModel::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["David Martin"]
  s.email       = ["dmarti21@gmail.com"]
  s.homepage    = "http://www.joha.us"
  s.summary     = %q{Model for the joha app}
  s.description = %q{Model for the joha app}
  s.add_runtime_dependency(%q{tinkit})
  s.add_runtime_dependency(%q{kinkit})
  s.add_runtime_dependency(%q{burp})
  s.add_runtime_dependency(%q{jsivt_grapher})

  s.rubyforge_project = "joha_model"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
