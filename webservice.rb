require 'sinatra'
require 'dm-core'
require 'dm-mysql-adapter'
require 'dm-migrations'
require 'dm-serializer/to_json'
require 'json'
require 'yaml'

use Rack::Logger
$logger = Logger.new "log/webservice.log"

DataMapper::Logger.new("log/webservice.log", :debug)

credentials = YAML.load_file('config/database.yml')
username    = credentials["development"]["username"]
password    = credentials["development"]["password"]
hostname    = credentials["development"]["hostname"]

DataMapper.setup(:default, "mysql://#{username}:#{password}@#{hostname}/geofencing")

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
Geofence.auto_upgrade!

class Application < Sinatra::Base

  before do
    content_type 'application/json'
  end

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

  get '/locations' do

    callback = params[:callback]; # JSONP
    
    locations = Location.all

    status 200
    json = {:locations => locations}.to_json

    if callback
      return "#{callback}(#{json});"
    else
      return json
    end

  end

  get '/geofences' do

    callback = params[:callback]; # JSONP

    geofences = Geofence.all

    status 200
    json = {:geofences => geofences}.to_json

    if callback
      return "#{callback}(#{json});"
    else
      return json
    end

  end
  
end
