#!/usr/bin/env ruby

Gem::Specification.new do |s|
  
  # GEM INFO
  s.name        = 'authoxy'
  s.version     = '1.2'
  s.summary     = 'A ruby version of Authoxy (www.hrsoftworks.net).'
  s.description = 'A Ruby version of the popular Authoxy program by Heath Raftery (http://www.hrsoftworks.net/Products.php#authoxy)'
  
  # AUTHOR
  s.authors     = 'Elia Schito'
  s.email       = 'perlelia@gmail.com'
  
  # FILES
  s.files = Dir['{bin,lib}/**/*'] #%w[lib/authoxy.rb lib/tasi_authoxy.rb lib/authoxy.example.yml]
  s.has_rdoc = true
  s.require_paths = ['lib']
  s.executables = %w[authoxy thasoxy]
  
  # DEPENDENCIES
  s.required_ruby_version = '>= 1.8.6'
end
