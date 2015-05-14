require 'rubygems'
require 'rake/clean'
require 'rake/gempackagetask'
 
spec = Gem::Specification.new do |s|
  s.name = %q{ruxtran}
  s.version = "0.1.9"
  s.date = %q{2006-11-27}
  s.summary = %q{Ruby XML transformation library}
  s.email = %q{ernest.micklei@philemonworks.com}
  s.homepage = %q{http://www.philemonworks.com/ruxtran}
  s.description = %q{Similar to XSLT but now transformations are written in Ruby}
  s.autorequire = %q{}
  s.has_rdoc = true
  s.authors = ["Ermest Micklei"]
  # bin
  s.files += Dir.new('./bin').entries.select{|e| e =~ /^[^.]/}.collect{|e| 'bin/'+e}
  # doc
  s.files += Dir.new('./doc').entries.select{|e| e =~ /\.html$/}.collect{|e| 'doc/'+e}
  # lib
  s.files += Dir.new('./lib').entries.select{|e| e =~ /\.rb$/}.collect{|e| 'lib/'+e}
  # lib/ruxtran
  s.files += Dir.new('./lib/ruxtran').entries.select{|e| e =~ /\.rb$/}.collect{|e| 'lib/ruxtran/'+e}
# samples
  s.files += Dir.new('./samples').entries.select{|e| e =~ /^[^.]/}.collect{|e| 'samples/'+e}
  s.test_files = Dir.new('./tests').entries.select{|e| e =~ /^[^.].*\.rb$/}.collect{|e| 'tests/'+e}
  s.rdoc_options = ["--title", "Ruxtran -- XML transformer", "--main", "README", "--line-numbers"]
  s.extra_rdoc_files = ['README']
  s.executables = ["ruxtran"]  
  s.default_executable = %q{ruxtran}  
  s.add_dependency('builder', '>= 1.2.4')
end

Rake::GemPackageTask.new(spec) do |pkg| end

task :install do
    Gem::GemRunner.new.run(['install','pkg/ruxtran'])
end

desc "Default Task"
task :default => [ :package ,:install ]
   
