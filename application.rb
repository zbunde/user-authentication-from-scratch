require 'sinatra/base'
require 'bcrypt'


class Application < Sinatra::Application

  enable :sessions

  def initialize(app=nil)
    super(app)

    # initialize any other instance variables for you
    # application below this comment. One example would be repositories
    # to store things in a database.

  end

  user_table = DB[:users]


  get '/' do
    if session[:user_id]
      id = session[:user_id]
      email = user_table[:id => id][:email]
      erb :index, :locals => {:email => email}
    else
      erb :index
    end
  end

  get '/register' do
    erb :register
  end

  post '/' do
    encrypted_password = BCrypt::Password.create(params[:Password])

    id = user_table.insert(:email => params[:Email], :password => encrypted_password)

    session[:user_id] = id

    redirect '/'
  end


  get '/logout' do
    session[:user_id] = false
    redirect '/'
  end

  get '/login' do

    erb :login

  end

  post '/login' do
    user = user_table[email: params[:Email]]
    password = params[:Password]

    if BCrypt::Password.new(user[:password]) == password
      session[:user_id] = user[:id]

      redirect '/'
    else
      redirect '/'
    end
  end
end
