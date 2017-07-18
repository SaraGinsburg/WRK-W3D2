DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL
);
DROP TABLE IF EXISTS questions;
CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  body VARCHAR(255) NOT NULL,
  author_id INTEGER NOT NULL,

  FOREIGN KEY (author_id) REFERENCES users(id)
);
DROP TABLE IF EXISTS question_follows;
CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);
DROP TABLE IF EXISTS replies;
CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  parent_reply_id INTEGER,
  user_id INTEGER NOT NULL,
  body VARCHAR(255) NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (parent_reply_id) REFERENCES replies(id)
);
DROP TABLE IF EXISTS question_likes;
CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO
  users (fname, lname)
VALUES
  ('Sara', 'Ginsburg'), ('Rhema', 'Boyo'), ('Levi', 'Ginsburg'), ('Jon', 'Snow');

INSERT INTO
  questions (title, body, author_id)
VALUES
  ('CSS Inline Block?', 'How do you style an element with an inline-block',
    (SELECT id FROM users WHERE fname = 'Sara' AND lname = 'Ginsburg')),
  ('SQL Tables?', 'How do I reference SQL tables in Ruby?',
    (SELECT id FROM users WHERE fname = 'Rhema' AND lname = 'Boyo')),
  ('Rails?', 'What is a model in Rails?',
    (SELECT id FROM users WHERE fname = 'Rhema' AND lname = 'Boyo'));

INSERT INTO
  question_follows (user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE fname = 'Sara' AND lname = 'Ginsburg'),
  (SELECT id FROM questions WHERE title = 'SQL Tables?')),
  ((SELECT id FROM users WHERE fname = 'Levi' AND lname = 'Ginsburg'),
  (SELECT id FROM questions WHERE title = 'SQL Tables?')),
  ((SELECT id FROM users WHERE fname = 'Jon' AND lname = 'Snow'),
  (SELECT id FROM questions WHERE title = 'CSS Inline Block?')),
  ((SELECT id FROM users WHERE fname = 'Jon' AND lname = 'Snow'),
  (SELECT id FROM questions WHERE title = 'SQL Tables?')),
  ((SELECT id FROM users WHERE fname = 'Rhema' AND lname = 'Boyo'),
  (SELECT id FROM questions WHERE title = 'CSS Inline Block?'));

INSERT INTO
  replies (question_id, parent_reply_id, user_id, body )
VALUES
  ((SELECT id FROM questions WHERE title = 'CSS Inline Block?'), NULL,
  (SELECT id FROM users WHERE fname = 'Rhema'),
  "just write display: inline-block"),
  ((SELECT id FROM questions WHERE title = 'CSS Inline Block?'), 1,
  (SELECT id FROM users WHERE fname = 'Sara'),
  "thanks, it works"),
  ((SELECT id FROM questions WHERE title = 'CSS Inline Block?'), 1,
  (SELECT id FROM users WHERE fname = 'Jon'),
  "try padding = 20px "),
  ((SELECT id FROM questions WHERE title = 'SQL Tables?'), NULL,
  (SELECT id FROM users WHERE fname = 'Jon'),
  "Here is a good example: cat import_db.sql | sqlite3 questions.db");

INSERT INTO
  question_likes (question_id, user_id )
VALUES
  ((SELECT id FROM questions WHERE title = 'SQL Tables?'),
  (SELECT id FROM users WHERE fname = 'Sara')),
  ((SELECT id FROM questions WHERE title = 'SQL Tables?'),
  (SELECT id FROM users WHERE fname = 'Sara')),
  ((SELECT id FROM questions WHERE title = 'SQL Tables?'),
  (SELECT id FROM users WHERE fname = 'Levi')),
  ((SELECT id FROM questions WHERE title = 'SQL Tables?'),
  (SELECT id FROM users WHERE fname = 'Jon')),
  ((SELECT id FROM questions WHERE title = 'CSS Inline Block?'),
  (SELECT id FROM users WHERE fname = 'Jon')),
  ((SELECT id FROM questions WHERE title = 'CSS Inline Block?'),
  (SELECT id FROM users WHERE fname = 'Levi')
);
