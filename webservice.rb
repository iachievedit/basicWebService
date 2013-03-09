require 'sinatra'
require 'dm-core'
require 'dm-sqlite-adapter'
require 'dm-migrations'
require 'json'

use Rack::Logger
$logger = Logger.new "log/webservice.log"

DataMapper::Logger.new("log/webservice.log", :debug)

DataMapper.setup(:default, 'sqlite3:webservice.db')

class Location
  include DataMapper::Resource

  property :id,       Serial
  property :latitude, Float
  property :longitude, Float
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
    $logger.debug "Well?"
    status 200
    return {status:  "ok"}.to_json
  end
  
end
