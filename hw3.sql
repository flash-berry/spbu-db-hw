CREATE DATABASE lenta;

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

SELECT * FROM employees LIMIT 6;

CREATE TABLE IF NOT EXISTS sales(
    sale_id SERIAL PRIMARY KEY,
    employee_id INT REFERENCES employees(employee_id),
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    sale_date DATE NOT NULL
);

-- Пример данных
INSERT INTO sales (employee_id, product_id, quantity, sale_date)
values
	(4, 2, 24, '2024-10-21'),
    (2, 1, 20, '2024-11-15'),
    (2, 2, 15, '2024-11-14'),
    (3, 1, 10, '2024-11-08'),
    (3, 3, 9, '2024-11-09'),
    (3, 3, 13, '2024-11-20'),
    (4, 3, 5, '2024-11-15'),
    (4, 2, 8, '2024-11-21'),
    (2, 1, 12, '2024-11-01');

SELECT * FROM sales LIMIT 9;

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

SELECT * FROM products LIMIT 3;

-- Создайте временную таблицу high_sales_products, которая будет содержать продукты, проданные в количестве более 10 единиц за последние 7 дней.
-- Выведите данные из таблицы high_sales_products.
CREATE TEMP TABLE high_sales_products AS
SELECT product_id, SUM(quantity) 
FROM sales
WHERE sale_date BETWEEN CURRENT_DATE - INTERVAL '7 days' AND CURRENT_DATE
GROUP BY product_id
HAVING SUM(quantity) > 10;

SELECT * FROM high_sales_products LIMIT 5;

-- Создайте CTE employee_sales_stats, который посчитает общее количество продаж и среднее количество продаж для каждого сотрудника за последние 30 дней.
-- Напишите запрос, который выводит сотрудников с количеством продаж выше среднего по компании.
WITH employee_sales_stats AS (
    SELECT 
        employee_id,
        SUM(quantity) AS total_sales,
        AVG(quantity) AS avg_sales
    FROM sales
    WHERE sale_date BETWEEN CURRENT_DATE - INTERVAL '30 days' AND CURRENT_DATE
    GROUP BY employee_id
)
SELECT employee_id
FROM employee_sales_stats, (
	SELECT AVG(avg_sales) AS avg_sales_company
	FROM employee_sales_stats
) AS dop_table
WHERE total_sales > avg_sales_company;

-- Используя CTE, создайте иерархическую структуру, показывающую всех сотрудников, которые подчиняются конкретному менеджеру.
-- Напишите запрос с CTE, который выведет топ-3 продукта по количеству продаж за текущий месяц и за прошлый месяц. В результатах должно быть указано, к какому месяцу относится каждая запись.
WITH employee_hierarchy AS (
    SELECT e1.name AS manager, e2.name AS employee
    FROM employees e1
    JOIN employees e2 ON e1.employee_id = e2.manager_id
)
SELECT * FROM employee_hierarchy LIMIT 5;

WITH monthly_sales AS (
    SELECT 
        product_id,
        SUM(quantity) AS total_sales,
        'текущий месяц' AS month_period
    FROM sales
    WHERE date_trunc('month', sale_date) = date_trunc('month', CURRENT_DATE)
    GROUP BY product_id, month_period
    UNION ALL
    SELECT 
        product_id,
        SUM(quantity) AS total_sales,
        'прошлый месяц' AS month_period
    FROM sales
    WHERE date_trunc('month', sale_date) = date_trunc('month', CURRENT_DATE - INTERVAL '1 month')
    GROUP BY product_id, month_period
)SELECT * FROM monthly_sales
ORDER BY total_sales DESC
LIMIT 3;

-- Создайте индекс для таблицы sales по полю employee_id и sale_date, чтобы ускорить запросы, которые фильтруют данные по сотрудникам и датам.
-- Проверьте, как наличие индекса влияет на производительность следующего запроса, используя EXPLAIN ANALYZE.

