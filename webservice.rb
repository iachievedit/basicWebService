require 'sinatra'
require 'datamapper'
require 'json'

$logger = Logger.new "log/webservice.log"

DataMapper.setup(:default, "sqlite:webservice.db")

class Location
  include DataMapper::Resource

  property :latitude, Real
  property :longitude, Real
  property :created_at, String
end

Location.auto_migrate!

class Application < Sinatra::Base

post '/location' do
  latitude   = params[:latitude]
  longitude  = params[:longitude]
  created_at = params[:created_at]

  $logger.debug "Location #{latitude}, #{longitude} posted at #{created_at}"

  status 200
  return {status:  "ok"}
end

end
