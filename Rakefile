require 'rake/rdoctask'
require 'spec/rake/spectask'
 
task :default => :spec
 
desc 'Run specs'
Spec::Rake::SpecTask.new('spec') do |task|
  task.spec_files = FileList['spec/**/*_spec.rb']
end
 
Rake::RDocTask.new do |task|
  task.rdoc_dir = 'doc'
  task.title = 'chronic_duration'
  task.options << '--line-numbers' << '--inline-source' << '--main' << 'README.rdoc'
  task.rdoc_files.include 'README.rdoc'
  task.rdoc_files.include 'lib/**/*.rb'
end