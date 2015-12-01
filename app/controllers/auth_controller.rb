require './lib/http_request'

class AuthController < ApplicationController

  layout "auth"

  GITHUB_OAUTH = {
      :authorize_url => 'https://github.com/login/oauth/authorize',
      :access_token_url => 'https://github.com/login/oauth/access_token',
      :api_url => "https://api.github.com",
      :client_id => 'f8a5dc5a90cbc4668978',
      :client_secret => 'a093842ccb3f1cd0e1fa03609d262f7e6e9b284b',
      :callback_url => 'http://dev.com:3000/auth/github_callback',
      :redirect_url => 'http://dev.com:3000/automation_set'
  }

  def index
    unless session[:current_user].nil?
      redirect_to "/automation_set"
    end
  end

  def logout
    session[:current_user] = nil
    redirect_to root_url
  end

  def github
    redirect_url = "#{GITHUB_OAUTH[:authorize_url]}?client_id=#{GITHUB_OAUTH[:client_id]}&redirect_uri=#{GITHUB_OAUTH[:callback_url]}&"
    redirect_to redirect_url
  end

  def github_callback
    access_token = get_access_token params[:code]
    user = get_user_info(access_token)
    session[:current_user] = user
    redirect_to GITHUB_OAUTH[:redirect_url]
  end

  private
  def get_access_token code
    body = {
        code: code,
        redirect_uri: GITHUB_OAUTH[:redirect_url],
        client_id: GITHUB_OAUTH[:client_id],
        client_secret: GITHUB_OAUTH[:client_secret]
    }
    opts = {:method => :post,
            :url => GITHUB_OAUTH[:access_token_url],
            :body => body
    }
    response = Http::Request.request(opts)
    response.body.split("&")[0].split("=")[1]
  end

  def get_user_info access_token
    url = "#{GITHUB_OAUTH[:api_url]}/user?access_token=#{access_token}"
    opts = {:method => :get,
            :url => url
    }
    response = Http::Request.request(opts)
    body = JSON(response.body)
    {id: body['id'], login: body['login'], name: body['name'], avatar_url: body['avatar_url']}
  end
end
