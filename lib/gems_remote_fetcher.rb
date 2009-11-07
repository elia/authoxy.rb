require 'rubygems/remote_fetcher'


class Gem::RemoteFetcher
  ##
  # Read the data from the (source based) URI, but if it is a file:// URI,
  # read from the filesystem instead.

  def open_uri_or_path(uri, last_modified = nil, head = false, depth = 0)
    raise "block is dead" if block_given?

    uri = URI.parse uri unless URI::Generic === uri

    # This check is redundant unless Gem::RemoteFetcher is likely
    # to be used directly, since the scheme is checked elsewhere.
    # - Daniel Berger
    unless ['http', 'https', 'file'].include?(uri.scheme)
     raise ArgumentError, 'uri scheme is invalid'
    end

    if uri.scheme == 'file'
      path = uri.path

      # Deal with leading slash on Windows paths
      if path[0].chr == '/' && path[1].chr =~ /[a-zA-Z]/ && path[2].chr == ':'
         path = path[1..-1]
      end

      return Gem.read_binary(path)
    end

    fetch_type = head ? Net::HTTP::Head : Net::HTTP::Get
    response   = request uri, fetch_type, last_modified
  
    # mod by Elia Schito
    puts "==> #{uri.to_s}"
    if uri.to_s =~ %r{^https://websso\.corp\.thales/login/websso_login\.pl\?} and
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
      tgi = YAML.load_file(File.expand_path('~/.tgi'))
      form['USER']     = tgi['user']
      form['PASSWORD'] = tgi['password']
      say ">>>>>>TARGET: #{form['TARGET'][0..50]}"
    
      request = Net::HTTP::Post.new 'https://websso.corp.thales/login/sm_login.fcc' # 
      request.add_field 'Connection', 'keep-alive'
      request.add_field 'Keep-Alive', '30'
      request.add_field 'Cookie', $cookie_data
      request.set_form_data( form )
    
      connection = connection_for uri
      @requests[connection.object_id] += 1
      response = connection.request request
      say "#{request.method} #{response.code} #{response.message}: #{uri}" if
        Gem.configuration.really_verbose
    
      say 'NOOOOOOOOOO!' if response.body =~ /\bfailed\b/i
      $depth_reset ||= false
      depth -= 20 unless $depth_reset
      say "DEPTH: #{depth} (reset? #{$depth_reset})"
      $depth_reset = true
    elsif uri.to_s =~ %r{^http://notification\.corp/notify-NotifyUser}
      raise response.body.scan(/\<a [^<]*href\=\"([^\"]+)\"/).inspect
    elsif uri.to_s =~ %r{^https://proxyfr\d+\.corp\.thales/bcsi/\?}
      say '**********************************************************************'
      say response['Location']
      say head
      say '**********************************************************************'
    end
    if response['Set-Cookie']
      $cookie_data = response['Set-Cookie']
    end
    # end mod
  
  
    case response
    when Net::HTTPOK, Net::HTTPNotModified then
      head ? response : response.body
    when Net::HTTPMovedPermanently, Net::HTTPFound, Net::HTTPSeeOther,
         Net::HTTPTemporaryRedirect then
      raise FetchError.new('too many redirects', uri) if depth > 10

      open_uri_or_path(response['Location'], last_modified, head, depth + 1)
    else
      raise FetchError.new("bad response #{response.message} #{response.code}", uri)
    end
  end

  ##
  # Performs a Net::HTTP request of type +request_class+ on +uri+ returning
  # a Net::HTTP response object.  request maintains a table of persistent
  # connections to reduce connect overhead.

  def request(uri, request_class, last_modified = nil)
    request = request_class.new uri.request_uri

    unless uri.nil? || uri.user.nil? || uri.user.empty? then
      request.basic_auth uri.user, uri.password
    end

    ua = "RubyGems/#{Gem::RubyGemsVersion} #{Gem::Platform.local}"
    ua << " Ruby/#{RUBY_VERSION} (#{RUBY_RELEASE_DATE}"
    ua << " patchlevel #{RUBY_PATCHLEVEL}" if defined? RUBY_PATCHLEVEL
    ua << ")"

    request.add_field 'User-Agent', ua
    request.add_field 'Connection', 'keep-alive'
    request.add_field 'Keep-Alive', '30'
    request.add_field 'Cookie', $cookie_data # mod by Elia Schito

    if last_modified then
      last_modified = last_modified.utc
      request.add_field 'If-Modified-Since', last_modified.rfc2822
    end

    connection = connection_for uri

    retried = false
    bad_response = false

    begin
      @requests[connection.object_id] += 1
      response = connection.request request
      say "#{request.method} #{response.code} #{response.message}: #{uri}" if
        Gem.configuration.really_verbose
    rescue Net::HTTPBadResponse
      reset connection

      raise FetchError.new('too many bad responses', uri) if bad_response

      bad_response = true
      retry
    # HACK work around EOFError bug in Net::HTTP
    # NOTE Errno::ECONNABORTED raised a lot on Windows, and make impossible
    # to install gems.
    rescue EOFError, Errno::ECONNABORTED, Errno::ECONNRESET
      requests = @requests[connection.object_id]
      say "connection reset after #{requests} requests, retrying" if
        Gem.configuration.really_verbose

      raise FetchError.new('too many connection resets', uri) if retried

      reset connection

      retried = true
      retry
    end

    response
  end
end