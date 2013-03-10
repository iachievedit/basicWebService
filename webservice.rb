require 'sinatra'
require 'dm-core'
require 'dm-sqlite-adapter'
require 'dm-migrations'
require 'json'

use Rack::Logger
$logger = Logger.new "log/webservice.log"

DataMapper::Logger.new("log/webservice.log", :debug)

DataMapper.setup(:default, 'sqlite3:public/system/webservice.db')

class Location
  include DataMapper::Resource

  property :id,       Serial
  property :latitude, Float
  property :longitude, Float
  property :created_at, String
end

class Geofence
  include DataMapper::Resource

  property :id, Serial
  property :latitude,  Float
  property :longitude, Float
  property :radius,    Integer
  property :event,     String
  property :created_at, String
end

DataMapper.finalize

Location.auto_upgrade!

class Application < Sinatra::Base

  post '/location' do
    latitude   = params[:latitude]
    longitude  = params[:longitude]
    
    $logger.debug "Location #{latitude}, #{longitude} posted"
    
    Location.create(:latitude   => latitude,
                    :longitude  => longitude,
                    :created_at => Time.now.to_s)

    status 200
    return {:status =>  "ok"}.to_json
  end

  post '/geofence' do
    latitude   = params[:latitude]
    longitude  = params[:longitude]
    radius     = params[:radius]
    event      = params[:event]
    
    $logger.debug "#{event} geofence with center (#{latitude}, #{longitude}) radius #{radius}"
    
    Geofence.create(:latitude   => latitude,
                    :longitude  => longitude,
                    :radius     => radius,
                    :event      => event,
                    :created_at => Time.now.to_s)

    status 200
    return {:status =>  "ok"}.to_json
  end
  
end
