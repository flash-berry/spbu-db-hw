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

SELECT * FROM courses;

INSERT INTO groups (full_name, short_name, students_ids) VALUES
('Искусственный интеллект и наука о данных', 'ИИНОД', NULL),
('Программная инженерия', 'ПИ', NULL);

SELECT * FROM groups;

INSERT INTO students (first_name, last_name, group_id, courses_ids) VALUES
('Артём','Пышный', 1, '{1, 2, 3, 4, 5}'),
('Ирина','Трошина', 1, '{1, 2, 3, 4, 5}'),
('Джасур','Баракаев', 1, '{1, 2, 3, 4, 5}'),
('Кемал','Курей', 2, '{2, 4, 6}'),
('Артём','Панов', 2, '{2, 4, 6}');

SELECT * FROM students;

-- С помощью подзапроса заполним значения массива данных students_ids в таблице Groups
UPDATE groups
SET students_ids = (
    SELECT ARRAY_AGG(students.id)
    FROM students 
    WHERE students.group_id = groups.id
);

SELECT * FROM groups;

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

SELECT * FROM machinelearning;

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

SELECT * FROM machinelearning;

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

---------------------------------------------------------------------------------------------------------
-- HOMEWORK 2
---------------------------------------------------------------------------------------------------------

CREATE TABLE student_courses
(
	id SERIAL PRIMARY KEY,
	student_id INTEGER REFERENCES students(id),
	course_id INTEGER REFERENCES courses(id),
	UNIQUE(student_id, course_id)
);

CREATE TABLE group_courses
(
	id SERIAL PRIMARY KEY,
	group_id INTEGER REFERENCES groups(id),
	course_id INTEGER REFERENCES courses(id),
	UNIQUE(group_id, course_id)
);

INSERT INTO student_courses (student_id, course_id) VALUES
(1,1),
(1,2),
(1,3),
(1,4),
(1,5),
(2,1),
(2,2),
(2,3),
(2,4),
(2,5),
(3,1),
(3,2),
(3,3),
(3,4),
(3,5),
(4,2),
(4,4),
(4,6),
(5,2),
(5,4),
(5,6);

SELECT * FROM student_courses;

INSERT INTO group_courses (group_id, course_id) VALUES
(1,1),
(1,2),
(1,3),
(1,4),
(1,5),
(2,2),
(2,4),
(2,6);

SELECT * FROM group_courses;

ALTER TABLE students DROP COLUMN courses_ids; 

ALTER TABLE groups DROP COLUMN students_ids; 

SELECT * FROM students;

SELECT * FROM groups;

ALTER TABLE courses ADD UNIQUE (name); 

-- ПОЛОЖИТЕЛЬНО ВЛИЯНИЕ ИНДЕКСОВ: 
--  Индекс, благодаря своему устройству (по умолчанию B-tree), позволяет при запросе сканировать не всю таблицу,
--  а только её часть, что значительно ускоряет операцию поиска (SELECT), соединения (JOIN), сортировки (ORDER BY)
--  и группировки (GROUP BY).
--  Алгоритмическая сложность для выполнения запроса без индекса O(n) где n это число записей в таблице.
--  Алгоритмическая сложность для выполнения запроса с индексом O(log(n)).
-- НЕГАТИВНОЕ ВЛИЯНИЕ ИНДЕКСОВ: 
--  Замедление операций вставки (INSERT), обновления (UPDATE) и удаления (DELETE).
--  Занимают дополнительное место на диске.
--  Увеличение сложности оптимизации запросов: при наличи большого числа индексов оптимизатор запросов может тратить
--  больше времени на анализ и выбор индекса для выполнения запроса.
-- КОГДА ИНДЕКСИРОВАНИЕ НЕ ВЫГОДНО:
--  Маленькие таблицы.
--  Низкая уникальность данных.
--  Частое обновление данных в таблице.
CREATE INDEX idx_students_group_id
ON students (group_id);

-- Добавим таблицу для каждого курса. Всего будет 6 таблиц
CREATE TABLE socialweb
(
	student_id INTEGER PRIMARY KEY REFERENCES students(id),
	grade INTEGER CHECK(grade >= 0 AND grade <= 100),
	grade_str VARCHAR(1)
);

INSERT INTO socialweb (student_id, grade, grade_str) VALUES
(1, 70, NULL),
(2, 25, NULL),
(3, 47, NULL);

SELECT * FROM socialweb;

UPDATE socialweb
SET grade_str = 
    CASE 
	    WHEN grade >= 90 THEN 'A'
	    WHEN grade >= 80 THEN 'B'
	    WHEN grade >= 70 THEN 'C'
	    WHEN grade >= 60 THEN 'D'
	    WHEN grade >= 50 THEN 'E'
	    ELSE 'F'
    END;

SELECT * FROM socialweb;

-------------------------------------------------------------------------------------------

CREATE TABLE tbs
(
	student_id INTEGER PRIMARY KEY REFERENCES students(id),
	grade INTEGER CHECK(grade >= 0 AND grade <= 100),
	grade_str VARCHAR(1)
);

INSERT INTO tbs (student_id, grade, grade_str) VALUES
(1, 50, NULL),
(2, 37, NULL),
(3, 40, NULL);

SELECT * FROM tbs;

UPDATE tbs
SET grade_str = 
    CASE 
	    WHEN grade >= 90 THEN 'A'
	    WHEN grade >= 80 THEN 'B'
	    WHEN grade >= 70 THEN 'C'
	    WHEN grade >= 60 THEN 'D'
	    WHEN grade >= 50 THEN 'E'
	    ELSE 'F'
    END;

SELECT * FROM tbs;

-------------------------------------------------------------------------------------------

