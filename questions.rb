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

    def authored_question
        Questions.find_by_author_id(self.id)
    end

    def followed_questions
        QuestionFollows.followed_questions_for_user_id(self.id)
    end

    def authored_replies
        Replies.find_by_author_id(self.id)
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

    def create
        raise "#{self} already in database" if self.id
        QuestionsDBConnection.instance.execute(<<-SQL, self.fname, self.lname)
          INSERT INTO
            users (fname, lname)
          VALUES
            (?, ?)
        SQL
        self.id = QuestionsDBConnection.instance.last_insert_row_id
      end

      def update
        raise "#{self} not in database" unless self.id
        QuestionsDBConnection.instance.execute(<<-SQL, self.fname, self.lname, self.id)
          UPDATE
            users
          SET
            fname = ?, lname = ?
          WHERE
            id = ?
        SQL
      end
end


class Questions

    attr_accessor :title, :body, :author, :id

    def self.all
        data = QuestionsDBConnection.instance.execute("SELECT * FROM questions")
        data.map { |datum| Questions.new(datum) }
    end

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

    def followers
        QuestionFollows.followers_for_question_id(self.id)
    end

    def authored
        author_1 = QuestionsDBConnection.instance.execute(<<-SQL, self.author)
        SELECT *
        FROM users
        WHERE id = ?
        SQL
        Users.new(author_1[0])
    end

    def self.find_by_author_id(author_id)
        id_1 = QuestionsDBConnection.instance.execute(<<-SQL, author_id)
        SELECT *
        FROM questions
        WHERE author = ?
        SQL
        if id_1.length == 0
            return nil
        end
        id_1.map {|question| Questions.new(question)}
    end

    def self.find_by_question(title)
        title_1 = QuestionsDBConnection.instance.execute(<<-SQL,("%"+title+"%"))
        SELECT *
        FROM questions
        WHERE title like ?
        SQL
        if title_1.length == 0
            return nil
        end
        Questions.new(title_1[0])
    end

    def create
        raise "#{self} already in database" if self.id
        QuestionsDBConnection.instance.execute(<<-SQL, self.title, self.body, self.author)
          INSERT INTO
            questions (title, body, author)
          VALUES
            (?, ?, ?)
        SQL
        self.id = QuestionsDBConnection.instance.last_insert_row_id
      end

    def update
        raise "#{self} not in database" unless self.id
        QuestionsDBConnection.instance.execute(<<-SQL, self.title, self.body, self.author, self.id)
          UPDATE
            questions
          SET
            title = ?, body = ?, author = ? 
          WHERE
            id = ?
        SQL
      end

    def replies
        Replies.find_by_question_id(self.id)
    end

end

class QuestionFollows

    attr_accessor :id, :followers, :question

    def initialize(options)
        @id = options['id']
        @followers = options['follower']
        @question = options['question']
    end

    def self.followers_for_question_id(question_id)
        id_1 = QuestionsDBConnection.instance.execute(<<-SQL, question_id)
        SELECT users.id, users.fname, users.lname
        FROM questions 
        JOIN question_follows ON questions.id = question
        JOIN users ON question_follows.followers = users.id
        WHERE questions.id = ?
        SQL
        id_1.map {|user| Users.new(user)}
    end

    def self.followed_questions_for_user_id(user_id)
        id_1 = QuestionsDBConnection.instance.execute(<<-SQL, user_id)
        SELECT questions.id, questions.title, questions.body, questions.author
        FROM users
        JOIN question_follows ON users.id = question_follows.followers
        JOIN questions ON question_follows.question = questions.id
        WHERE users.id = ?
        SQL
        id_1.map {|question| Questions.new(question)}
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

    def authored
        author_1 = QuestionsDBConnection.instance.execute(<<-SQL, self.author)
        SELECT *
        FROM users
        WHERE id = ?
        SQL
        Users.new(author_1[0])
    end

    def question
        question = QuestionsDBConnection.instance.execute(<<-SQL, self.subj)
        SELECT *
        FROM questions
        WHERE id = ?
        SQL
        Question.new(author_1[0])
    end

    def parent_reply
        if parent == nil
            self.question
        end
        reply = QuestionsDBConnection.instance.execute(<<-SQL, self.parent)
        SELECT *
        FROM replies
        WHERE id = ?
        SQL
        Replies.new(reply[0])
    end

    def self.all
        data = QuestionsDBConnection.instance.execute("SELECT * FROM replies")
        data.map { |datum| Replies.new(datum) }
    end
    
    def child_reply
        children = Replies.all
        children.select {|child| child.parent == self.id}
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

    def self.find_by_author_id(user_id)
        id_1 = QuestionsDBConnection.instance.execute(<<-SQL, user_id)
        SELECT *
        FROM replies
        WHERE author = ?
        SQL
        if id_1.length == 0
            return nil
        end
        id_1.map { |reply| Replies.new(reply)}
    end

    def self.find_by_question_id(question_id)
        id_1 = QuestionsDBConnection.instance.execute(<<-SQL, question_id)
        SELECT *
        FROM replies
        WHERE subj = ?
        SQL
        if id_1.length == 0
            return nil
        end
        id_1.map { |reply| Replies.new(reply)}
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