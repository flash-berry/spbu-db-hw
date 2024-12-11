SELECT * FROM pg_database
WHERE datname = 'office';

CREATE DATABASE office;

CREATE TABLE IF NOT EXISTS departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(50) UNIQUE NOT NULL
);

INSERT INTO departments (department_name) VALUES
('IT'),
('Management'),
('Data Science'),
('Operations'),
('Human Resources'),
('Finance'),
('Sales and Marketing');

SELECT * FROM departments LIMIT 10;

CREATE TABLE IF NOT EXISTS employees (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    position VARCHAR(50) NOT NULL,
    is_manager BOOLEAN NOT NULL,
    department_id INT REFERENCES departments(department_id),
    hire_date DATE NOT NULL,
    salary NUMERIC(10, 2) NOT NULL,
    manager_id INT REFERENCES employees(employee_id)
);

INSERT INTO employees (first_name, last_name, position, is_manager, department_id, hire_date, salary, manager_id) VALUES
('Alice', 'Johnson', 'Software Engineer', TRUE, 1, '2019-03-15', 85000.00, NULL),
('Bob', 'Smith', 'DevOps Engineer', FALSE, 1, '2020-06-12', 80000.00, 1),
('Carol', 'Williams', 'Junior Developer', FALSE, 1, '2022-08-10', 60000.00, 1),
('David', 'Brown', 'Team Lead', FALSE, 1, '2018-11-01', 95000.00, NULL),
('Eve', 'Davis', 'Project Manager', TRUE, 2, '2017-05-20', 105000.00, NULL),
('Frank', 'Miller', 'Business Analyst', FALSE, 2, '2020-01-15', 75000.00, 5),
('Grace', 'Wilson', 'Assistant Manager', FALSE, 2, '2021-09-12', 70000.00, 5),
('Henry', 'Moore', 'Data Scientist', TRUE, 3, '2019-07-08', 92000.00, NULL),
('Ivy', 'Taylor', 'Data Analyst', FALSE, 3, '2020-04-18', 72000.00, 8),
('Jack', 'Anderson', 'Machine Learning Engineer', FALSE, 3, '2021-11-22', 98000.00, 8),
('Karen', 'Thomas', 'Operations Manager', TRUE, 4, '2016-03-12', 90000.00, NULL),
('Leo', 'Jackson', 'Logistics Specialist', FALSE, 4, '2018-10-05', 65000.00, 11),
('Mona', 'White', 'Operations Analyst', FALSE, 4, '2022-02-25', 55000.00, 11),
('Nina', 'Harris', 'HR Manager', TRUE, 5, '2015-08-20', 85000.00, NULL),
('Oscar', 'Martin', 'Recruitment Specialist', FALSE, 5, '2019-01-15', 60000.00, 14),
('Paul', 'Garcia', 'Finance Manager', TRUE, 6, '2014-06-10', 110000.00, NULL),
('Quincy', 'Martinez', 'Accountant', FALSE, 6, '2020-03-20', 70000.00, 16),
('Rachel', 'Roberts', 'Marketing Manager', TRUE, 7, '2018-04-25', 95000.00, NULL),
('Steve', 'Lopez', 'Sales Executive', FALSE, 7, '2020-09-15', 65000.00, NULL),
('Tina', 'Clark', 'Digital Marketing Specialist', FALSE, 7, '2022-07-10', 55000.00, 18);

SELECT * FROM employees LIMIT 20;

CREATE TABLE IF NOT EXISTS projects (
    project_id SERIAL PRIMARY KEY,
    project_name TEXT UNIQUE NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    budget NUMERIC(12, 2)
);

INSERT INTO projects (project_name, start_date, end_date, budget) VALUES
('Website Redesign', '2023-01-15', '2023-05-30', 50000.00),
('Mobile App Development', '2023-02-01', '2023-11-30', 150000.00),
('Data Migration', '2022-06-10', '2023-06-10', 120000.00),
('Marketing Campaign', '2023-03-01', '2023-12-31', 80000.00),
('Customer Support Optimization', '2023-04-15', NULL, 60000.00),
('Cybersecurity Upgrade', '2023-05-20', '2023-10-20', 90000.00),
('AI Chatbot Implementation', '2023-08-01', '2024-02-28', 110000.00),
('Office Relocation', '2023-09-01', '2024-01-31', 70000.00),
('Financial Audit', '2023-07-01', NULL, 40000.00),
('Employee Training Program', '2023-06-01', '2023-12-15', 30000.00);

