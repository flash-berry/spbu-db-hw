create database university; 

create table courses
(
	id serial primary key,
	name varchar(50),
	is_exam boolean,
	min_grade integer,
	max_grade integer
);

create table groups
(
	id serial primary key,
	full_name varchar(50),
	short_name varchar(50),
	students_ids integer[]
);

create table students
(
	id serial primary key,
	first_name varchar(50),
	last_name varchar(50),
	group_id integer references groups(id),
	courses_ids integer[]
);

insert into courses (name, is_exam, min_grade, max_grade) values
('Соцсети', true, 0, 100),
('Машинное обучение', true, 0, 100),
('Теория баесовских сетей', true, 0, 100),
('Английский язык', false, 0, 100),
('Психология коммуникаций', false, 0, 100),
('Компьютерное зрение', true, 0, 100);

select * from courses;

insert into groups (full_name, short_name, students_ids) values
('Искусственный интеллект и наука о данных', 'ИИНОД', null),
('Программная инженерия', 'ПИ', null);

select * from groups;

insert into students (first_name, last_name, group_id, courses_ids) values
('Артём','Пышный', 1, '{1, 2, 3, 4, 5, 6}'),
('Ирина','Трошина', 1, '{1, 2, 3, 4, 5, 6}'),
('Джасур','Баракаев', 1, '{1, 2, 3, 4, 5, 6}'),
('Кемал','Курей', 2, '{2, 4, 6}'),
('Артём','Панов', 2, '{2, 4, 6}');

select * from students;

-- С помощью подзапроса заполним значения массива данных students_ids в таблице Groups
UPDATE groups
SET students_ids = (
    SELECT array_agg(students.id)
    FROM students 
    WHERE students.group_id = groups.id
);

select * from groups;

create table machinelearning
(
	student_id integer primary key references students(id),
	grade integer check(grade >= 0 and grade <= 100),
	grade_str varchar(50)
);

insert into machinelearning (student_id, grade, grade_str) values
(1, 60, null),
(2, 99, null),
(3, 22, null),
(4, 37, null),
(5, 49, null);

select * from machinelearning;

-- С помощью запроса заполним значения поля grade_str в таблице machinelearning
UPDATE machinelearning
SET grade_str = 
    case 
	    when grade >= 90 then 'A'
	    when grade >= 80 then 'B'
	    when grade >= 70 then 'C'
	    when grade >= 60 then 'D'
	    when grade >= 50 then 'E'
	    else 'F'
    end;
    
select * from machinelearning;

-- Процедуры фильтрации

-- С помощью Where
select * from courses
where is_exam = false;

-- С помощью условий сравнения и логических операторов
select * from machinelearning
where grade > 40 and grade_str != 'F';

-- С помощью like для поиска по шаблону
select * from students
where first_name like '_ртём';

select * from students
where last_name like 'Т%';

-- Процедуры агрегации

select avg(grade) from machinelearning;

select min(grade) from machinelearning;

select max(grade) from machinelearning;

select sum(grade) from machinelearning;