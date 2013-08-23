require 'sinatra/base'
require 'oauth2'
require 'json'
require 'rack-flash'
require 'yaml'
require './helpers/init'

class App < Sinatra::Base
  set :views, File.expand_path('../views', File.dirname(__FILE__))
  set :static, true
  set :public_folder, 'public'
  enable :sessions
  use Rack::Flash, :sweep => true
  set :session_secret, "github_client" # shotgun bug

  configure :development, :test, :production do
    config = YAML::load(File.open('oauth_example.yml'))
    set :client_id, config['development']['client_id']
    set :secret, config['development']['secret']
  end

 # configure :production do
 #   set :client_id, ENV['client_id']
 #   set :secret, ENV['secret']
 # end

  before do
    if session[:access_token]
      get_user
    end
    # has_access
  end

  get '/' do
    p ENV
    # if session[:access_token]
    #   redirect '/list'
    # end
    erb :index
  end

  get '/list' do
    has_access
    get_repos
    load_more = request.env['rack.request.query_hash']['more']
    if load_more
      erb :repos, :layout => false
    else
      erb :list
    end
  end

  get '/auth/github' do
    url = client.auth_code.authorize_url(:redirect_uri => redirect_uri, :scope => 'public_repo')
    redirect url
  end

  get '/auth/github/callback' do
    token = get_token(params[:code])
    session[:access_token] = token unless token.empty?
    if session[:access_token]
      flash[:success] = "Log in successfully."
      redirect '/'
    else
      status 401
      halt %(<p>Please authorize on Github.</p><p><a href="/auth/github">Retry</a></p>)
    end
  end

  post '/unstarred/:user/:repo' do
    if params[:user] && params[:repo]
      unstarred_repo(params[:user], params[:repo])
      "Successfully unstarred #{params[:user]}/#{params[:repo]}."
    else
      halt 503, "Failed to unstarred the repository."
    end
  end

  post '/unwatch/:user/:repo' do
    if params[:user] && params[:repo]
      unwatch_repo(params[:user], params[:repo])
      "Successfully unwatched #{params[:user]}/#{params[:repo]}."
    else
      halt 503, "Failed to unwatch the repository."
    end
  end

  get '/about' do
    erb :about
  end

  get '/logout' do
    logout
  end

  get '/starred' do
    has_access
    get_starred_repos
  end
end
