require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader'
require 'bcrypt'

enable :session

get '/homepage' do
    



  slim(:homepage)
end


get '/register' do
  
  
  

  slim(:register)
end

post '/register' do
  
  user = params[:user]
  pwd = params[:pwd]
  pwd_confirm = params[:pwd_confirm]



  db = SQLite3::Database.new("db/databas.db")
  result=db.execute("SELECT id FROM users WHERE user=?" ,user)

  if result.empty?
    if pwd==pwd_confirm
      pwd_digest=BCrypt::Password.create(pwd)
      p user
      p pwd_digest
      db.execute("INSERT INTO users(user, pwd_digest) VALUES(?,?)",[user,pwd_digest])
      redirect('/homepage')
    else
      redirect('/error') #lösenord matchar ej
    end
  else
    redirect('/register') #user existerar redan
  end

  redirect '/homepage'
end


get '/login' do




  slim(:login)
end

post '/login' do
  user = params[:user]
  pwd = params[:pwd]
  
  db = SQLite3::Database.new("db/databas.db")
  db.results_as_hash = true
  result=db.execute("SELECT id,pwd_digest FROM users WHERE user=?" ,user)


  if result.empty?
    redirect('/error') #Fel
  end

  user_id = result.first["id"]
  pwd_digest = result.first["pwd_digest"]

  if BCrypt::Password.new(pwd_digest) == pwd
    session[:user_id] = user_id
    redirect('/homepage')
  else
    redirect('error')
  end
end