require 'sinatra/base'
require 'bcrypt'


class Application < Sinatra::Application

  enable :sessions

    user_table = DB[:users]

  get '/' do
    id = session[:user_id]
    user = user_table.where(id: id).first

    erb :index, :locals => {user: user}
  end

  get '/register' do
    erb :register, :locals => {:error_message => nil}
  end

  post '/register' do
    password = params[:Password]
    email = params[:Email]

    if email.empty?
      erb :register, locals: {error_message: "Email cannot be blank"}
    elsif user_table[email: email]
      erb :register, locals: {error_message: "Email address already exists"}
    elsif password.empty?
      erb :register, locals: {error_message: "Password cannot be blank"}
    elsif password.length < 3
      erb :register, locals: {error_message: "Password must be longer than 2 characters"}
    elsif password != params[:Password_Confirmation]
      erb :register, locals: {error_message: "Password must match Password Confirmation"}
    elsif /[-0-9a-zA-Z.+_]+@[-0-9a-zA-Z.+_]+\.[a-zA-Z]{2,6}/.match(email).nil?
      erb :register, locals: {error_message: "Email must be valid"}
    else
      encrypted_password = BCrypt::Password.create(password)
      id = user_table.insert(:email => email, :password => encrypted_password)
      session[:user_id] = id
      redirect '/'
    end
  end

  get '/login' do
    erb :login, locals: {error_message: nil}
  end

  post '/login' do
    email = params[:Email]
    password = params[:Password]
    user = user_table.where(email: email).to_a.first

    if email.empty?
      erb :login, locals: {error_message: "Email must not be blank"}
    elsif user.nil?
      erb :login, locals: {error_message: "Invalid email or password"}
    elsif BCrypt::Password.new(user[:password]) == password
      session[:user_id] = user[:id]
      redirect '/'
    elsif  BCrypt::Password.new(user[:password]) != password
      erb :login, locals: {error_message: "Invalid email or password"}
    end
  end

  get '/logout' do
    session.clear
    redirect '/'
  end

  get '/users' do
    id = session[:user_id]
    user = user_table.where(id: id).to_a.first

    if user[:admin]
      erb :users, locals: {users: user_table.to_a}
    else
      erb :index, locals: {error_message: "You must be an admin to view this page"}
    end
  end
end
