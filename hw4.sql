CREATE DATABASE market;

CREATE TABLE IF NOT EXISTS employees (
    employee_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    position VARCHAR(50) NOT NULL,
    department VARCHAR(50) NOT NULL,
    salary NUMERIC(10, 2) NOT NULL,
    manager_id INT REFERENCES employees(employee_id)
);

-- Пример данных
INSERT INTO employees (name, position, department, salary, manager_id)
VALUES
    ('Alice Johnson', 'Manager', 'Sales', 85000, NULL),
    ('Bob Smith', 'Sales Associate', 'Sales', 50000, 1),
    ('Carol Lee', 'Sales Associate', 'Sales', 48000, 1),
    ('David Brown', 'Sales Intern', 'Sales', 30000, 2),
    ('Eve Davis', 'Developer', 'IT', 75000, NULL),
    ('Frank Miller', 'Intern', 'IT', 35000, 5);


SELECT * FROM employees LIMIT 10;

CREATE TABLE IF NOT EXISTS sales(
    sale_id SERIAL PRIMARY KEY,
    employee_id INT REFERENCES employees(employee_id),
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    sale_date DATE NOT NULL
);

-- Пример данных
INSERT INTO sales (employee_id, product_id, quantity, sale_date)
VALUES
    (2, 1, 20, '2024-10-15'),
    (2, 2, 15, '2024-10-16'),
    (3, 1, 10, '2024-10-17'),
    (3, 3, 5, '2024-10-20'),
    (4, 2, 8, '2024-10-21'),
    (2, 1, 12, '2024-11-01');

SELECT * FROM sales LIMIT 10;


CREATE TABLE IF NOT EXISTS products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    price NUMERIC(10, 2) NOT NULL
);

-- Пример данных
INSERT INTO products (name, price)
VALUES
    ('Product A', 150.00),
    ('Product B', 200.00),
    ('Product C', 100.00);

SELECT * FROM products LIMIT 10;

CREATE TABLE audit_log (
    id SERIAL PRIMARY KEY,
    table_name TEXT,
    operation TEXT,
    changed_time TIMESTAMP
);

-------------------------------------------------------------------------------------------------------
-- Домашнее задание
-- 1. Создать триггеры со всеми возможными ключевыми словами, а также рассмотреть операционные триггеры

--Функция для проверки отделения
CREATE OR REPLACE FUNCTION check_department()
RETURNS TRIGGER AS $$
BEGIN
	IF (NEW.department IS DISTINCT FROM OLD.department) THEN
	    IF NEW.department != 'Sales' AND NEW.department != 'IT' THEN
	        RAISE EXCEPTION 'Отделения "%" не существует', NEW.department;
		ELSE
			RAISE NOTICE 'Отделения "%" существует', NEW.department;
	    END IF;
	END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER department_check_trigger
BEFORE INSERT OR UPDATE ON employees
FOR EACH ROW
WHEN (NEW.department IS NOT NULL)
EXECUTE FUNCTION check_department();

INSERT INTO employees (name, position, department, salary, manager_id)  --триггер сработал и проверил, что всё нормально (отделение существует)
VALUES
	('Alice Johnson', 'Manager', 'Sales', 30000, NULL); 

SELECT * FROM employees LIMIT 10;

INSERT INTO employees (name, position, department, salary, manager_id)  --триггер сработал и выдал ошибку (отделения QA не существует)
VALUES
	('X', 'Manager', 'QA', 30000, NULL); 

SELECT * FROM employees LIMIT 10;

--Функция для логирования операций INSERT DELETE UPDATE TRUNCATE в таблице
CREATE OR REPLACE FUNCTION log_changes()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO audit_log (table_name, operation, changed_time)
    VALUES (TG_TABLE_NAME, TG_OP, NOW());
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_changes_trigger
AFTER INSERT OR UPDATE OR DELETE OR TRUNCATE 
ON employees
FOR EACH STATEMENT
EXECUTE FUNCTION log_changes();

INSERT INTO employees (name, position, department, salary, manager_id) 
VALUES 
	('Artem Pyshnii', 'Manager', 'IT', 60000, NULL); 

DELETE FROM employees 
WHERE employee_id = 9;

SELECT * FROM audit_log LIMIT 10;

UPDATE employees       --триггер department_check_trigger не даёт выполнить запрос
SET department = 'QA'
WHERE employee_id = 1; 

