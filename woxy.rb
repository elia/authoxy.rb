require 'webrick'
require 'webrick/httpproxy'
require 'webrick/https'
require 'openssl'

require 'pp'
TGI = YAML.load_file('~/.tgi')

class WEBrick::HTTPRequest
  def update_uri(uri)
    @unparsed_uri = uri
    @request_uri = parse_uri(uri)
  end
end

class WEBrick::HTTPResponse
  def inject_payload(string)
    if @content_type =~ /html/
      @body.gsub!( /<\/body>/ , "<script>#{string}</script></body>") # this is just
    end
  end
end

req_call = Proc.new do |req,res|
  req.add_field 'Cookie', $cookie_data # mod by Elia Schito
end


res_call = Proc.new do |req,res|
  
  response = res
  uri = res['location']
  puts "****** Requested URI" +  req.unparsed_uri
  puts "****** Redirect Location: " +  uri.to_s
  # pp res
  # puts '*' * 80
  if uri =~ %r{^https://websso\.corp\.thales/login/websso_login\.pl\?} and
      response.body.include? 'THALES WEBSSO LOGIN PAGE'
    # <form NAME="login" action="sm_login.fcc" METHOD="POST" onSubmit="connect(); return false;">
    #   <input type=hidden name=TARGET value="-SM-https://proxyfr02.corp.thales/bcsi/?cfru=aHR0cDovL2dlbXMucnVieWZvcmdlLm9yZy9xdWljay9NYXJzaGFsLjQuOC9hY3RpdmVyZWNvcmQtMi4zLjMuZ2Vtc3BlYy5yeg==">
    #   <input type=hidden name=SMAUTHREASON value="0">
    #   <input type=hidden name=SMAGENTNAME value="-SM-JlKvNa6JrRE+GdzgtUMKX2c0KdW39h9z8pz3OcF3DobheRKLqobognbX+AUY0vzx">
    #   <input type=hidden name=POSTPRESERVATIONDATA value="">
    #   <input type=hidden name="SMENC" value="ISO-8859-1">
    #   <input type=hidden name="SMLOCALE" value="US-EN">
    #   <input type="hidden" name="PASSWORD" value="">
    #   <input type="hidden" name="lang" value="">
    #   <input type="text" name="USER" maxlength="8" size="23">
    # </form>
    
    form = {}
    hidden_fields_regex = /hidden name\=\"?(TARGET|SMAUTHREASON|SMAGENTNAME|POSTPRESERVATIONDATA|SMENC|SMLOCALE|lang)\"? value\=\"(.*)\"\>/ 
    response.body.scan( hidden_fields_regex ).each do |(name, value)|
      form[name] = value
    end
    form['lang']     = 'en'
    form['USER']     = TGI['user']
    form['PASSWORD'] = TGI['password']
    puts ">>>>>>TARGET: #{form['TARGET'][0..50]}"
    
    request = Net::HTTP::Post.new 'https://websso.corp.thales/login/sm_login.fcc' # 
    request.add_field 'Connection', 'keep-alive'
    request.add_field 'Keep-Alive', '30'
    request.add_field 'Cookie', $cookie_data
    request.set_form_data( form )
    
    # connection = connection_for uri
    # @requests[connection.object_id] += 1
    response = connection.request request
    puts "#{request.method} #{response.code} #{response.message}: #{uri}" if
      Gem.configuration.really_verbose
    
    puts 'NOOOOOOOOOO!' if response.body =~ /\bfailed\b/i
    $depth_reset ||= false
    depth -= 20 unless $depth_reset
    puts "DEPTH: #{depth} (reset? #{$depth_reset})"
    $depth_reset = true
  elsif uri.to_s =~ %r{^http://notification\.corp/notify-NotifyUser}
    raise response.body.scan(/\<a [^<]*href\=\"([^\"]+)\"/).inspect
  elsif uri.to_s =~ %r{^https://proxyfr\d+\.corp\.thales/bcsi/\?}
    puts '**********************************************************************'
    puts response['Location']
    # puts res.head
    puts '**********************************************************************'
  elsif uri =~ /^https:/
    
  end
  
  if response['Set-Cookie']
    $cookie_data = response['Set-Cookie']
  end
  # res.inject_payload("alert(\"P0wned\");")
end

puts "Starting..."

config = {
  :Port => 8090,
  :BindAddress => '127.0.0.1',
  :ServerType => Thread,
  # :RequestCallback => req_call,
  :ProxyVia => true,
  :ProxyURI => URI.parse('http://elia.schito:snorkies@172.24.1.50:8080'),
  # :ProxyTimeout => true,
  :ProxyContentHandler => res_call
}

if ARGV.include? 'ssl'
  config.merge!(
    :Port => 8091,
    :SSLEnable => true,
    :SSLVerifyClient => OpenSSL::SSL::VERIFY_NONE,
    :SSLCertName => [ [ "CN", WEBrick::Utils::getservername ] ]
  )
end


s = WEBrick::HTTPProxyServer.new(config)
# s.mount('/')
# trap("INT"){s.shutdown}
puts s.status

s.start

puts s.status
sleep




