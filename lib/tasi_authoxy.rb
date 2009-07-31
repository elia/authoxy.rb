require File.dirname(__FILE__)+'/authoxy.rb'

class TasiAuthoxy < Authoxy
  def initialize user, password, tgi, tgi_password, port = 8080
    @tgi = tgi
    @tgi_password = tgi_password
    super 'vimodrone', port, 'http://172.24.1.50:8080', 
          user, password, {:ProxyContentHandler => method( :thales_login )}
  end
  
  def thales_login(req, res)
    case req.request_uri.to_s
    when %r{^https://websso\.corp\.thales/login/}
      inject_script res, <<-JS
        document.login.PASSWORD.value = '#{@tgi_password.gsub("'","\\'")}';
        document.login.USER.value = '#{@tgi}';
        document.login.submit();        
      JS
    when %r{^http://notification\.corp/notify-NotifyUser}
      inject_script res, <<-JS
        // http://notification.corp/notify-NotifyUser*
        document.location.href = document.getElementsByTagName('a')[0].href
      JS
    end
  end
  
  def inject_script( res, script )
    replace_response( res ) { |doc|
        doc.sub! /<\/body>/i, <<-EOS
          <script type="text/javascript">
            #{script}
          </script></body>
        EOS
        
        doc
    }
  end

  def replace_response( res )
    res.body = yield( res.body )
    res.header.delete 'etag'
    res.header.delete 'expires'
    res.header['cache-control'] = 'no-cache'
    res.header['pragma'] = 'no-cache'
    res.setup_header
  end
  
  def start
    trap('INT') {
      stop
      exit
    }
    super
    sleep
  end
end