SELECT * FROM projects LIMIT 10;

CREATE TABLE IF NOT EXISTS tasks (
    task_id SERIAL PRIMARY KEY,
    task_name VARCHAR(50) UNIQUE NOT NULL,
    project_id INT REFERENCES projects(project_id),
    assigned_to INT REFERENCES employees(employee_id),
    deadline DATE,
    complete BOOLEAN NOT NULL
);

INSERT INTO tasks (task_name, project_id, assigned_to, deadline, complete) VALUES
('Prepare Financial Reports', 9, 17, '2023-07-15', TRUE),
('Analyze Budget Allocations', 9, 17, '2023-08-01', TRUE),
('Identify Cost Overruns', 9, 11, '2023-08-15', FALSE),
('Review Tax Compliance', 9, 14, '2023-09-01', FALSE),
('Submit Audit Findings', 9, 17, '2023-10-01', TRUE),
('Update Financial Policies', 9, 17, NULL, FALSE),
('Discuss Findings with Stakeholders', 9, 5, NULL, TRUE),
('Collect Customer Feedback', 5, 11, '2023-05-01', TRUE),
('Analyze Support Tickets', 5, 11, '2023-05-15', TRUE),
('Identify Common Issues', 5, 8, '2023-06-01', FALSE),
('Research Support Tools', 5, 3, '2023-06-15', FALSE),
('Implement Chatbot', 5, 3, '2023-08-01', FALSE),
('Test Chatbot Functionality', 5, 8, '2023-08-15', TRUE),
('Create Training Materials', 5, 14, '2023-09-01', FALSE),
('Train Support Team', 5, 14, '2023-09-15', TRUE),
('Launch New Support System', 5, 11, '2023-10-01', FALSE),
('Monitor System Performance', 5, 3, NULL, FALSE);

SELECT * FROM tasks LIMIT 20;

-- Запрос, который выводит список сотрудников, которые работают над проектом и число выполняемых для проекта задач
SELECT project_name, ARRAY_AGG(DISTINCT assigned_to) AS list_employees, COUNT(task_id) AS tasks_in_progress
FROM projects p
INNER JOIN tasks t
ON p.project_id = t.project_id
WHERE t.complete = FALSE 
GROUP BY project_name;

-- Запрос, который показывает незаконченные проекты
SELECT project_name, start_date, budget
FROM projects
WHERE end_date IS NULL;

-- Запрос, который показывает среднюю зарплату по отделам
SELECT department_name, AVG(salary) AS avg_salary
FROM employees e
INNER JOIN departments d
ON e.department_id = d.department_id
GROUP BY department_name
ORDER BY avg_salary DESC;

-- Запрос, который показывает 5 последних нанятых в оффис работников
SELECT *
FROM employees
ORDER BY hire_date DESC
LIMIT 5;

-- Запрос, который показывает менеджеров по отделам
SELECT first_name, last_name, department_name 
FROM employees e
INNER JOIN departments d
ON e.department_id = d.department_id 
WHERE is_manager = TRUE;

-- Запрос, который показывает менеджеров + количество и список подчинённых им сотрудников
SELECT first_name, last_name, table_subordinate_employees.subordinate_employees, table_subordinate_employees.count_subordinate_employees
FROM employees
INNER JOIN (SELECT manager_id , ARRAY_AGG(employee_id) AS subordinate_employees, COUNT(employee_id) AS count_subordinate_employees
FROM employees 
WHERE is_manager = FALSE AND manager_id IS NOT NULL
GROUP BY manager_id ) AS table_subordinate_employees 
ON employees.employee_id = table_subordinate_employees.manager_id;

-- В текущей версии (задании) проекта была разработана основная структура и логика базы данных, а также простые запросы + агрегации
-- Основные таблицы были заполненны соответствующими логике данными.
------------------------------------------------------------------------------------------------------------------------------------------

-- Создадим временную таблицу, которая покажет ближайшие задачи
INSERT INTO tasks (task_name, project_id, assigned_to, deadline, complete) VALUES
('Prepare Financial Reports 2', 9, 17, '2024-12-15', TRUE),
('Analyze Budget Allocations 2', 9, 17, '2023-12-31', TRUE),
('Identify Cost Overruns 2', 9, 11, '2025-01-01', FALSE),
('Review Tax Compliance 2', 9, 14, '2025-04-17', TRUE),
('Review Tax Compliance 3', 9, 14, '2025-04-17', FALSE),
('Analyze Support Tickets 2', 5, 11, '2025-05-15', TRUE),
('Prepare Financial Reports 4', 9, 14, '2023-6-15', TRUE),
('Analyze Budget Allocations 4', 9, 11, '2023-2-17', TRUE);

