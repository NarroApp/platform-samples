require 'bundler/setup'
require 'sinatra'
require 'rest_client'
require 'json'

CLIENT_ID = ENV['NARRO_CLIENT_ID']
CLIENT_SECRET = ENV['NARRO_SECRET_ID']

use Rack::Session::Pool, :cookie_only => false

def authenticated?
  session[:access_token]
end

def authenticate!
  erb :index, :locals => {:client_id => CLIENT_ID}
end

get '/' do
  if !authenticated?
    authenticate!
  else
    access_token = session[:access_token]
    locals = {}

    begin
      articles = RestClient.get('https://www.narro.co/api/v1/articles',
                                    {:Authorization => 'Bearer ' + access_token,
                                    :accept => :json})
    rescue => e
      # request didn't succeed because the token was revoked so we
      # invalidate the token stored in the session and render the
      # index page so that the user can start the OAuth flow again

      session[:access_token] = nil
      return authenticate!
    end

    locals['articles'] = articles
    erb :details, :locals => locals
  end
end

get '/callback' do
  session_code = request.env['rack.request.query_hash']['code']

  result = RestClient.post('https://www.narro.co/oauth2/token',
                          {:client_id => CLIENT_ID,
                           :client_secret => CLIENT_SECRET,
                           :code => session_code},
                           :accept => :json)

  session[:access_token] = JSON.parse(result)['value']

  redirect '/'
end
