#!/usr/bin/env ruby
require 'rake'
require 'rubygems'

Gem::Specification.new do |s|
  
  # GEM INFO
  s.name        = 'ruby-authoxy'
  s.version     = '1.0'
  s.summary     = 'A ruby version of Authoxy (www.hrsoftworks.net).'
  s.description = 'A Ruby version of the popular Authoxy program by Heath Raftery (http://www.hrsoftworks.net/Products.php#authoxy)'
  
  # AUTHOR
  s.authors     = 'Elia Schito'
  s.email       = 'perlelia@gmail.com'
  
  #FILES
  s.files = Dir['lib/authoxy.*']
  # s.has_rdoc = false
  s.require_paths = ['lib']
  # s.executables = Dir[Rails.root + '/bin/cmc*'].map {|f| File.basename(f) }
  
  # DEPENDENCIES
  s.required_ruby_version =                 '>= 1.8.6'
end

puts '=> Generating Gem...'