CREATE TEMP TABLE nearest_noncomplete_tasks AS
SELECT project_name, task_name, deadline
FROM tasks t
INNER JOIN projects p
ON t.project_id = p.project_id
WHERE t.complete = FALSE AND t.deadline > CURRENT_DATE
ORDER BY deadline;

SELECT * FROM nearest_noncomplete_tasks LIMIT 5;

-- CTE запрос, который показывает расходы бюджета за прошлый год по кварталам
INSERT INTO projects (project_name, start_date, end_date, budget) VALUES
('Website Redesign 2', '2024-01-15', '2024-05-30', 50000.00),
('Mobile App Development 2', '2024-02-01', '2024-11-30', 150000.00),
('Data Migration 2', '2024-06-10', '2024-06-10', 120000.00),
('Marketing Campaign 2', '2024-03-01', '2024-12-31', 80000.00);

WITH quarterly_budget_report_for_last_year AS (
    SELECT 
        SUM(budget) AS total_cost,
        'первый квартал' AS quarter_period
    FROM projects
    WHERE EXTRACT(quarter FROM start_date) = 1 AND EXTRACT(year FROM start_date) = EXTRACT(year FROM CURRENT_DATE - INTERVAL '1 year')
    GROUP BY quarter_period
    UNION ALL
    SELECT 
        SUM(budget) AS total_cost,
        'второй квартал' AS quarter_period
    FROM projects
    WHERE EXTRACT(quarter FROM start_date) = 2 AND EXTRACT(year FROM start_date) = EXTRACT(year FROM CURRENT_DATE - INTERVAL '1 year')
    GROUP BY quarter_period
    UNION ALL
    SELECT 
        SUM(budget) AS total_cost,
        'третий квартал' AS quarter_period
    FROM projects
    WHERE EXTRACT(quarter FROM start_date) = 3 AND EXTRACT(year FROM start_date) = EXTRACT(year FROM CURRENT_DATE - INTERVAL '1 year')
    GROUP BY quarter_period
    UNION ALL
    SELECT 
        SUM(budget) AS total_cost,
        'четвёртый квартал' AS quarter_period
    FROM projects
    WHERE EXTRACT(quarter FROM start_date) = 4 AND EXTRACT(year FROM start_date) = EXTRACT(year FROM CURRENT_DATE - INTERVAL '1 year')
    GROUP BY quarter_period
)SELECT * FROM quarterly_budget_report_for_last_year
ORDER BY total_cost DESC;

-- CTE запрос, который показывает работников, которые выполнили больше задач, чем в среднем выполняют задач в оффисе за прошлый год
WITH employee_tasks_stats AS (
    SELECT 
        assigned_to AS employee_id,
        COUNT(*) AS total_tasks
    FROM tasks
    WHERE EXTRACT(year FROM deadline) = EXTRACT(year FROM CURRENT_DATE - INTERVAL '1 year') AND complete = TRUE
    GROUP BY employee_id
),
counting_avg AS (
	SELECT AVG(total_tasks) AS avg_tasks
	FROM employee_tasks_stats
)
SELECT first_name, last_name
FROM counting_avg, employee_tasks_stats ets
INNER JOIN employees e
ON ets.employee_id = e.employee_id
WHERE total_tasks > avg_tasks
ORDER BY total_tasks DESC;

-- Создадим представление, которое объединяет данные из двух таблиц: tasks и projects и отображает текущие проекты и задачи по ним.
CREATE VIEW tasks_projects_view AS
SELECT p.project_name, p.start_date, p.end_date, p.budget, t.task_name, t.assigned_to, t.deadline, t.complete
FROM projects p
INNER JOIN tasks t 
ON t.project_id = p.project_id;

SELECT * FROM tasks_projects_view LIMIT 30;

-- Проанализируем запрос, который показывает менеджеров по отделам, используя EXPLAIN ANALYZE (валидация запроса)