CREATE TABLE english
(
	student_id INTEGER PRIMARY KEY REFERENCES students(id),
	grade INTEGER CHECK(grade >= 0 AND grade <= 100),
	grade_str VARCHAR(1)
);

INSERT INTO english (student_id, grade, grade_str) VALUES
(1, 79, NULL),
(2, 83, NULL),
(3, 57, NULL),
(4, 44, NULL),
(5, 90, NULL);

SELECT * FROM english;

UPDATE english
SET grade_str = 
    CASE 
	    WHEN grade >= 90 THEN 'A'
	    WHEN grade >= 80 THEN 'B'
	    WHEN grade >= 70 THEN 'C'
	    WHEN grade >= 60 THEN 'D'
	    WHEN grade >= 50 THEN 'E'
	    ELSE 'F'
    END;

SELECT * FROM english;

-------------------------------------------------------------------------------------------

CREATE TABLE psychology
(
	student_id INTEGER PRIMARY KEY REFERENCES students(id),
	grade INTEGER CHECK(grade >= 0 AND grade <= 100),
	grade_str VARCHAR(1)
);

INSERT INTO psychology (student_id, grade, grade_str) VALUES
(1, 35, NULL),
(2, 95, NULL),
(3, 84, NULL);

SELECT * FROM psychology;

UPDATE psychology
SET grade_str = 
    CASE 
	    WHEN grade >= 90 THEN 'A'
	    WHEN grade >= 80 THEN 'B'
	    WHEN grade >= 70 THEN 'C'
	    WHEN grade >= 60 THEN 'D'
	    WHEN grade >= 50 THEN 'E'
	    ELSE 'F'
    END;

SELECT * FROM psychology;

-------------------------------------------------------------------------------------------

CREATE TABLE computevision
(
	student_id INTEGER PRIMARY KEY REFERENCES students(id),
	grade INTEGER CHECK(grade >= 0 AND grade <= 100),
	grade_str VARCHAR(1)
);

INSERT INTO computevision (student_id, grade, grade_str) VALUES
(1, 75, NULL),
(2, 44, NULL),
(3, 80, NULL),
(4, 52, NULL),
(5, 71, NULL);

SELECT * FROM computevision;

UPDATE computevision
SET grade_str = 
    CASE 
	    WHEN grade >= 90 THEN 'A'
	    WHEN grade >= 80 THEN 'B'
	    WHEN grade >= 70 THEN 'C'
	    WHEN grade >= 60 THEN 'D'
	    WHEN grade >= 50 THEN 'E'
	    ELSE 'F'
    END;

SELECT * FROM computevision;

-- Запрос, который покажет список всех студентов с их курсами.
SELECT first_name, last_name, ARRAY_AGG(name) AS list_courses
FROM students s, courses c, student_courses sc
WHERE sc.student_id = s.id AND sc.course_id = c.id
GROUP BY first_name, last_name;

-- Запрос: находит студентов, у которых средняя оценка по курсам выше, чем у любого другого студента в их группе.
SELECT s2.first_name, s2.last_name, avg_grade_table.group_id, max_grades.max_avg
FROM students s2, (
	 	SELECT AVG(combined_grade.grade) AS average_grade, combined_grade.student_id, s.group_id 
			FROM (
			    SELECT grade, student_id FROM machinelearning
			    UNION ALL
			    SELECT grade,student_id FROM socialweb
			    UNION ALL
			    SELECT grade, student_id FROM tbs
			    UNION ALL
			    SELECT grade, student_id FROM english
			    UNION ALL
			    SELECT grade, student_id FROM psychology
			    UNION ALL
			    SELECT grade, student_id FROM computevision
			) AS combined_grade
			JOIN students s 
			ON s.id = combined_grade.student_id
			GROUP BY combined_grade.student_id, s.group_id 
	 ) AS avg_grade_table
JOIN (
	SELECT MAX(average_grade_table.average_grade) AS max_avg, average_grade_table.group_id
	FROM (
			SELECT AVG(combined_grade.grade) AS average_grade, combined_grade.student_id, s.group_id 
			FROM (
			    SELECT grade, student_id FROM machinelearning
			    UNION ALL
			    SELECT grade,student_id FROM socialweb
			    UNION ALL
			    SELECT grade, student_id FROM tbs
			    UNION ALL
			    SELECT grade, student_id FROM english
			    UNION ALL
			    SELECT grade, student_id FROM psychology
			    UNION ALL
			    SELECT grade, student_id FROM computevision
			) AS combined_grade
			JOIN students s 
			ON s.id = combined_grade.student_id
			GROUP BY combined_grade.student_id, s.group_id 
		) AS average_grade_table
	GROUP BY average_grade_table.group_id
	) AS max_grades
ON avg_grade_table.group_id = max_grades.group_id 
AND avg_grade_table.average_grade = max_grades.max_avg
WHERE s2.id = avg_grade_table.student_id
ORDER BY avg_grade_table.group_id;

-- Подсчитать количество студентов на каждом курсе
SELECT COUNT(id) AS count_students, course_id 
FROM student_courses sc 
GROUP BY course_id 
ORDER BY course_id;

-- Найти среднюю оценку на каждом курсе
SELECT AVG(m.grade) AS machinelearning, AVG(s.grade) AS socialweb, AVG(t.grade) AS tbs, AVG(e.grade) AS english, AVG(p.grade) AS psyhology, AVG(c.grade) AS computevision 
FROM machinelearning m 
FULL JOIN socialweb s ON m.student_id = s.student_id
FULL JOIN tbs t ON m.student_id = t.student_id
FULL JOIN english e ON m.student_id = e.student_id
FULL JOIN psychology p ON m.student_id = p.student_id
FULL JOIN computevision c ON m.student_id = c.student_id;