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
        return routes.join("|")
    end

    # Checks if username given on signup (and login) is taken
    #
    # @params [String] uid, The given username
    #
    # @return [Any] result of query if a match is found, else false
    def uid_taken(uid)

        db = conn("db/q.db")
        query = "SELECT * FROM users WHERE uid = ? LIMIT 1"
        result = db.execute(query, uid).first
        db.close

        if result
            return result
        end
        return false
    end

    # Validates username and password given on login
    #
    # @params [String] uid, The given username
    # @params [String] pwd, The given passwprd
    #
    # @return [Any] result of query if information is valid, else false
    #
    # @see Model#uid_taken
    def check_login(uid, pwd)

        result = uid_taken(uid)

        if result != false
            pwdigest = result['pwdigest']
            if BCrypt::Password.new(pwdigest) == pwd
                return result
            end
        end
        return false
    end

    # Creates an account for the user
    #
    # @param [Hash] params, Form data
    # @option params [String] name, The name of the owner of the new user account
    # @option params [String] uid, A unique username for the new account
    # @option params [String] pwd, The password of the new account
    def create_account(params)
        name = params[:name]
        uid = params[:uid]
        pwd = params[:pwd]
        pwdigest = BCrypt::Password.create(pwd)
    
        db = conn("db/q.db")
        query = "INSERT INTO users (name, uid, pwdigest) VALUES (?, ?, ?) RETURNING id"
        id = db.execute(query, name, uid, pwdigest).first['id']
        db.close

        return id
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
            access = 2
        else
            access = 0
            quiz['owners'].each do |owner|
                if owner['id'] == user['id']
                    if owner['creator'] == 1
                        access = 2
                    else
                        access = 1
                    end
                end
            end
        end
    
        query = "SELECT * FROM questions WHERE quiz_id = ?"
        questions = db.execute(query, quiz_id)
        query = "SELECT answers.* FROM answers INNER JOIN questions ON questions.id = answers.question_id WHERE questions.quiz_id = ?"
        answers = db.execute(query, quiz_id)
    
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
    # @option params [Array] owners, The username or ids of the users owning the quiz, separated by commas
    # @param [Integer] creator_id, The id of the creator
    def create_quiz(params)
        content = JSON.parse(params[:content])
        owners = JSON.parse(params[:owners])

        db = conn("db/q.db")
        query = "INSERT INTO quizzes (name, desc) VALUES (?, ?) RETURNING id"
        quiz_id = db.execute(query, params[:name], params[:desc]).first['id']

        q_query = "INSERT INTO questions (quiz_id, local_id, text) VALUES (?, ?, ?) RETURNING id"
        a_query = "INSERT INTO answers (question_id, local_id, text, correct) VALUES (?, ?, ?, ?)"
        content.each do |q|
            question_id = db.execute(q_query, quiz_id, q['id'], q['text']).first['id']
            q['answers'].each do |a|
                db.execute(a_query, question_id, a['id'], a['text'], a['correct'])
            end
        end

        query = "INSERT INTO quizzes_owners (quiz_id, user_id, creator) VALUES (?, (SELECT id FROM users WHERE uid = ? LIMIT 1), ?)"
        owners.each do |o|
            if o[-1] == "*"
                o.chop! # tar bort sista tecknet i sträng, dvs. "*"
                db.execute(query, quiz_id, o, 1)
            else
                db.execute(query, quiz_id, o, 0)
            end
        end
        db.close
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
    def update_quiz(quiz_id, params)       

        db = conn("db/q.db")
        query = "UPDATE quizzes SET name = ?, desc = ? WHERE id = ?"
        db.execute(query, params[:name], params[:desc], quiz_id)
    
        if params[:content] != nil # om frågor och svar är uppdaterade. använder delete och insert eftersom det är enklare än att kolla exakt vilka frågor som är uppdaterade eller borttagna eller om ordningen på dem är ändrade och sedan anpassa en update query utefter det

            query = "DELETE FROM questions WHERE quiz_id = ?"
            db.execute(query, quiz_id)
            query = "DELETE FROM answers WHERE answers.question_id IN (SELECT questions.id FROM questions WHERE questions.quiz_id = ?)"
            db.execute(query, quiz_id)
        
            q_query = "INSERT INTO questions (quiz_id, local_id, text) VALUES (?, ?, ?) RETURNING id"
            a_query = "INSERT INTO answers (question_id, local_id, text, correct) VALUES (?, ?, ?, ?)"
            content = JSON.parse(params[:content])
            content.each do |q|
                question_id = db.execute(q_query, quiz_id, q['id'], q['text']).first['id']
                q['answers'].each do |a|
                    db.execute(a_query, question_id, a['id'], a['text'], a['correct'])
                end
            end
        end
        
        if params[:owners] != nil
            
            query = "DELETE FROM quizzes_owners WHERE quiz_id = ?"
            db.execute(query, quiz_id)
            owners = JSON.parse(params[:owners])
            
            query = "INSERT INTO quizzes_owners (quiz_id, user_id, creator) VALUES (?, (SELECT id FROM users WHERE uid = ?), ?)"
            owners.each do |o|
                if o[-1] == "*"
                    o.chop! # tar bort sista tecknet i sträng, dvs. "*"
                    db.execute(query, quiz_id, o, 1)
                else
                    db.execute(query, quiz_id, o, 0)
                end
            end
        end
        db.close
    end

    # Deletes quiz and rows of other tables related to it
    #
    # @param [SQLite3::Database] db, The database
    # @param [Integer] quiz_id, The id for the quiz to be deleted
    def delete_quiz(quiz_id)
        db = conn("db/q.db")
        query = "DELETE FROM answers WHERE question_id IN (SELECT id FROM questions WHERE quiz_id = ?)"
        db.execute(query, quiz_id)
        query = "DELETE FROM questions WHERE quiz_id = ?"
        db.execute(query, quiz_id)
        query = "DELETE FROM quizzes WHERE id = ?"
        db.execute(query, quiz_id)
        query = "DELETE FROM quizzes_owners WHERE quiz_id = ?"
        db.execute(query, quiz_id)
        db.close
    end

    # Fetches all quizzes that matches search (truly all if search = nil)
    #
    # @param [String] search, User's search for quizzes
    #
    # @return [Array] containing the data of all fetched quizzes
    def fetch_quizzes(search)
        db = conn("db/q.db")
        sub_query = "SELECT uid FROM users INNER JOIN quizzes_owners ON quizzes_owners.user_id = users.id WHERE quizzes_owners.quiz_id = quizzes.id LIMIT 1"
        if search == ''
            query = "SELECT *, (#{sub_query}) AS creator FROM quizzes ORDER BY RANDOM() LIMIT 50"
            quizzes = db.execute(query)
        else
            query = "SELECT *, (#{sub_query}) AS creator FROM quizzes WHERE name LIKE ? ORDER BY RANDOM() LIMIT 50"
            quizzes = db.execute(query, "%#{search}%")
        end
        db.close
        return quizzes
    end

    # Fetches all users that matches search
    #
    # @param [String] search, Search-string for users' uids
    #
    # @return [Array] containing the data of all fetched users
    def fetch_users(current, search)
        str = '?'
        for i in 1..(current.length-1) do
            str += ',?'
        end
        db = conn("db/q.db")
        query = "SELECT id, uid FROM users WHERE uid LIKE ? AND id NOT IN (#{str}) LIMIT 5"
        users = db.execute(query, "%#{search}%", *current)
        db.close
        return users
    end

end