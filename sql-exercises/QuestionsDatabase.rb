require 'sqlite3'
require 'singleton'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end


end

class Question
  attr_accessor :id, :title, :body, :author_id

  def self.find_by_id(id)
    id = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT *
      FROM questions
      WHERE id = ?
    SQL
    return nil unless id.length > 0
    Question.new(id.first)
  end

  def self.followers(id)
    QuestionFollow.followers_for_question_id(id)
  end

  def self.author(title)
    author = QuestionsDatabase.instance.execute(<<-SQL, title)
      SELECT users.*
      FROM questions
      JOIN users ON questions.author_id = users.id
      WHERE title = ?
    SQL
    return nil unless author.length > 0
    User.new(author.first)
  end

  def self.find_by_author_id(author_id)
    author_id = QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT *
      FROM questions
      WHERE author_id = ?
    SQL
    return nil unless author_id.length > 0
    author_id.map { |question| Question.new(question) }
  end

  def self.replies(question_id)
    Reply.find_by_question_id(question_id)

  end

  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
  end

end

class User
  attr_accessor :id, :fname, :lname

  def self.find_by_name(fname, lname)
    name = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT *
      FROM users
      WHERE fname = ? AND lname = ?
    SQL
    return nil unless name.length > 0
    User.new(name.first)
  end

  def self.authored_questions(author_id)
    author_questions = QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT *
      FROM questions
      WHERE questions.author_id = ?
    SQL
    return nil unless author_questions.length > 0
    author_questions.map { |question| Question.new(question) }
  end

  def self.followed_questions(id)
    QuestionFollow.followed_questions_for_user_id(id)
  end

  def self.authored_replies(user_id)
    author_replies = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT *
      FROM replies
      WHERE replies.user_id = ?
    SQL
    return nil unless author_replies.length > 0
    author_replies.map { |reply| Reply.new(reply) }
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end
end

class QuestionFollow
  def self.followers_for_question_id(question_id)
    followers = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT users.fname, users.lname
      FROM question_follows
      JOIN users ON user_id = users.id
      WHERE question_follows.question_id = ?
    SQL
    return nil unless followers.length > 0
    followers.map { |user| User.find_by_name(user['fname'], user['lname']) }
  end

  def self.followed_questions_for_user_id(user_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT questions.id
      FROM question_follows
      JOIN questions ON questions.id = question_follows.question_id
      WHERE question_follows.user_id = ?
    SQL
    return nil unless questions.length > 0
    questions.map { |question| Question.find_by_id(question.values[0]) }
  end

  def self.most_followed_questions(n)
    most_followed_questions = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT *
      FROM question_follows
      JOIN questions ON questions.id = question_follows.question_id
      GROUP BY questions.id
      ORDER BY COUNT(questions.id) DESC
      LIMIT ?

    SQL
    return nil unless most_followed_questions.length > 0
    return most_followed_questions.map {|question| Question.new(question)}
  end

end

class QuestionLike
  def self.likers_for_question_id(question_id)
    likers = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT DISTINCT users.fname, users.lname
      FROM question_likes
      JOIN users ON users.id = question_likes.user_id
      WHERE question_likes.question_id = ?
    SQL
    return nil unless likers.length > 0
    likers.map { |user| User.find_by_name(user['fname'], user['lname']) }
  end
end

class Reply
  attr_accessor :question_id, :parent_reply_id, :user_id, :body
  def self.find_by_question(question_id)
    question = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT *
      FROM replies
      WHERE question_id = ?
    SQL
    return nil unless question.length > 0
    Reply.new(question.first)
  end

  def self.author(reply_id)
    author = QuestionsDatabase.instance.execute(<<-SQL, reply_id)
      SELECT users.*
      FROM replies
      JOIN users ON replies.user_id = users.id
      WHERE replies.id = ?
    SQL
    return nil unless author.length > 0
    User.new(author.first)
  end

  def self.question(reply_id)
    question = QuestionsDatabase.instance.execute(<<-SQL, reply_id)
      SELECT questions.*
      FROM replies
      JOIN questions ON replies.question_id = questions.id
      WHERE replies.id = ?
    SQL
    return nil unless question.length > 0
    Question.new(question.first)
  end

  def self.parent_reply(reply_id)
    parent_reply = QuestionsDatabase.instance.execute(<<-SQL, reply_id)
      SELECT parent_replies.*
      FROM replies
      JOIN replies AS parent_replies ON replies.parent_reply_id = parent_replies.id
      WHERE replies.id = ?
    SQL
    return nil unless parent_reply.length > 0
    Reply.new(parent_reply.first)
  end

  def self.child_replies(reply_id)
    child_replies = QuestionsDatabase.instance.execute(<<-SQL, reply_id)
      SELECT child_replies.*
      FROM replies
      JOIN replies AS child_replies ON child_replies.parent_reply_id = replies.id
      WHERE replies.id = ?
    SQL
    return nil unless child_replies.length > 0
    child_replies.map { |child| Reply.new(child)}

  end

  def self.find_by_user_id(user_id)
    user_id = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT *
      FROM replies
      WHERE user_id = ?
    SQL
    return nil unless user_id.length > 0
    user_id.map { |reply| Reply.new(reply) }
  end

  def self.find_by_question_id(question_id)
    question_id = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT *
      FROM replies
      WHERE question_id = ?
    SQL
    return nil unless question_id.length > 0
    question_id.map { |reply| Reply.new(reply) }
  end

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @parent_reply_id = options['parent_reply_id']
    @user_id = options['user_id']
    @body =  options['body']
  end
end
