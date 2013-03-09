require 'sinatra'
require 'json'

class Application < Sinatra::Base

get '/geofence/:fence_id/crossed' do
  fence_id = params[:fence_id]
  user_id  = params[:user_id]

  puts "Geofence #{fence_id} has been crossed by #{user_id}"

  status 200
  return {status:  "ok",
          crossing:  {geofence_id:  fence_id,
                      user_id:      user_id}}.to_json
end

end
