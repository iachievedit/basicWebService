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

  belongs_to :trip
end

class Geofence
  include DataMapper::Resource

  property :id, Serial
  property :latitude,  Float
  property :longitude, Float
  property :radius,    Integer
  property :event,     String
  property :created_at, String

  belongs_to :trip
end

class Trip

  include DataMapper::Resource

  property :id,  Serial
  property :trip_identifier, String
  property :started_at, String
  property :stopped_at, String

  has n, :locations
  has n, :geofences

end

DataMapper.finalize

Location.auto_upgrade!
Geofence.auto_upgrade!
Trip.auto_upgrade!

class Application < Sinatra::Base

  before do
    content_type 'application/json'
  end

  post '/location' do
    latitude   = params[:latitude]
    longitude  = params[:longitude]
    trip_identifier = params[:trip_identifier]
    
    $logger.debug "Location #{latitude}, #{longitude} posted for trip #{trip_identifier}"

    trip = Trip.first(:trip_identifier => trip_identifier)

    location = Location.create(:latitude   => latitude,
                               :longitude  => longitude,
                               :created_at => Time.now.to_s)

    trip.locations << location
    trip.save!

    status 200
    return {:status =>  "ok"}.to_json

  end

  post '/geofence' do
    latitude   = params[:latitude]
    longitude  = params[:longitude]
    radius     = params[:radius]
    event      = params[:event]
    trip_identifier = params[:trip_identifier]
    
    $logger.debug "#{event} geofence with center (#{latitude}, #{longitude}) radius #{radius}"

    trip = Trip.first(:trip_identifier => trip_identifier)
    
    geofence = Geofence.create(:latitude   => latitude,
                               :longitude  => longitude,
                               :radius     => radius,
                               :event      => event,
                               :created_at => Time.now.to_s)
    
    trip.geofences << geofence
    trip.save!

    status 200

    return {:status =>  "ok"}.to_json
  end

  post '/trip' do

    trip_identifier = params[:trip_identifier]    

    $logger.debug "Creating new trip #{trip_identifier}"
    
    Trip.create(:trip_identifier => trip_identifier)

    status 200

    return {:status => "ok"}.to_json

  end

  get '/locations' do

    callback        = params[:callback]; # JSONP
    trip_identifier = params[:trip_identifier]

    puts trip_identifier
    
    trip = Trip.first(:trip_identifier => trip_identifier)

    status 200
    json = {:locations => trip.locations}.to_json

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