UPDATE employees
SET department = 'IT'
WHERE employee_id = 1; 

SELECT * FROM audit_log LIMIT 10;

--Создадим таблицу Categories и добавим поле Category в таблицу Products
CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    category_name TEXT NOT NULL UNIQUE
);

INSERT INTO categories (category_name)
VALUES
    ('Category 1'),
    ('Category 2');
   
SELECT * FROM categories LIMIT 10;

ALTER TABLE products
ADD COLUMN category_id INT REFERENCES categories(category_id);

UPDATE products 
SET category_id = 1
WHERE name = 'Product A';

UPDATE products 
SET category_id = 2
WHERE name = 'Product B' OR name = 'Product C';

SELECT * FROM products LIMIT 10;

--Создадим представление объединяющее данные из двух таблиц
CREATE VIEW products_details AS
SELECT p.product_id, p.name, p.price, c.category_name
FROM products p 
JOIN
categories c ON c.category_id = p.category_id;

SELECT * FROM products_details LIMIT 10;

--Функция для обработки вставки в представление
CREATE OR REPLACE FUNCTION handle_insert_product()
RETURNS TRIGGER AS $$
BEGIN
    --Берём существующую категорию или создаём новую
    INSERT INTO categories (category_name)
    VALUES (NEW.category_name)
    ON CONFLICT (category_name) DO NOTHING;

    --Добавляем строку в таблицу Products
    INSERT INTO products (name, category_id, price)
    VALUES (
        NEW.name,
        (SELECT category_id FROM categories WHERE category_name = NEW.category_name),
        NEW.price
    );
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER insert_into_products_details
INSTEAD OF INSERT
ON products_details
FOR EACH ROW
EXECUTE FUNCTION handle_insert_product();

INSERT INTO products_details (name, price, category_name)
VALUES ('Product D', 1000, 'Category 3');

INSERT INTO products_details (name, price, category_name)
VALUES ('Product F', 1000, 'Category 1');

SELECT * FROM products_details LIMIT 10;

SELECT * FROM products LIMIT 10;

SELECT * FROM categories LIMIT 10;

-- В задании были использованы следующие ключевые слова для объекта Trigger:
-- {BEFORE | AFTER | INSTEAD OF}
-- {INSERT | UPDATE | DELETE | TRUNCATE}
-- [FOR EACH ROW | FOR EACH STATEMENT]
-- [WHEN (condition)] 

-- 2. Попрактиковаться в созданиях транзакций (привести пример успешной и фейл транзакции, объяснить в комментариях почему она зафейлилась)

--Успешная транзакция
BEGIN;

INSERT INTO employees (name, position, department, salary, manager_id)
VALUES ('Irina Troshina', 'Programmer', 'IT', 30000, 1); 

INSERT INTO employees (name, position, department, salary, manager_id)
VALUES ('Alexey Panov', 'Economist', 'Sales', 30000, 1); 

COMMIT;

--Фейл транзакция
BEGIN;

INSERT INTO employees (name, position, department, salary, manager_id)
VALUES ('Michael Kamov', 'Manager', 'Sales', 30000, NULL); 

INSERT INTO employees (name, position, department, salary, manager_id)
VALUES ('Andrey Egorov', 'Economist', 'QA', 30000, 1); 

COMMIT;

ROLLBACK;

--Фейл произошёл из-за того, что стоит триггер department_check_trigger который не разрешает записывать людей в несуществующие отделы

SELECT * FROM employees LIMIT 15;

-- 3. Использовать RAISE для логирования
-- Raise exception и Raise notice использовались в функции check_department() для триггера department_check_trigger

--Функция, которая оповещает, когда работнику назначен новый менеджер или менеджера сняли
CREATE OR REPLACE FUNCTION change_manager()
RETURNS TRIGGER AS $$
BEGIN
	IF (NEW.manager_id IS DISTINCT FROM OLD.manager_id) THEN
		IF NEW.manager_id IS NULL THEN
			RAISE NOTICE 'C работника % сняли менеджера', NEW.name;
		ELSE
			RAISE NOTICE 'Работнику % назначили менеджера', NEW.name;
		END IF;
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER manager_change_trigger
BEFORE UPDATE OF manager_id ON employees
FOR EACH ROW
EXECUTE FUNCTION change_manager();

SELECT * FROM employees LIMIT 15;

UPDATE employees 
SET manager_id = NULL
WHERE employee_id = 2;