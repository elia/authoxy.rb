# coded by MenTaLguY, a starter proxy for hoodwink.d
# released 2005 Aug 26
require 'webrick/httpproxy'

class HoOdLuM < WEBrick::HTTPProxyServer

    TOKEN = WEBrick::Utils::random_string 32

    HOSTS = Hash[ *%w[
        hoodwink.d  65.125.236.166
    ] ]

    CACHE_SCRIPT_FOR = 1800

    def initialize(*args)
        super(*args)
        config.merge!(
            :RequestCallback => method( :prewink ),
            :ProxyContentHandler => method( :upwink )
        )
    end

    def prewink( req, res )
        class << req
            attr_accessor :visible_request_uri
            def set_uri( uri, host = nil )
                instance_variable_set( "@unparsed_uri", uri.to_s )
                instance_variable_set( "@request_uri", uri )
                header['host'] = [host || uri.host]
            end
        end

        req.visible_request_uri = req.request_uri.dup
        if req.visible_request_uri.to_s == "http://hoodwink.d/jsx/hoodwinkd.user.js"
            if @cached_script and Time.now - @cached_script.first < CACHE_SCRIPT_FOR
                @cached_script.last.instance_variables.each do |iv|
                    res.instance_variable_set( iv, @cached_script.last.instance_variable_get( iv ) )
                end
                raise WEBrick::HTTPStatus::OK
            end
        end
        
        if req.request_uri.path =~ %r!^/#{ TOKEN }/!
            req.set_uri( URI( $' ) )
        end
        
        if HOSTS[req.request_uri.host]
            host, req.request_uri.host = req.request_uri.host, HOSTS[req.request_uri.host]
            req.set_uri( req.request_uri, host )
        end
        req.header.delete 'accept-encoding'
    end

    def upwink( req, res )
        if req.visible_request_uri.to_s == "http://hoodwink.d/jsx/hoodwinkd.user.js"
            @cached_script = [Time.now, fixup_script( res )] if res.status == 200
        elsif req.visible_request_uri.host == "hoodwink.d"
            # don't wink the hoods
        else
            if res.status == 200
                case res.content_type
                when /^text\/html/, /^application\/xhtml+xml/
                    inject_script( res )
                end
            end
        end
    end

    def fixup_script( res )
        replace_response( res ) { |script|
            "(function() {" + <<EOS + script + "})();"

function GM_xmlhttpRequest(details) {
    var req = null;
    if (window.XMLHttpRequest) {
        req = new XMLHttpRequest();
    } else if (window.ActiveXObject) {
        req = new ActiveXObject("Microsoft.XMLHTTP");
    }
    if (!req) return;

    var url = new String("http://" + window.location.host + "/#{ TOKEN }/" + details.url);
    req.open(details.method, url, true);
    if (details.headers) {
        for (header in details.headers) {
            req.setRequestHeader(header, details.headers[header])
        }
    }
    req.onreadystatechange = function() {
        if ( req.readyState == 4 && req.status == 200 && details.onload ) {
            details.onload(req);
        }
    }
    if (details.body) {
        req.send(details.body);
    } else {
        req.send("");
    }
}

EOS
        }
        res
    end

    def inject_script( res )
        replace_response( res ) { |doc|
            doc.sub!(/<\/body>/i, <<EOS)
    <script type="text/javascript" src="http://hoodwink.d/jsx/hoodwinkd.user.js">
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
end

server = HoOdLuM::new( 
    :BindAddress => "127.0.0.1",
    :Port => 37004
)
trap( :INT ) { server.shutdown }
server.start