-- Увеливаем объём данных
INSERT INTO sales (employee_id, product_id, quantity, sale_date)
SELECT
    ((random() * 5) + 1)::INT,
    ((random() * 3) + 1)::INT,
    ((random() * 0) + 1)::INT,
    CURRENT_DATE + (random() * 10)::INT
FROM generate_series(1, 100000); -- 100000 строк

-- Создаём индекс
CREATE INDEX idx_sales_employee_date ON sales (employee_id, sale_date);

-- Запрос с индексом idx_sales_employee_date
-- Planning Time: 0.181 ms
-- Execution Time: 0.067 ms
EXPLAIN ANALYZE
SELECT employee_id, sale_date
FROM sales
WHERE employee_id = 4 AND sale_date = '2024-11-15';

DROP INDEX idx_sales_employee_date;

-- Запрос без индекса
-- Planning Time: 1.222 ms
-- Execution Time: 13.983 ms
EXPLAIN ANALYZE
SELECT employee_id, sale_date
FROM sales
WHERE employee_id = 4 AND sale_date = '2024-11-15';

-- Выполнение запроса с индексом ускорило Plannig Time запроса в 6.75 раз, а Executuion Time запроса в 208.7 раз

-- Используя EXPLAIN, проанализируйте запрос, который находит общее количество проданных единиц каждого продукта.

-- Первоочерёдно выполняется функция агрегации SUM() - HashAggregate  (cost=2774.14..2774.18 rows=4 width=12) (actual time=51.400..51.404 rows=4 loops=1):
--	cost=2774.14..2774.18:
--		2774.14: Оценочные начальные затраты на выполнение операции.
--		2774.18: Оценочные конечные затраты.
--  	Затраты включают чтение данных, вычисления и использование памяти.
-- 	rows=4: Оценочное количество строк, которое операция должна вернуть (здесь — 4 строки).
--  width=12: Средний размер одной строки в байтах
--  actual time=51.400..51.404:
--		51.400: Время начала выполнения операции (в миллисекундах).
--		51.404: Время окончания выполнения операции.
--		Разница между этими значениями — это время, затраченное на выполнение операции (около 0.004 мс).
--  loops=1: Указывает, что операция выполнялась один раз.
--
-- Затем выполняется группировка по полю product_id - Group Key: product_id
-- 	Group Key: product_id: Указывает, что группировка данных выполнялась по полю product_id. Это соответствует ключу в запросе GROUP BY product_id.
-- 
-- Batches: 1 Memory Usage: 24kB:
--	Batches: 1: Указывает, что вся хэш-таблица для агрегации уместилась в оперативной памяти и не потребовалось разбивать её на партии (batches) для записи на диск.
--  Memory Usage: 24kB: Показывает, что хэш-таблица использовала 24 килобайта оперативной памяти.
--
-- Указано, что при выполнении запроса использовалось полное сканирование таблицы - ->  Seq Scan on sales  (cost=0.00..1.09 rows=9 width=8) (actual time=0.022..0.031 rows=58 loops=1)
-- 	cost=0.00..2274.09:
-- 		0.00: Начальная оценка стоимости операции (без затрат на чтение данных).
--		2274.09: Конечная оценка стоимости операции (с учётом затрат на чтение всех строк таблицы).
--	rows=100009: Оценочное количество строк в таблице sales (здесь — 100009 строк).
--	width=8: Средний размер одной строки в байтах (здесь — 8 байт, вероятно, для двух числовых столбцов).
-- 	actual time=0.018..12.352:
--		0.018: Время начала выполнения последовательного сканирования.
--		12.352: Время окончания выполнения последовательного сканирования.
--		Разница (около 12.3 мс) — это время, затраченное на последовательное чтение всех строк таблицы.
--		loops=1: Операция была выполнена один раз.
--
-- Planning Time: 0.141 ms:
--  Planning Time: Время, затраченное на анализ запроса и построение плана выполнения.
-- 
-- Execution Time: 51.448 ms:
--  Execution Time: Общее время выполнения запроса, включая все этапы. В данном случае выполнение запроса заняло около 51.4 мс.
EXPLAIN ANALYZE
SELECT product_id, SUM(quantity)
FROM sales
GROUP BY product_id;