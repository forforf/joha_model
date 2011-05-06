require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "joha_model"
  gem.homepage = "http://github.com/forforf/joha_model"
  gem.license = "TBD"
  gem.summary = %Q{Web model interface for all joha actions}
  gem.description = %Q{Hooks up to a web framework as a model and front-ends all the associated libraries needed to run the joha service}
  gem.email = "dmarti21@gmail.com"
  gem.authors = ["Dave M"]
  # Include your dependencies below. Runtime dependencies are required when using your gem,
  # and development dependencies are only needed for development (ie running rake tasks, tests, etc)
    gem.add_runtime_dependency 'couchrest', '~> 1.0'
    gem.add_runtime_dependency 'couchrest_extended_document', '~> 1.0' #working to remove this dependency
    #gem.add_runtime_dependency 'tinkit', :git => "git://github.com/forforf/kinkit"
    #gem.add_runtime_dependency 'kinkit', :git => "git://github.com/forforf/kinkit"
    #gem.add_runtime_dependency 'burp', :git => "git://github.com/forforf/burp"
    #gem.add_runtime_dependency 'jsivt_grapher', :git => "git://github.com/forforf/jsivt_grapher"
  #  gem.add_development_dependency 'rspec', '> 1.2.3'
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "joha_model #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
