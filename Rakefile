require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "jsparrow"
    gem.summary = "JSparrow is a JMS client based on JRuby"
    gem.email = "leandrodoze@gmail.com"
    gem.homepage = "http://github.com/leandrosilva/jsparrow"
    gem.authors = ["Leandro Silva"]
    gem.files =  FileList["[A-Z]*", "{lib,sample,spec}/**/*"]
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler -s http://gemcutter.org"
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = 'jsparrow'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = false
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/*_test.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new do |spec|
  spec.spec_files = FileList['spec/**/*_spec.rb']
  spec.spec_opts = %w(-fs --color)
end

task :default => :test
