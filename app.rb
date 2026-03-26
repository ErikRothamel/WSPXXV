require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader'
require 'bcrypt'

set :session_secret, '34567897656787654567898765456788765445678765434567898765434567898765434567890987654387434567898765434567876543245678876543456789856787654345678765'

enable :sessions


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
      db.execute("INSERT INTO users(user, pwd_digest,funds) VALUES(?,?,?)",[user,pwd_digest,0])
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


get '/game' do
  @win_message = session.delete(:win_message)  # hämtar meddelandet och tar bort det
  slim :game
end



post '/game' do
  user = params[:user]
  stake = params[:stake].to_i

  db = SQLite3::Database.new("db/databas.db")
  db.results_as_hash = true

  result = rand(1..3)

  if result != 1
    db.execute("UPDATE users SET funds = funds + ? WHERE user = ?", [stake*2, user])
    session[:win_message] = "Vinst!!"
  else
    db.execute("UPDATE users SET funds = funds - ? WHERE user = ?", [stake, user])
    session[:win_message] = "Förlust :("
  end

  redirect '/game'
end


get '/cash' do





  slim(:cash)
end


post '/cash' do
  user = params[:user] #hitta user (via sessions(?))
  cash = params[:cash]
  
  db = SQLite3::Database.new("db/databas.db")

  db.results_as_hash = true

  db.execute("UPDATE users SET funds = funds + 0 + ? WHERE user = ?", [cash, user])
  
  redirect '/cash'
end


get '/shop' do
  db = SQLite3::Database.new("db/databas.db")
  db.results_as_hash = true

  @productsarr = db.execute("SELECT * FROM products")



  slim(:shop)
end 


post '/shop' do
  





  redirect '/shop'
end


post '/buy' do
  product_id = params[:id]
  user_id = session[:user_id]

  db = SQLite3::Database.new("db/databas.db")
  db.execute("INSERT INTO user_product(user_id, product_id) VALUES(?,?)",[user_id, product_id])



  redirect '/shop'
end