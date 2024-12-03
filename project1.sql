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
--
-- Предварительно дальнейшие планы по проекту в следующих версиях (заданиях), разработать:
--		1) Триггер запрещающий назначать в поле manager_id людей, которые не менеджеры
--		2) Триггер на минимальную заработную плату
--		3) Триггер для архивирования уволенных сотрудников и выполненных задач
--		4) Триггер который контролирует чтобы end_date не могла быть меньше start_date таблицы projects
--		5) Триггер для логирования действий в БД
--		6) Добавить логирование к запросам
--		7) Реализовать систему, которая будет добавлять/отнимать к/от ЗП в зависимости от рабочих часов за месяц для каждого сотрудника оффиса и штрафов (просрочил дедлайн задачи) 
--		8) Продолжить разрабатывать запросы, которые могут быть полезны при работе с текущей БД
--		9) Создать запросы с использованием CTE, временных таблиц, представлений
--		10) Создать следующие таблицы overdue_tasks, log_audit и dismissed employees
