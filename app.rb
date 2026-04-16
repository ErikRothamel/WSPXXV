require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader'
require 'bcrypt'

# Sinatra app configuration
set :session_secret, '34567897656787654567898765456788765445678765434567898765434567898765434567890987654387434567898765434567876543245678876543456789856787654345678765'

enable :sessions
# Enable session support for login state management


get '/homepage' do
  # Render the homepage view
  slim(:homepage)
end


get '/register' do
  # Show the registration form
  slim(:register)
end


post '/register' do
  # Get registration form parameters
  user = params[:user]
  pwd = params[:pwd]
  pwd_confirm = params[:pwd_confirm]

  # Open the SQLite database and verify unique username
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
  # Show the login form
  slim(:login)
end


post '/login' do
  # Authenticate user credentials
  user = params[:user]
  pwd = params[:pwd]
  
  db = SQLite3::Database.new("db/databas.db")
  db.results_as_hash = true
  result=db.execute("SELECT id,pwd_digest FROM users WHERE user=?" ,user)

  if result.empty?
    redirect('/error') # Fel
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
  # Load game page with current user funds and any win/loss message
  db = SQLite3::Database.new("db/databas.db")
  db.results_as_hash = true

  @funds = db.execute("SELECT funds FROM users WHERE id = ?", session[:user_id]).first["funds"]

  @win_message = session.delete(:win_message)
  slim :game
end


post '/game' do
  # Run a game round and update funds based on a random outcome
  user_id = session[:user_id]
  stake = params[:stake].to_i

  db = SQLite3::Database.new("db/databas.db")
  db.results_as_hash = true

  result = rand(1..3)

  if result != 1
    db.execute("UPDATE users SET funds = funds + ? WHERE id = ?", [stake*2, user_id])
    session[:win_message] = "Vinst!!"
  else
    db.execute("UPDATE users SET funds = funds - ? WHERE id = ?", [stake, user_id])
    session[:win_message] = "Förlust :("
  end

  redirect '/game'
end


get '/cash' do
  # Display cash deposit page with current user balance
  db = SQLite3::Database.new("db/databas.db")
  db.results_as_hash = true

  @funds = db.execute("SELECT funds FROM users WHERE id = ?", session[:user_id]).first["funds"]

  slim(:cash)
end


post '/cash' do
  # Add deposited cash to current user funds
  user_id = session[:user_id]
  cash = params[:cash]
  
  db = SQLite3::Database.new("db/databas.db")
  db.results_as_hash = true

  db.execute("UPDATE users SET funds = funds + 0 + ? WHERE id = ?", [cash, user_id])
  
  redirect '/cash'
end


get '/shop' do
  # Load available products that the current user has not yet purchased
  db = SQLite3::Database.new("db/databas.db")
  db.results_as_hash = true

  @productsarr = db.execute("SELECT * FROM products WHERE id NOT IN (SELECT product_id FROM user_product WHERE user_id = ?)", session[:user_id])
  slim(:shop)
end 


post '/shop' do
  redirect '/shop'
end


post '/buy' do
  # Handle product purchases if the user has sufficient funds
  product_id = params[:product_id]
  user_id = session[:user_id]

  db = SQLite3::Database.new("db/databas.db")
  db.results_as_hash = true

  price = db.execute("SELECT price FROM products WHERE id = ?", product_id).first["price"]
  funds = db.execute("SELECT funds FROM users WHERE id = ?", user_id).first["funds"]

  if funds >= price
    db.execute("INSERT INTO user_product(user_id, product_id) VALUES(?,?)", [user_id, product_id])
    db.execute("UPDATE users SET funds = funds - ? WHERE id = ?", [price, user_id])
    redirect '/shop'
  else
    redirect '/error'
  end
end

get '/delete_account' do
  # Show delete account confirmation page for current user
  db = SQLite3::Database.new("db/databas.db")
  db.results_as_hash = true

  @user = db.execute("SELECT user FROM users WHERE id = ?", session[:user_id]).first["user"]

  slim(:delete_account)
end

post '/delete_account' do
  # Delete the user's account after verifying their password
  user_id = session[:user_id]
  pwd = params[:pwd]

  db = SQLite3::Database.new("db/databas.db")
  db.results_as_hash = true

  result = db.execute("SELECT pwd_digest FROM users WHERE id = ?", user_id).first
  pwd_digest = result["pwd_digest"]

  if BCrypt::Password.new(pwd_digest) == pwd
    db.execute("DELETE FROM user_product WHERE user_id = ?", user_id)
    db.execute("DELETE FROM users WHERE id = ?", user_id)
    session.clear
    redirect '/register'
  else
    redirect '/error'
  end
end