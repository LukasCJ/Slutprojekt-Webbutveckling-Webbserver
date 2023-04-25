module Model

    # Connects to the database
    #
    # @param [String] path, Describes path to database file
    #
    # @return [SQLite3::Database] the server's main database
    def conn(path)
        db = SQLite3::Database.new(path)
        db.results_as_hash = true
        return db
    end

    # Prepares a collection of strings to be used with one before-block
    #
    # @params [String] routes, Describes routes to prepare for before-block
    #
    # @return [String] string of multiple routes to be used with one before-block
    def all_of(*routes)
        return strings.join("|")
    end

    # Creates an account and logs user in
    #
    # @param [Hash] params, Form data
    # @option params [String] name, The name of the owner of the new user account
    # @option params [String] uid, A unique username for the new account
    # @option params [String] pwd, The password of the new account
    # @option params [String] pwd_confirm, Repeated password for validation
    def create_account(params)
        name = params[:name]
        uid = params[:uid] # todo: skapa validering som kollar om användarnamnet redan finns
        pwd = params[:pwd]
        pwd_confirm = params[:pwd_confirm]
      
        if pwd == pwd_confirm
        
            pwdigest = BCrypt::Password.create(pwd)
        
            db = conn("db/q.db")
            query = "INSERT INTO users (name, uid, pwdigest) VALUES (?, ?, ?) RETURNING id"
            id = db.execute(query, name, uid, pwdigest).first['id']
            db.close

            p id

            session[:user_id] = id
            session[:user_uid] = uid
        else
            puts "Lösenorden matchar inte."
            redirect('/forms?error=pwdmatch')
        end
    end

    # Logs user in
    #
    # @param [Hash] params, Form data
    # @option params [String] uid, The unique account username
    # @option params [String] pwd, The password of the account
    def login(params)
        if params[:uid] == nil || params[:pwd] == nil
            puts "Angiven data inte fullständig."
            redirect('/forms?error=empty')
        end
        
        uid = params[:uid]
        pwd = params[:pwd]
        
        db = conn("db/q.db")
        query = "SELECT * FROM users WHERE uid = ? LIMIT 1"
        result = db.execute(query, uid).first
        db.close
        
        if result
        
            pwdigest = result['pwdigest']
        
            if BCrypt::Password.new(pwdigest) == pwd
                session[:user_id] = result['id']
                session[:user_uid] = result['uid']
                session[:admin] = result['admin']
            else
                puts "Fel lösenord."
                redirect('/forms?error=wrongpwd')
            end
        else
            puts "Fel användarnamn."
            redirect('/forms?error=wrongusername')
        end
    end

    # Fetches the quizzes that the user owns
    #
    # @param [Integer] user_id, The id of account whose quizzes should be fetched
    #
    # @return [Array] containing the data of all owned quizzes
    def fetch_owned_quizzes(user_id)
        db = conn("db/q.db")
        query = "SELECT quizzes.* FROM quizzes INNER JOIN quizzes_owners ON quizzes_owners.quiz_id = quizzes.id WHERE quizzes_owners.user_id = ? ORDER BY quizzes.id DESC"
        quizzes = db.execute(query, user_id)
        db.close
        return quizzes
    end

    # Checks if the user has access to a quiz, and fetches the data of that quiz if they do
    #
    # @param [Integer] quiz_id, The id of the quiz
    # @param [Integer] user_id, The id of the user
    #
    # @return [Hash] containing all the data of the quiz
    def access_quiz(quiz_id, user)
    
        db = conn("db/q.db")
        query = "SELECT * FROM quizzes WHERE id = ? LIMIT 1"
        quiz = db.execute(query, quiz_id).first
        query = "SELECT users.id, users.uid, quizzes_owners.creator FROM users INNER JOIN quizzes_owners ON quizzes_owners.user_id = users.id WHERE quizzes_owners.quiz_id = ?"
        quiz['owners'] = db.execute(query, quiz_id)
    
        if user['admin'] == 1
            access = true
        else
            access = false
            quiz['owners'].each do |owner|
                if owner['id'] == user['id']
                    access = true
                end
            end
        end
    
        query = "SELECT * FROM questions WHERE quiz_id = ?"
        questions = db.execute(query, quiz_id)
        query = "SELECT answers.* FROM answers INNER JOIN questions ON questions.id = answers.question_id WHERE questions.quiz_id = ?"
        answers = db.execute(query, quiz_id)
        p "answers from sql: #{answers}"
    
        db.close
    
        quiz['content'] = []
        questions.each do |question|
            q = {}
            q['answers'] = []
            q['id'], q['text'] = question['local_id'], question['text']
            answers.each do |answer|
                if answer['question_id'] == question['id']
                    a = {}
                    a['id'], a['text'], a['correct'] = answer['local_id'], answer['text'], answer['correct']
                    q['answers'] << a
                end
            end
            quiz['content'] << q
        end
    
        return {'access' => access, 'quiz' => quiz}
    end

    # Creates a quiz in the database
    #
    # @param [Hash] params, The form data
    # @option params [String] name, The name of the quiz
    # @option params [String] desc, A description of the quiz
    # @option params [String] content, A stringified JSON array containing the data of every question and every answer
    # @option params [String] owners, The username or ids of the users owning the quiz, separated by commas
    # @param [Integer] creator_id, The id of the creator
    def create_quiz(params, creator_id)
        content = JSON.parse(params[:content])
        owners = params[:owners].split(',').map(&:lstrip) # delar in strängen i en array utefter komma-tecken mellan användarnamnen, tar sedan bort whitespace i början och slutet av varje element
        
        # validering
        # p "content: #{content}"
        # content.each do |q|
        #     if content['text'].class != String || content['text'].length == 0
        #         redirect('/quiz/new?error="no-question"')
        #     end
        #     if content['text'].class != String || content['text'].length == 0
        #         redirect('/quiz/new?error="no-question"')
        #     end

        db = conn("db/q.db")
        query = "INSERT INTO quizzes (name, desc) VALUES (?, ?) RETURNING id"
        quiz_id = db.execute(query, params[:name], params[:desc]).first['id']

        q_query = "INSERT INTO questions (quiz_id, local_id, text) VALUES (?, ?, ?) RETURNING id"
        a_query = "INSERT INTO answers (question_id, local_id, text, correct) VALUES (?, ?, ?, ?)"
        content.each do |q| # q - question
            question_id = db.execute(q_query, quiz_id, q['id'], q['text']).first['id']
            q['answers'].each do |a|
                db.execute(a_query, question_id, a['id'], a['text'], a['correct'])
            end
        end

        query = "INSERT INTO quizzes_owners (quiz_id, user_id, creator) VALUES (?, ?, ?)"
        db.execute(query, quiz_id, creator_id, 1)
        query2 = "SELECT id FROM users WHERE uid = ? LIMIT 1"
        owners.each do |o| 
            if o.length > 0
                if o.scan(/\D/).empty? # om det endast finns siffror i strängen
                    user_id = o.to_i
                else
                    user_id = db.execute(query2, o).first['id']
                end

                if (user_id != nil) && (user_id != creator_id)
                    db.execute(query, quiz_id, user_id, 0)
                end
            end
        end

        db.close
    end

    # Prepares a quiz-values for edit-page
    #
    # @param [Hash] quiz, The quiz data from access_quiz
    # @option quiz [Array] content, The data of the questions and answers
    # @option quiz [Array] owners, The owners of the quiz
    #
    # @return [Hash] containing both input and the newly prepared data
    def prepare_edit(quiz) 
        quiz['content_json'] = quiz['content'].to_json

        quiz['owner_str'] = ""
        last = quiz['owners'].length-1
        quiz['owners'].each_with_index do |owner, i|
      
            if owner['creator'] == 1
                owner['uid'] += '*'
            end
        
            if i != last
                owner['uid'] += ', '
            end
            
            quiz['owner_str'] += owner['uid']
        end
        return quiz
    end

    # Updates quiz data in database
    #
    # @param [Hash] params, The form data
    # @option params [String] id, The id of the quiz
    # @option params [Integer] delete, Defined as 1 if the quiz should be deleted
    # @option params [String] name, The name of the quiz
    # @option params [String] desc, A description of the quiz
    # @option params [String] content, A stringified JSON array containing the data of every question and every answer
    # @option params [String] owner_changed, Defined as true if the owner field has changed, otherwise undefined
    # @option params [String] owners, The username or ids of the users owning the quiz, separated by commas
    # @param [Hash] editor
    # @option editor [Integer] id, The id of the editor
    # @option editor [Integer] uid, The unique username of the editor
    def update_quiz(db, quiz_id, params, editor_id)       

        p "name: #{params[:name]}"
        query = "UPDATE quizzes SET name = ?, desc = ? WHERE id = ?"
        db.execute(query, params[:name], params[:desc], quiz_id)
    
        p "content: #{params[:content]}"
        if params[:content] != nil # om frågor och svar är uppdaterade. använder delete och insert eftersom det är enklare än att kolla exakt vilka frågor som är uppdaterade eller borttagna eller om ordningen på dem är ändrade och sedan anpassa en update query utefter det

            query = "DELETE FROM questions WHERE quiz_id = ?"
            db.execute(query, quiz_id)
            query = "DELETE FROM answers WHERE answers.question_id IN (SELECT questions.id FROM questions WHERE questions.quiz_id = ?)"
            db.execute(query, quiz_id)
        
            q_query = "INSERT INTO questions (quiz_id, local_id, text) VALUES (?, ?, ?) RETURNING id"
            a_query = "INSERT INTO answers (question_id, local_id, text, correct) VALUES (?, ?, ?, ?)"
            content = JSON.parse(params[:content])
            content.each do |q| # q - question
                question_id = db.execute(q_query, quiz_id, q['id'], q['text']).first['id']
                q['answers'].each do |a|
                    p "question_id: #{question_id}"
                    db.execute(a_query, question_id, a['id'], a['text'], a['correct'])
                end
            end
        end
        
        if params[:owners_changed] == "true"
            
            query = "DELETE FROM quizzes_owners WHERE quiz_id = ?"
            db.execute(query, quiz_id)
            query = "INSERT INTO quizzes_owners (quiz_id, user_id, creator) VALUES (?, ?, ?)"
            db.execute(query, quiz_id, editor_id, 1)
            
            owners = params[:owners].split(',').map(&:lstrip) # separerar sträng till array och tar bort whitespace i slut och början på varje element
            owners.each do |o| # o - owner
                if o[-1] == "*"
                    o.chop! # tar bort sista tecknet i sträng, dvs. "*"
                    find_id_query = "SELECT id FROM users WHERE uid = ? LIMIT 1"
                    user_id = db.execute(find_id_query, o).first['id']
                    if user_id != editor_id
                        db.execute(query, quiz_id, user_id, 1)
                    end
                else
                    find_id_query = "SELECT id FROM users WHERE uid = ? LIMIT 1"
                    user_id = db.execute(find_id_query, o).first['id']
                    if user_id != editor_id
                        db.execute(query, quiz_id, user_id, 0)
                    end
                end
            end
        end
    end

    def delete_quiz(db, quiz_id)
        query = "DELETE FROM answers WHERE question_id IN (SELECT id FROM questions WHERE quiz_id = ?)"
        db.execute(query, quiz_id)
        query = "DELETE FROM questions WHERE quiz_id = ?"
        db.execute(query, quiz_id)
        query = "DELETE FROM quizzes WHERE id = ?"
        db.execute(query, quiz_id)
        query = "DELETE FROM quizzes_owners WHERE quiz_id = ?"
        db.execute(query, quiz_id)
    end

    # Fetches all quizzes that matches search (truly all if search = nil)
    #
    # @param [String] search, User's search for quizzes
    #
    # @return [Array] containing the data of all fetched quizzes
    def fetch_all_quizzes(search)
        db = conn("db/q.db")
        query = "SELECT * FROM quizzes WHERE name LIKE %?% ORDER BY RANDOM()"
        quizzes = db.execute(query, search)
        db.close
        return quizzes
    end
end