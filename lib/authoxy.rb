#!/usr/bin/env ruby
require 'webrick/httpproxy'
require 'webrick/httpauth/digestauth'
require 'webrick/httpauth/userdb'
require 'yaml'
require 'pp'

def ask question
  STDOUT.print question
  STDOUT.flush
  gets.chomp
end

class Authoxy
  attr_reader :name
  
  # Prepares a new Authoxy:
  # 
  # <code> my_proxy = Authoxy.new 'office', 8080, 'http://my.office.proxy.com:8080' </code>
  # 
  def initialize name, local_port, upstream_proxy, user, password
    @name = name
    proxy_uri          = URI::parse(upstream_proxy) 
    proxy_uri.user     = user
    proxy_uri.password = password
    
    # Set up the proxy itself
    @server = WEBrick::HTTPProxyServer.new(
      :LogFile => false,
      :Port => local_port.to_i,
      :ProxyVia => true,
      :ProxyURI => proxy_uri
    )
  end
  
  # Starts the proxy
  def start
    @thread = Thread.new do
      puts "Starting #{name} proxy..."
      @server.start
    end
  end
  
  # Stops the proxy
  def stop
    puts "Stopping #{name} proxy..."
    @server.shutdown
  end
  
  # Starts Authoxy loading the configuration from a YAML file like this:
  # 
  # office_proxy: 
  #   local_port: 8080
  #   upstream_proxy: http://my.office.proxy:8080
  #   password: very_secret_word
  #   user: elia.schito
  # 
  # other_office_proxy: 
  #   local_port: 8081
  #   upstream_proxy: http://other.proxy.com:8080
  #   user: elia
  #   password: other_very_secret_word
  # 
  def self.load path
    proxy_definitions = YAML.load_file(path)

    @proxies ||= []
    proxy_definitions.each do |(name, proxy)|
      @proxies << Authoxy.new( name, proxy['local_port'].to_i, proxy['upstream_proxy'], proxy['user'], proxy['password'] || ask("password (#{name}): ") )
    end
    
    trap('INT') {
      @proxies.each { |proxy| proxy.stop }
      exit
    }
    @proxies.each { |proxy| proxy.start }
    sleep
  end
end

Authoxy.load(File.dirname(__FILE__) + '/authoxy.yml') if $0 == __FILE__