-- Hash Join верхний уровень - Hash Join  (cost=13.09..31.46 rows=95 width=354) (actual time=0.060..0.065 rows=7 loops=1):
--	cost=13.09..31.46:
--		13.09: Оценочные начальные затраты на выполнение операции.
--		31.46: Оценочные конечные затраты.
--  	Затраты включают чтение данных, вычисления и использование памяти.
-- 	rows=95: Оценочное количество строк, которое операция должна вернуть (здесь — 95 строки).
--  width=354: Средний размер одной строки в байтах
--  actual time=0.060..0.065:
--		0.060: Время начала выполнения операции (в миллисекундах).
--		0.065: Время окончания выполнения операции.
--		Разница между этими значениями — это время, затраченное на выполнение операции (около 0.005 с).
--	rows=7: На самом деле соединение вернуло 7 строк.
--  loops=1: Указывает, что операция выполнялась один раз.
--
-- Hash Cond: (d.department_id = e.department_id): 
--	Условие соединения: department_id из таблицы departments должно совпадать с department_id из таблицы employees.
--
-- Ветка 1: Seq Scan on departments d  (cost=0.00..15.40 rows=540 width=122) (actual time=0.019..0.021 rows=7 loops=1):
--	Seq Scan: Последовательное сканирование таблицы departments.
--	cost=0.00..15.40: 
--		0.00: Оценочные начальные затраты на выполнение операции.
--		15.40: Оценочные конечные затраты.
-- 	rows=540: Оценочное количество строк в таблице departments (здесь — 540 строки).
--  width=122: Каждая строка имеет ширину 122 байта. 
--  actual time=0.019..0.021:
--		0.019: Время начала выполнения операции (в миллисекундах).
--		0.021: Время окончания выполнения операции.
--		Разница между этими значениями — это время, затраченное на выполнение операции (около 0.002 с).
--	rows=7: Таблица содержит 7 строк, которые учавствуют в соединении.
--  loops=1: Таблица прочитана 1 раз.
--  
-- Ветка 2: Hash (cost=11.90..11.90 rows=95 width=240) (actual time=0.023..0.024 rows=7 loops=1)
-- 	Hash: Создание хэш-таблицы на основе данных из таблицы employees.
--	cost=11.90..11.90: Создание хэш-таблицы имеет фиксированную стоимость 11.90
--	rows=95: Ожидается, что таблица содержит 95 строк.
--	width=240: Каждая строка шириной 240 байт.
--  actual time=0.023..0.024:
--		0.023: Время начала выполнения операции (в миллисекундах).
--		0.024: Время окончания выполнения операции.
--		Разница между этими значениями — это время, затраченное на выполнение операции создания хэша (около 0.001 с).
--	rows=7: Таблица содержит 7 строк.
--  loops=1: Таблица прочитана 1 раз.
--
-- Buckets: 1024: Создано 1024 хэш-"корзины".
-- Batches: 1: Использована одна партия.
-- Memory Usage: 9kB: Затрачено 9 КБ памяти.
--	
-- Seq Scan on employees e (cost=0.00..11.90 rows=95 width=240) (actual time=0.010..0.015 rows=7 loops=1):
--	Seq Scan on employees e: Последовательное сканирование таблицы employees для получения данных.
--	cost=0.00..11.90: 
--		0.00: Оценочные начальные затраты на выполнение операции.
--		11.90: Оценочные конечные затраты.	
--	rows=95: Ожидается что таблица содержит 95 строк.
--  width=240: Каждая строка шириной 240 байт.
--  actual time=0.010..0.015:
--		0.010: Время начала выполнения операции (в миллисекундах).
--		0.015: Время окончания выполнения операции.
--		Разница между этими значениями — это время, затраченное на выполнение операции создания хэша (около 0.005 с).
--	rows=7: Таблица содержит 7 строк, которые прошли фильтрацию.
--  loops=1: Таблица прочитана 1 раз.
--	Filter: is_manager: Применен фильтр is_manager.
--	Rows Removed by Filter: 13: 13 строк были исключены, так как не прошли фильтр.
--
-- Planning Time: 0.227 ms:
--  Planning Time: Время, затраченное на анализ запроса и построение плана выполнения.
-- 
-- Execution Time: 0.110 ms:
-- Execution Time: Общее время выполнения запроса, включая все этапы. В данном случае выполнение запроса заняло около 0.110 мс.
EXPLAIN ANALYZE
SELECT first_name, last_name, department_name 
FROM employees e
INNER JOIN departments d
ON e.department_id = d.department_id 
WHERE is_manager = TRUE;

-- В текущей версии (задании) проекта были разработаны временные структуры и представления, способы валидации запросов.
-- Временная таблица nearest_noncomplete_tasks, CTE quarterly_budget_report_for_last_year, CTE employee_tasks_stats.
-- Представление tasks_projects_view и проанализрован с помощью EXPLAIN ANALYZE запрос, который показывает менеджеров по отделам.