require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'sqlite3'

get('/')  do
  db = SQLite3::Database.new("db/q.db")
  db.results_as_hash = true
  
  random = db.execute("SELECT * FROM quizzes INNER JOIN quizzes_owners ON quizzes.id = quizzes_owners.quiz_id WHERE quizzes_owners.user_id = ? ORDER BY RANDOM() LIMIT 5")
  often = db.execute("SELECT * FROM quizzes INNER JOIN quizzes_owners ON quizzes.id = quizzes_owners.quiz_id WHERE quizzes_owners.user_id = ? AND ORDER BY (SELECT COUNT(*) FROM quizzes_completions WHERE quiz_id = quizzes.id AND date > ? LIMIT 1) DESC LIMIT 5")
  popular = db.execute("SELECT * FROM quizzes ORDER BY (SELECT COUNT(*) quizzes_likes WHERE quizzes_likes.quiz_id = quizzes.id LIMIT 1) DESC LIMIT 5")

  slim(:"index", locals: {random:random, often:often, popular:popular})
end

get('/quizzes') do

end

get('/user/:id') do

end

get('/user/:id/quizzes') do

end

get('/quiz/new') do
#   slim(:"albums/new")
end

post('/quiz/create') do
#   db = SQLite3::Database.new("db/chinook-crud.db")

#   title = params[:title]
#   artist_id = params[:artist_id]

#   db.execute("INSERT INTO albums (Title, ArtistId) VALUES (?,?)",title,artist_id)

#   redirect('/albums')
end

get('/quiz/:id') do
#   id = params[:id].to_i
#   db = SQLite3::Database.new("db/chinook-crud.db")
#   db.results_as_hash = true

#   result = db.execute("SELECT * FROM albums WHERE AlbumId = ?",id).first
#   result2 = db.execute("SELECT Name AS ArtistName FROM artists WHERE ArtistId IN (SELECT ArtistId FROM albums WHERE AlbumId = ?)",id).first
  
#   slim(:"albums/show",locals:{result:result,result2:result2})
end

post('/quiz/:id/delete') do
#   id = params[:id].to_i
#   db = SQLite3::Database.new("db/chinook-crud.db")

#   db.execute("DELETE FROM albums WHERE AlbumId = ?",id)
  
#   redirect('/albums')
end

get('/quiz/:id/edit') do
#   id = params[:id].to_i
#   db = SQLite3::Database.new("db/chinook-crud.db")
#   db.results_as_hash = true

#   result = db.execute("SELECT * FROM albums WHERE AlbumId = ?",id).first

#   slim(:"albums/edit",locals:{result:result})
end

post('/quiz/:id/update') do
#   id = params[:id].to_i
#   title = params[:title]
#   db = SQLite3::Database.new("db/chinook-crud.db")

#   db.execute("UPDATE albums SET Title = ? WHERE AlbumId = ?",title,id)
  
#   redirect('/albums')
end