Gem::Specification.new do |s|
  
  s.name          = "chronic_duration"
  s.version       = "0.2.0"
  s.date          = "2009-01-11"
  
  s.summary       = "A Ruby natural language parser for elapsed time"
  s.description   = "A simple Ruby natural language parser for elapsed time. 
    (For example, 4 hours and 30 minutes, 6 minutes 4 seconds, 3 days, etc.) 
    Returns all results in seconds. Will return an integer unless you get tricky and need a float. 
    (4 minutes and 13.47 seconds, for example.)"
  
  s.require_path  = 'lib'
  s.files         = Dir['lib/**/*.rb', '[A-Z]*']
  s.test_files    = Dir['spec/**/*.rb', 'Rakefile']
  
  s.has_rdoc      = true
  s.rdoc_options  = ['--line-numbers', '--inline-source', '--main', 'README']
  
  s.author        = "Henry Poydar"
  s.email         = "henry@poydar.com"
  s.homepage      = "http://github.com/hpoydar/chronic_duration"

end