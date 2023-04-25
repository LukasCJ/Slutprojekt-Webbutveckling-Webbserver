require_relative 'model.rb'
require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'json'

enable :sessions

include Model

# Display landing page
#
# @session [Integer] user_id, The id of the user's account on the databse, is asigned as session at login, If not defined the user is sent to page for login/signup
get('/') do
  check_logged_in(session[:user_id], false, '/forms')
  quizzes = fetch_owned_quizzes(session[:user_id])
  slim(:index, locals:{quizzes:quizzes})
end

# Display login/signup page
#
get('/forms') do
  check_logged_in(session[:user_id], true, '/')
  slim(:forms)
end

# Inserts a new user account into the database, logs the user into that account and redirects the user to landing page
#
# @param [String] name, The name of the owner of the new user account
# @param [String] uid, Means unique identifier, A unique username for the new account
# @param [String] pwd, The password of the new account
# @param [String] pwd_confirm, Repeated password for validation
#
# @see Model#create_account
post('/signup') do
  create_account(params)
  redirect('/')
end

# Logs the user into account matching user-given information
#
# @param [String] uid, The given username
# @param [String] pwd, The given password
#
# @see Model#login
post('/login') do
  login(params)
  redirect('/')
end

# Logs the user out of the account they're logged into
# 
post('/logout') do
  session[:user_id] = nil
  session[:user_uid] = nil
  redirect('/')
end

# Display quiz-creator page
#
get('/quiz/new') do
  check_logged_in(session[:user_id], false, '/forms')
  slim(:"quiz/new")
end

# Inserts a new quiz into the database based on user-given information (modified through script.js)
#
# @param [String] name, The name of the quiz
# @param [String] desc, A description of the quiz
# @param [String] content, A stringified JSON array containing JSON hashes containing all information about every question and every answer
# @param [String] owners, The username or ids of the users owning the quiz, separated by commas
# @session [Integer] user_id, The id of the creator
#
# @see Model#create_quiz
post('/quiz/create') do
  create_quiz(params, session[:user_id])
  redirect('/')
end

# Display quiz-player page
# Corrent state: only really shows whether you own the quiz or not
# Meant to allow you to play the quiz
#
# @param [Integer] id, The id of the quiz
# @session [Integer] user_id, The id of the visitor
#
# @see Model#access_quiz
get('/quiz/:id') do
  check_logged_in(session[:user_id], false, '/forms')
  
  result = access_quiz(params[:id], session[:user_id])
  access = result['access']
  quiz = result['quiz']

  slim(:"quiz/index", locals:{access:access, quiz:quiz})
end

# Display quiz-editor page
#
# @param [Integer] id, The id of the quiz
# @session [Integer] user_id, The id of the visitor
#
# @see Model#access_quiz
# @see Model#prepare_edit
get('/quiz/:id/edit') do
  check_logged_in(session[:user_id], false, '/forms')

  result = access_quiz(params[:id], session[:user_id])
  access = result['access']
  quiz = prepare_edit(result['quiz'])

  slim(:"quiz/edit", locals:{access:access, quiz:quiz})
end

# Updates quiz information
# Current state: doesn't work
#
# @param [Integer] id, The id of the quiz
# @param [Integer] delete, Defined as 1 if the quiz should be deleted
# @param [String] name, The name of the quiz
# @param [String] desc, A description of the quiz
# @param [String] content, A stringified JSON array containing JSON hashes containing all information about every question and every answer
# @param [String] owner_changed, Defined as true if the owner field has changed, otherwise undefined
# @param [String] owners, The username or ids of the users owning the quiz, separated by commas
# @session [Integer] user_id, The id of the visitor
# 
# @see Model#update_quiz
post('/quiz/:id/update') do # används för både update (inklusive add owner) & delete
  quiz_id = params[:id].to_i

  db = conn("db/q.db")
  if params[:delete].to_i == 1
    delete_quiz(db, quiz_id)
  else
    update_quiz(db, quiz_id, params, session[:user_id])
  end
  db.close
  redirect('/')
end