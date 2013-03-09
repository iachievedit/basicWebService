require 'sinatra'
require 'json'

$logger = Logger.new "log/webservice.log"

class Application < Sinatra::Base

get '/geofence/:fence_id/crossed' do
  fence_id = params[:fence_id]
  user_id  = params[:user_id]

  $logger.debug "Geofence #{fence_id} has been crossed by #{user_id}"

  status 200
  return {status:  "ok",
          crossing:  {geofence_id:  fence_id,
                      user_id:      user_id}}.to_json
end

end
