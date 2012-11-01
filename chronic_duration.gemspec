Gem::Specification.new do |s|
  s.name = %q{chronic_duration}
  s.version = "0.9.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["hpoydar"]
  s.date = %q{2011-06-04}
  s.description = %q{A simple Ruby natural language parser for elapsed time. (For example, 4 hours and 30 minutes, 6 minutes 4 seconds, 3 days, etc.) Returns all results in seconds. Will return an integer unless you get tricky and need a float. (4 minutes and 13.47 seconds, for example.) The reverse can also be performed via the output method.}
  s.email = %q{hpoydar@gmail.com}
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
    "Gemfile",
    "MIT-LICENSE",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "chronic_duration.gemspec",
    "lib/chronic_duration.rb",
    "spec/chronic_duration_spec.rb"
  ]
  s.homepage = %q{http://github.com/hpoydar/chronic_duration}
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.5.2}
  s.summary = %q{A Ruby natural language parser for elapsed time}
  s.test_files = [
    "spec/chronic_duration_spec.rb"
  ]

  s.add_runtime_dependency(%q<numerizer>, ["~> 0.1.1"])
  s.add_development_dependency(%q<rspec>, ["~> 2.11.0"])
  s.add_development_dependency(%q<bundler>, ["~> 1.2.0"])
  s.add_development_dependency(%q<simplecov>, ["~> 0.7.1"])
  s.add_development_dependency(%q<rake>, [">= 0"])
  s.add_development_dependency(%q<rdoc>, [">= 0"])
end

