PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);

DROP TABLE IF EXISTS questions;

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  author INTEGER NOT NULL,
  FOREIGN KEY (author) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_follows;

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  followers INTEGER NOT NULL,
  question INTEGER NOT NULL,
  FOREIGN KEY (followers) REFERENCES users(id),
  FOREIGN KEY (question) REFERENCES questions(id) 
);

DROP TABLE IF EXISTS replies;

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  reply TEXT NOT NULL,
  subj INTEGER NOT NULL, --replies to a particular question
  parent INTEGER,
  author INTEGER NOT NULL,
  FOREIGN KEY(subj) REFERENCES questions(id),
  FOREIGN KEY(parent) REFERENCES replies(id),
  FOREIGN KEY(author) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_likes;

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  user TEXT NOT NULL,
  question TEXT NOT NULL,
  FOREIGN KEY(user) REFERENCES users(id),
  FOREIGN KEY(question) REFERENCES questions(id)
);


INSERT INTO
  users (fname, lname)
VALUES
  ('Dustin', 'Adler'),
  ('Julian', 'Kang');

INSERT INTO
  questions (title, body, author)
VALUES
  ('WhyDoIExist', 'I think it''s self explanitory?', (SELECT id FROM users WHERE fname = 'Dustin' AND lname = 'Adler')),
  ('Lunch?', 'What''s for lunch?', (SELECT id FROM users WHERE fname = 'Julian' AND lname ='Kang'));

INSERT INTO
  question_follows (followers, question)
VALUES
  ((SELECT id FROM users WHERE fname = 'Dustin' AND lname = 'Adler'),
  (SELECT id FROM questions WHERE title = 'WhyDoIExist'));

  INSERT INTO
    replies (reply, subj, parent, author)
  VALUES
    ('EternalDamnation', (SELECT id FROM questions WHERE title = 'WhyDoIExist'),
    (SELECT id FROM replies WHERE reply = 'EternalDamnation'),
    (SELECT id FROM users WHERE fname = 'Dustin' AND lname = 'Adler'));