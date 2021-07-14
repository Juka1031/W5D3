require 'sqlite3'
require 'singleton'


class QuestionsDBConnection <SQLite3::Database
include Singleton
    def initialize
        super('questions.db')
        self.type_translation = true
        self.results_as_hash = true
    end
end

class Users
    attr_accessor :id, :fname, :lname
    def self.all
        data = QuestionsDBConnection.instance.execute("SELECT * FROM users")
        data.map { |datum| Users.new(datum) }
    end

    def initialize(options)
        @id = options['id']
        @fname = options['fname']
        @lname = options['lname']
    end

    def self.find_by_id(id)
        id_1 = QuestionsDBConnection.instance.execute(<<-SQL, id)
        SELECT *
        FROM users
        WHERE id = ?
        SQL
        if id_1.length == 0
            return nil
        end
        Users.new(id_1[0])
    end

    def self.find_by_name(fname, lname)
        full_name = QuestionsDBConnection.instance.execute(<<-SQL, fname, lname)
        SELECT *
        FROM users
        WHERE fname = ? AND lname = ?
        SQL
        if full_name.length == 0
            return nil
        end
        Users.new(full_name[0])
    end
end


class Questions
    attr_accessor :id, :title, :body, :author
    def initialize(options)
        @id = options['id']
        @title = options['title']
        @body = options['body']
        @author = options['author']
        
    end

    def self.find_by_id(id)
        id_1 = QuestionsDBConnection.instance.execute(<<-SQL, id)
        SELECT *
        FROM questions
        WHERE id = ?
        SQL
        if id_1.length == 0
            return nil
        end
        Questions.new(id_1[0])
    end

end

class QuestionFollows

    attr_accessor :id, :followers, :question
    def initialize(options)
        @id = options['id']
        @followers = options['follower']
        @question = options['question']
        
    end
    def self.find_by_id(id)
        id_1 = QuestionsDBConnection.instance.execute(<<-SQL, id)
        SELECT *
        FROM question_follows
        WHERE id = ?
        SQL
        if id_1.length == 0
            return nil
        end
        QuestionFollows.new(id_1[0])
    end

end

class Replies
    attr_accessor :id, :reply, :subj, :parent, :author
    def initialize(options)
        @id = options['id']
        @reply = options['reply']
        @subj = options['subj']
        @parent = options['parent']
        @author = options['author']
    end
    def self.find_by_id(id)
        id_1 = QuestionsDBConnection.instance.execute(<<-SQL, id)
        SELECT *
        FROM replies
        WHERE id = ?
        SQL
        if id_1.length == 0
            return nil
        end
        Replies.new(id_1[0])
    end

end

class QuestionLikes
    attr_accessor :id, :user, :question
    def initialize(options)
        @id = options['id']
        @user = options['user']
        @question = options['question']
    end

    def self.find_by_id(id)
        id_1 = QuestionsDBConnection.instance.execute(<<-SQL, id)
        SELECT *
        FROM question_likes
        WHERE id = ?
        SQL
        if id_1.length == 0
            return nil
        end
        QuestionLikes.new(id_1[0])
    end

end

# class BaseDB_Handling
#     TABLE = raise
#     def initialize(options)
#         @id = options['id']
#     end

#     def self.all(TABLE)
#         data = QuestionsDBConnection.instance.execute("SELECT * FROM #{TABLE}")
#         data.map { |datum| .new(datum) }
#       end


# class ClassName <BaseDB_Handling
#     def initialize
        
#     end
#     def self.all
#         super
#     end
# end