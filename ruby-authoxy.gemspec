#!/usr/bin/env ruby

Gem::Specification.new do |s|
  
  # GEM INFO
  s.name        = 'ruby-authoxy'
  s.version     = '1.0.1'
  s.summary     = 'A ruby version of Authoxy (www.hrsoftworks.net).'
  s.description = 'A Ruby version of the popular Authoxy program by Heath Raftery (http://www.hrsoftworks.net/Products.php#authoxy)'
  
  # AUTHOR
  s.authors     = 'Elia Schito'
  s.email       = 'perlelia@gmail.com'
  
  #FILES
  s.files = %w[lib/authoxy.rb lib/authoxy.example.yml]
  s.has_rdoc = true
  s.require_paths = ['lib']
  s.executables = %q[authoxy]
  
  # DEPENDENCIES
  s.required_ruby_version = '>= 1.8.6'
end
