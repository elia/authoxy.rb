uri = response.request_uri.to_s

puts "==> #{uri.to_s}"
if uri.to_s =~ %r{^https://websso\.corp\.thales/login/websso_login\.pl\?} and
    response.body.include? 'THALES WEBSSO LOGIN PAGE'
    
    puts ' => LOGIN'
#   # <form NAME="login" action="sm_login.fcc" METHOD="POST" onSubmit="connect(); return false;">
#   #   <input type=hidden name=TARGET value="-SM-https://proxyfr02.corp.thales/bcsi/?cfru=aHR0cDovL2dlbXMucnVieWZvcmdlLm9yZy9xdWljay9NYXJzaGFsLjQuOC9hY3RpdmVyZWNvcmQtMi4zLjMuZ2Vtc3BlYy5yeg==">
#   #   <input type=hidden name=SMAUTHREASON value="0">
#   #   <input type=hidden name=SMAGENTNAME value="-SM-JlKvNa6JrRE+GdzgtUMKX2c0KdW39h9z8pz3OcF3DobheRKLqobognbX+AUY0vzx">
#   #   <input type=hidden name=POSTPRESERVATIONDATA value="">
#   #   <input type=hidden name="SMENC" value="ISO-8859-1">
#   #   <input type=hidden name="SMLOCALE" value="US-EN">
#   #   <input type="hidden" name="PASSWORD" value="">
#   #   <input type="hidden" name="lang" value="">
#   #   <input type="text" name="USER" maxlength="8" size="23">
#   # </form>
# 
#   form = {}
#   hidden_fields_regex = /hidden name\=\"?(TARGET|SMAUTHREASON|SMAGENTNAME|POSTPRESERVATIONDATA|SMENC|SMLOCALE|lang)\"? value\=\"(.*)\"\>/ 
#   response.body.scan( hidden_fields_regex ).each do |(name, value)|
#     form[name] = value
#   end
#   form['lang']     = 'en'
#   form['USER']     = @tgi
#   form['PASSWORD'] = @tgi_password
#   puts ">>>>>>TARGET: #{form['TARGET'][0..50]}"
# 
#   request = Net::HTTP::Post.new 'https://websso.corp.thales/login/sm_login.fcc' # 
#   request.add_field 'Connection', 'keep-alive'
#   request.add_field 'Keep-Alive', '30'
#   request.add_field 'Cookie', $cookie_data
#   request.set_form_data( form )
# 
#   connection = connection_for uri
#   @requests[connection.object_id] += 1
#   response = connection.request request
#   puts "#{request.method} #{response.code} #{response.message}: #{uri}" if
#     Gem.configuration.really_verbose
# 
#   puts 'NOOOOOOOOOO!' if response.body =~ /\bfailed\b/i
#   $depth_reset ||= false
#   depth -= 20 unless $depth_reset
#   puts "DEPTH: #{depth} (reset? #{$depth_reset})"
#   $depth_reset = true
# elsif uri.to_s =~ %r{^http://notification\.corp/notify-NotifyUser}
#   puts response.body.scan(/\<a [^<]*href\=\"([^\"]+)\"/).inspect
# elsif uri.to_s =~ %r{^https://proxyfr\d+\.corp\.thales/bcsi/\?}
#   puts '**********************************************************************'
#   puts response['Location']
#   puts head
#   puts '**********************************************************************'
# if response['Set-Cookie']
#   $cookie_data = response['Set-Cookie']
# end
end

return request, response
