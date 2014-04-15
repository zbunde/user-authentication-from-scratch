require 'sinatra/base'

class Application < Sinatra::Application

  def initialize(app=nil)
    super(app)

    # initialize any other instance variables for you
    # application below this comment. One example would be repositories
    # to store things in a database.

  end

  user_table = DB[:users]
  user_array = user_table.to_a
  enable :sessions

  get '/' do
    erb :index, :locals => {user_array: user_table.to_a}
  end

  get '/register' do
    erb :register
  end

  post '/' do
    user_array.each do |hash|
      if hash[:email]== nil
        redirect '/'
      else
        user_table.insert({:email => params[:Email], :password => params[:Password]})
        session[:insert] = "Hello, #{hash[:email]}"
      end
    end
    erb :index
  end

end