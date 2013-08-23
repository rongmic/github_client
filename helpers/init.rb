def client
  if !session[:access_token]
    @auth_client ||= OAuth2::Client.new(settings.client_id, settings.secret, :site => 'https://github.com', :authorize_url => '/login/oauth/authorize', :token_url => '/login/oauth/access_token')
  else
    @api_client ||= OAuth2::Client.new(settings.client_id, settings.secret, :site => 'https://api.github.com')
  end
end

def has_access
  unless session[:access_token]
    flash[:warning] = "You should log in."
    redirect '/'
  end
end

def login?
  true unless session[:access_token].nil?
end

def access_token
  @access_token ||= OAuth2::AccessToken.new(client, session[:access_token])
end

def headers
  {'Accept' => 'application/vnd.github.v3+json'}
end

def send_request(uri, method='get')
  begin
    oauth_response = access_token.send(method, uri)
    JSON.parse(oauth_response.body) unless oauth_response.body.empty?
  rescue OAuth2::Error => e
    session[:accession] = nil
    status 503
    puts e.inspect
    halt %(<p>#{$!}</p><p><a href="/auth/github">Retry</a></p>)
  end
end

def redirect_uri(path = '/auth/github/callback', query = nil)
  uri = URI.parse(request.url)
  uri.path = path
  uri.query = query
  uri.to_s
end

def get_user
  if session[:user].nil?
    @user = session[:user] = send_request('/user')
  else
    @user = session[:user]
  end
end

def get_repos
  @page = request.env['rack.request.query_hash']['page']
  param = request.env['rack.request.query_hash']
  if param.has_key?('starred')
    @repos = get_starred_repos
  else
    @repos = get_watched_repos
  end
end

def watched_repos
  page, res, results = 1, [], []
  begin
    res = send_request("/users/#{@user['login']}/watched?page=#{page}")
    results.concat res
    page += 1
  end while !res.empty?
  results
end

def unstarred_repo(user, repo)
  # true
  send_request("/user/watched/#{user}/#{repo}", 'delete')
end

def unwatch_repo(user, repo)
  send_request("/user/subscriptions/#{user}/#{repo}", 'delete')
end

def get_token(code)
  client.auth_code.get_token(code, :redirect_uri => redirect_uri).token
end

def nav_active?(path)
  true if path == request.path_info
end

def flash_types
  [:success, :info, :warning, :error]
end

def logout
  session[:access_token], session[:user] = nil, nil
  flash[:success] = "You have logouted successfully."
  redirect '/'
end

def get_starred_repos
  send_request("/users/#{@user['login']}/starred?page=#{@page}")
end

def get_watched_repos
  send_request("/users/#{@user['login']}/subscriptions?page=#{@page}")
end

def repos_starred?
  param = request.env['rack.request.query_hash']
  true if param.has_key? 'starred'
end
