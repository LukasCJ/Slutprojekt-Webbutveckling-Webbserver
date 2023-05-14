require_relative 'model.rb'
require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'json'

enable :sessions

include Model

# Locks pages for people who aren't logged in
#
# @session [Integer] user_id, The user's account's id
#
# @see Model#all_of
before do
  if request.get? # om det är en get-route
    if request.path_info != '/forms' # om det inte är sidan /forms
      if session[:user_id] == nil
        redirect('/forms')
      end
    else # om det är sidan /forms
      if session[:user_id] != nil
        redirect('/')
      end
    end
  end
end

# Locks page for everyone except admins
#
# @session [Integer] admin, 1 means user is admin, 0 means user is not admin
before('/all/*') do
  if session[:admin] != 1
    redirect('/')
  end
end

# Validates values before post signup
#
# @param [String] name, The name of the owner of the new user account
# @param [String] uid, Means unique identifier, A unique username for the new account
# @param [String] pwd, The password of the new account
# @param [String] pwd_confirm, Repeated password for validation
#
# @see Model#create_account
before('/signup') do
  if params[:uid] == "" || params[:name] == "" || params[:pwd] == "" || params[:pwd_confirm] == "" 
    redirect('/forms?error=field-empty');
  end
  if params[:pwd] != params[:pwd_confirm]
    redirect('/forms?error=pwd-match');
  end
  if params[:uid] !~ /^[a-zA-Z0-9]*$/
    redirect('/forms?error=faulty-uid');
  end
  if uid_taken(params[:uid]) != false
    redirect('/forms?error=uid-taken');
  end
end

# Validates values before post login
#
# @param [String] uid, Means unique identifier, A unique username for the new account
# @param [String] pwd, The password of the new account
#
# @see Model#check_login
before('/login') do
  if params[:uid] == "" || params[:pwd] == ""
    redirect('/forms?error=field-empty');
  end
  if params[:uid] !~ /^[a-zA-Z0-9]*$/
    redirect('/forms?error=faulty-uid');
  end
end

# Checks and updates cooldown for post-requests that aims to make a change in the database, and for login
#
# @session [Time] cool, for cool-down, the time of when a cool-down is over, used to block quick repeats of certain actions
before(all_of('/login', '/signup', '/quiz/create', '/quiz/*/update')) do
  if session[:cool] != nil && session[:cool] > Time.now
    path = request.path_info
    if path == '/login' || path == '/signup'
      redirect('/forms?error=cool-down')
    else
      redirect('/?error=cool-down')
    end
  end
end

# Sets cooldown after post-requests that aims to make a change in the database, and after login
#
# @session [Time] cool, for cool-down, the time of when a cool-down is over
after(all_of('/login', '/signup', '/quiz/create', '/quiz/*/update')) do
  session[:cool] = set_cooldown(session[:cool], Time.now)
end

# Display landing page
#
# @session [Integer] user_id, The id of the user's account on the databse, is asigned as session at login, If not defined the user is sent to page for login/signup
get('/') do
  quizzes = fetch_owned_quizzes(session[:user_id])
  if params[:error] != nil
    err = prep_error(params[:error], session[:cool])
    slim(:index, locals:{quizzes:quizzes, err:err})
  else
    slim(:index, locals:{quizzes:quizzes, err:'none'})
  end
end

# Display login/signup page
get('/forms') do
  if params[:error] != nil
    err = prep_error(params[:error], session[:cool])
    slim(:forms, locals:{err:err})
  else
    slim(:forms, locals:{err:'none'})
  end
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
  id = create_account(params)
  session[:user_id] = id
  session[:user_uid] = params[:uid]
  session[:admin] = 0
  redirect('/')
end

# Logs the user into account matching user-given information
#
# @param [String] uid, The given username
# @param [String] pwd, The given password
#
# @see Model#login
post('/login') do
  result = check_login(params[:uid], params[:pwd])
  if result == false
    redirect('/forms?error=faulty-login');
  end
  session[:user_id] = result['id']
  session[:user_uid] = result['uid']
  session[:admin] = result['admin']
  redirect('/')
end

# Logs the user out of the account they're logged into
post('/logout') do
  session[:user_id] = nil
  session[:user_uid] = nil
  session[:admin] = nil
  redirect('/')
end

# Display quiz-creator page
#
get('/quiz/new') do
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
  create_quiz(params)
  redirect('/')
end

# Prepare and send values for user-search on /quiz/new & /quiz/:id/edit
#
# @param [String] :for, What kind of thing we're searching for (in case we wwant to search for something else than users in the future)
# @param [String] :input, The input of the user, the search string for usernames
#
# @see Model#access_quiz
post('/quick-search') do 
  if request.xhr?
    case params[:for]
    when 'users'
      users = fetch_users(params[:current], params[:input])
      erb users.to_json
    else
      users = fetch_users(params[:current], params[:input])
      erb users.to_json
    end
  end
end

# Display quiz-player page
#
# @param [Integer] :id, The id of the quiz
# @session [Integer] user_id, The id of the visitor
#
# @see Model#access_quiz
get('/quiz/:id') do
  result = access_quiz(params[:id], {'id' => session[:user_id], 'admin' => session[:admin]})
  quiz = result['quiz']

  slim(:"quiz/index", locals:{access:result['access'], quiz:quiz})
end

# Display quiz-editor page
#
# @param [Integer] :id, The id of the quiz
# @session [Integer] user_id, The id of the visitor
#
# @see Model#access_quiz
# @see Model#prepare_edit
get('/quiz/:id/edit') do
  result = access_quiz(params[:id], {'id' => session[:user_id], 'admin' => session[:admin]})
  quiz = result['quiz']
  quiz['content_json'] = quiz['content'].to_json

  if result['access'] == 0
    redirect('/')
  else
    slim(:"quiz/edit", locals:{access:result['access'], quiz:quiz})
  end
end

# Updates quiz information
#
# @param [Integer] :id, The id of the quiz
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
  if params[:delete].to_i == 1
    delete_quiz(quiz_id)
  else
    update_quiz(quiz_id, params)
  end
  redirect('/')
end

# Page where admins can see all quizzes in database
# 
# @see Model#fetch_quizzes
get('/all') do
  quizzes = fetch_quizzes('')
  slim(:all, locals:{quizzes:quizzes})
end

# Allows admins to specify name of quizzes to see by writing a search-request in the url
#
# @param [String] :search, The search specifying the likes of the name of the quiz
# 
# @see Model#fetch_quizzes
get('/all/:search') do
  quizzes = fetch_quizzes(params[:search])
  slim(:all, locals:{quizzes:quizzes})
end