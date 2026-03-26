require 'sqlite3'

db = SQLite3::Database.new("databas.db")


def seed!(db)
  puts "Using db file: db/todos.db"
  puts "🧹 Dropping old tables..."
  drop_tables(db)
  puts "🧱 Creating tables..."
  create_tables(db)
  puts "🍎 Populating tables..."
  populate_tables(db)
  puts "✅ Done seeding the database!"
end

def drop_tables(db)
  db.execute('DROP TABLE IF EXISTS exempel')
  db.execute('DROP TABLE IF EXISTS users')
  db.execute('DROP TABLE IF EXISTS products')
  db.execute('DROP TABLE IF EXISTS user_product')
end

def create_tables(db)
  db.execute('CREATE TABLE exempel (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL, 
              description TEXT,
              state BOOLEAN)')
  db.execute('CREATE TABLE users (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              user TEXT NOT NULL, 
              pwd_digest TEXT NOT NULL,
              funds INTEGER)')
  db.execute('CREATE TABLE products(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              description TEXT,
              price INTEGER NOT NULL
              )')
  db.execute('CREATE TABLE user_product(
              user_id INTEGER NOT NULL,
              product_id INTEGER NOT NULL)')
end

def populate_tables(db)
  db.execute('INSERT INTO exempel (name, description, state) VALUES ("Köp mjölk", "3 liter mellanmjölk, eko",false)')
  db.execute('INSERT INTO exempel (name, description, state) VALUES ("Köp julgran", "En rödgran",false)')
  db.execute('INSERT INTO exempel (name, description, state) VALUES ("Pynta gran", "Glöm inte lamporna i granen och tomten",false)')


  db.execute('INSERT INTO products (name, description, price) VALUES ("grön färg", "grön färg", 10)')
  db.execute('INSERT INTO products (name, description, price) VALUES ("blå färg", "blå färg", 100)')
  db.execute('INSERT INTO products (name, description, price) VALUES ("röd färg", "röd färg", 1000)')
  db.execute('INSERT INTO products (name, description, price) VALUES ("gul färg", "gul färg", 10000)')
  db.execute('INSERT INTO products (name, description, price) VALUES ("orange färg", "orange färg", 100000)')
end

seed!(db)