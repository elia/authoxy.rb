require 'rubygems'
require 'sinatra'


get '/' do
'
  <form NAME="login" action="sm_login.fcc" METHOD="POST">
  <input type=hidden name=TARGET value="-SM-https://proxyfr02.corp.thales/bcsi/?cfru=aHR0cDovL2dlbXMucnVieWZvcmdlLm9yZy9xdWljay9NYXJzaGFsLjQuOC9hY3RpdmVyZWNvcmQtMi4zLjMuZ2Vtc3BlYy5yeg==">
  <input type=hidden name=SMAUTHREASON value="0">
  <input type=hidden name=SMAGENTNAME value="-SM-JlKvNa6JrRE+GdzgtUMKX2c0KdW39h9z8pz3OcF3DobheRKLqobognbX+AUY0vzx">
  <input type=hidden name=POSTPRESERVATIONDATA value="">
  <input type=hidden name="SMENC" value="ISO-8859-1">
  <input type=hidden name="SMLOCALE" value="US-EN">
  <input type="text" name="PASSWORD" value="">
  <input type="hidden" name="lang" value="">
  <input type="text" name="USER" maxlength="8" size="23">
  </form>
'
end



post '/*sm_login.fcc' do
  request.inspect
end