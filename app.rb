require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'sqlite3'
require 'bcrypt'

enable :sessions

def conn(path)
  db = SQLite3::Database.new(path)
  db.results_as_hash = true
  return db
end

def sql_select(db, columns, from, join, where, values, order, limit)
  sql = "SELECT " + columns + " FROM " + from + " " + join + " WHERE " + where + " ORDER BY " + order + " LIMIT " + limit
  puts "Query: #{sql}"
  return db.execute(sql, *values)
end

get('/') do
  if(session[:user_id] == nil)
    redirect('/forms')
  else
    db = conn("db/q.db")
    join = "INNER JOIN quizzes_owners ON quizzes_owners.quiz_id = quizzes.id"
    quizzes = sql_select(db, "*", "quizzes", join, "quizzes_owners.user_id = ?", [session[:user_id].to_s], "id DESC", "10")
    puts "Result: #{quizzes}"
    db.close
    slim(:index, locals:{quizzes:quizzes, session:session})
  end
end

get('/forms') do
  slim(:forms)
end

post('/signup') do
  name = params[:name]
  uid = params[:uid]
  pwd = params[:pwd]
  pwd_confirm = params[:pwd_confirm]

  if pwd == pwd_confirm

    pwdigest = BCrypt::Password.create(pwd)

    db = conn("db/q.db")
    db.execute('INSERT INTO users (name, uid, pwdigest) VALUES (?, ?, ?)', name, uid, pwdigest)
    db.close

    redirect('/')
  else
    puts "Lösenorden matchar inte."
    redirect('/forms?error=pwdmatch')
  end
end

post('/login') do
  if params[:uid] == nil || params[:pwd] == nil
    puts "Fel användarnamn."
    redirect('/forms?error=wrongusername')
  end

  uid = params[:uid]
  pwd = params[:pwd]

  db = conn("db/q.db")
  result = db.execute('SELECT * FROM users WHERE uid = ?', uid).first
  db.close

  if result

    pwdigest = result['pwdigest']

    if BCrypt::Password.new(pwdigest) == pwd
      session[:user_id] = result['id']
      session[:user_uid] = result['uid']
      redirect('/')
    else
      puts "Fel lösenord."
      redirect('/forms?error=wrongpwd')
    end
  else
    puts "Fel användarnamn."
    redirect('/forms?error=wrongusername')
  end
end

post('/logout') do
  session[:user_id] = nil
  redirect('/')
end

get('/quiz/new') do
  slim(:"quiz/new")
end

get('/quiz/new') do
  slim(:"quiz/new")
end

post('/quiz') do # create
  redirect('/')
end

get('/quiz/:id') do
  id = params[:id]

  db = conn("db/q.db")
  quiz = sql_select(db, "*", "quizzes", "", "quizzes.id = ?", [id.to_s], "id DESC", "1")
  owners = sql_select(db, "*", "quizzes_owners", "", "quizzes_owners.quiz_id = ?", [id.to_s], "id DESC", "")
  puts "Result: #{quizzes}"
  db.close

  case quiz[]
  access = 

  slim(:"quiz/index", locals:{id:id})
end

get('/quiz/:id/edit') do
  slim(:"quiz/index/edit")
end

post('/quiz/:id/update') do # används för både update & delete, inklusive add collaborator
  redirect('/')
end

# get('/quizzes') do

# end

# get('/user/:id') do

# end

# get('/user/:id/quizzes') do

# end



# post('/quiz/create') do
# #   db = SQLite3::Database.new("db/chinook-crud.db")

# #   title = params[:title]
# #   artist_id = params[:artist_id]

# #   db.execute("INSERT INTO albums (Title, ArtistId) VALUES (?,?)",title,artist_id)

# #   redirect('/albums')
# end

# get('/quiz/:id') do
# #   id = params[:id].to_i
# #   db = SQLite3::Database.new("db/chinook-crud.db")
# #   db.results_as_hash = true

# #   result = db.execute("SELECT * FROM albums WHERE AlbumId = ?",id).first
# #   result2 = db.execute("SELECT Name AS ArtistName FROM artists WHERE ArtistId IN (SELECT ArtistId FROM albums WHERE AlbumId = ?)",id).first
  
# #   slim(:"albums/show",locals:{result:result,result2:result2})
# end

# post('/quiz/:id/delete') do
# #   id = params[:id].to_i
# #   db = SQLite3::Database.new("db/chinook-crud.db")

# #   db.execute("DELETE FROM albums WHERE AlbumId = ?",id)
  
# #   redirect('/albums')
# end

# get('/quiz/:id/edit') do
# #   id = params[:id].to_i
# #   db = SQLite3::Database.new("db/chinook-crud.db")
# #   db.results_as_hash = true

# #   result = db.execute("SELECT * FROM albums WHERE AlbumId = ?",id).first

# #   slim(:"albums/edit",locals:{result:result})
# end

# post('/quiz/:id/update') do
# #   id = params[:id].to_i
# #   title = params[:title]
# #   db = SQLite3::Database.new("db/chinook-crud.db")

# #   db.execute("UPDATE albums SET Title = ? WHERE AlbumId = ?",title,id)
  
# #   redirect('/albums')
# end