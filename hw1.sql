CREATE DATABASE university;

CREATE TABLE courses
(
	id SERIAL PRIMARY KEY,
	name VARCHAR(50),
	is_exam BOOLEAN,
	min_grade INTEGER,
	max_grade INTEGER
);

CREATE TABLE groups
(
	id SERIAL PRIMARY KEY,
	full_name VARCHAR(50),
	short_name VARCHAR(50),
	students_ids INTEGER[]
);

CREATE TABLE students
(
	id SERIAL PRIMARY KEY,
	first_name VARCHAR(50),
	last_name VARCHAR(50),
	group_id INTEGER REFERENCES groups(id),
	courses_ids INTEGER[]
);

INSERT INTO courses (name, is_exam, min_grade, max_grade) VALUES
('Соцсети', TRUE, 0, 100),
('Машинное обучение', TRUE, 0, 100),
('Теория баесовских сетей', TRUE, 0, 100),
('Английский язык', FALSE, 0, 100),
('Психология коммуникаций', FALSE, 0, 100),
('Компьютерное зрение', TRUE, 0, 100);

SELECT * FROM courses LIMIT 10;

INSERT INTO groups (full_name, short_name, students_ids) VALUES
('Искусственный интеллект и наука о данных', 'ИИНОД', NULL),
('Программная инженерия', 'ПИ', NULL);

SELECT * FROM groups LIMIT 2;

INSERT INTO students (first_name, last_name, group_id, courses_ids) VALUES
('Артём','Пышный', 1, '{1, 2, 3, 4, 5}'),
('Ирина','Трошина', 1, '{1, 2, 3, 4, 5}'),
('Джасур','Баракаев', 1, '{1, 2, 3, 4, 5}'),
('Кемал','Курей', 2, '{2, 4, 6}'),
('Артём','Панов', 2, '{2, 4, 6}');

SELECT * FROM students  LIMIT 10;

-- С помощью подзапроса заполним значения массива данных students_ids в таблице Groups
UPDATE groups
SET students_ids = (
    SELECT ARRAY_AGG(students.id)
    FROM students 
    WHERE students.group_id = groups.id
);

SELECT * FROM groups  LIMIT 10;

CREATE TABLE machinelearning
(
	student_id INTEGER PRIMARY KEY REFERENCES students(id),
	grade INTEGER CHECK(grade >= 0 AND grade <= 100),
	grade_str VARCHAR(1)
);

INSERT INTO machinelearning (student_id, grade, grade_str) VALUES
(1, 60, NULL),
(2, 99, NULL),
(3, 22, NULL),
(4, 37, NULL),
(5, 49, NULL);

SELECT * FROM machinelearning  LIMIT 10;

-- С помощью запроса заполним значения поля grade_str в таблице machinelearning
UPDATE machinelearning
SET grade_str = 
    CASE 
	    WHEN grade >= 90 THEN 'A'
	    WHEN grade >= 80 THEN 'B'
	    WHEN grade >= 70 THEN 'C'
	    WHEN grade >= 60 THEN 'D'
	    WHEN grade >= 50 THEN 'E'
	    ELSE 'F'
    END;

SELECT * FROM machinelearning  LIMIT 10;

-- Процедуры фильтрации

-- С помощью Where
SELECT * FROM courses
WHERE is_exam = FALSE;

-- С помощью условий сравнения и логических операторов
SELECT * FROM machinelearning
WHERE grade > 40 AND grade_str != 'F';

-- С помощью like для поиска по шаблону
SELECT * FROM students
WHERE first_name LIKE '_ртём';

SELECT * FROM students
WHERE last_name LIKE 'Т%';

-- Процедуры агрегации

SELECT avg(grade) FROM machinelearning;

SELECT min(grade) FROM machinelearning;

SELECT max(grade) FROM machinelearning;

SELECT sum(grade) FROM machinelearning;