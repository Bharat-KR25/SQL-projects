
-- Data Analytics - Module End Assignment 3
-- Analyzing E-Learning Platform Purchases using MySQL

-- SECTION 1: DATABASE SETUP & DATA ENTRY

DROP DATABASE IF EXISTS elearning_platform;
CREATE DATABASE elearning_platform;
USE elearning_platform;


DROP TABLE IF EXISTS purchases;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS learners;

CREATE TABLE learners (
    learner_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name  VARCHAR(100) NOT NULL,
    country    VARCHAR(60)  NOT NULL
);

CREATE TABLE courses (
    course_id  INT AUTO_INCREMENT PRIMARY KEY,
    course_name VARCHAR(150) NOT NULL,
    category   VARCHAR(50)  NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL
);

CREATE TABLE purchases (
    purchase_id   INT AUTO_INCREMENT PRIMARY KEY,
    learner_id    INT NOT NULL,
    course_id     INT NOT NULL,
    quantity      INT NOT NULL DEFAULT 1,
    purchase_date DATE NOT NULL,
    FOREIGN KEY (learner_id) REFERENCES learners(learner_id),
    FOREIGN KEY (course_id)  REFERENCES courses(course_id)
);


INSERT INTO learners (learner_id, full_name, country) VALUES
(1, 'Alice Johnson', 'USA'),
(2, 'Rahul Mehta',   'India'),
(3, 'Chen Wei',      'China'),
(4, 'Sofia Rossi',   'Italy'),
(5, 'John Smith',    'USA'),
(6, 'Emma Clarke',   'United Kingdom');

-- ---- Sample Data: Courses ----

INSERT INTO courses (course_id, course_name, category, unit_price) VALUES
(101, 'Python for Beginners',            'Beginner',     2000.00),
(102, 'Excel Basics',                    'Beginner',     1200.00),
(103, 'Advanced Machine Learning',       'Advanced',    15000.00),
(104, 'Digital Marketing Fundamentals',  'Intermediate', 5000.00),
(105, 'Cloud Architecture Mastery',      'Expert',      18000.00);

-- ---- Sample Data: Purchases ----
INSERT INTO purchases (purchase_id, learner_id, course_id, quantity, purchase_date) VALUES
(1, 1, 101, 1, '2024-01-15'),
(2, 1, 103, 1, '2024-02-10'),
(3, 2, 102, 2, '2024-01-20'),
(4, 2, 104, 2, '2024-03-05'),
(5, 3, 104, 1, '2024-02-25'),
(6, 4, 101, 3, '2024-01-30'),
(7, 4, 103, 1, '2024-03-15'),
(8, 5, 102, 1, '2024-02-05');


 
-- SECTION 2: DATA EXPLORATION USING JOINS


-- ---- 2a. INNER JOIN: only learners who purchased, only courses that sold ----
SELECT
    l.full_name                      AS learner_name,
    c.course_name                    AS course_name,
    c.category                       AS category,
    p.quantity                       AS quantity,
    FORMAT(p.quantity * c.unit_price, 2) AS total_amount,
    p.purchase_date                  AS purchase_date
FROM purchases p
INNER JOIN learners l ON p.learner_id = l.learner_id
INNER JOIN courses  c ON p.course_id  = c.course_id
ORDER BY (p.quantity * c.unit_price) DESC;

-- ---- 2b. LEFT JOIN: every learner, including those with no purchases ----
SELECT
    l.full_name                      AS learner_name,
    c.course_name                    AS course_name,
    c.category                       AS category,
    p.quantity                       AS quantity,
    FORMAT(p.quantity * c.unit_price, 2) AS total_amount,
    p.purchase_date                  AS purchase_date
FROM learners l
LEFT JOIN purchases p ON l.learner_id = p.learner_id
LEFT JOIN courses  c  ON p.course_id  = c.course_id
ORDER BY (p.quantity * c.unit_price) DESC;

-- ---- 2c. RIGHT JOIN: every course, including ones never purchased ----
SELECT
    l.full_name                      AS learner_name,
    c.course_name                    AS course_name,
    c.category                       AS category,
    p.quantity                       AS quantity,
    FORMAT(p.quantity * c.unit_price, 2) AS total_amount,
    p.purchase_date                  AS purchase_date
FROM purchases p
RIGHT JOIN courses  c ON p.course_id  = c.course_id
LEFT JOIN  learners l ON p.learner_id = l.learner_id
ORDER BY (p.quantity * c.unit_price) DESC;



-- SECTION 3: CORE ANALYTICAL QUERIES (Q1-Q5)


-- ---- Q1: Each learner's total spending with their country ----
SELECT
    l.full_name AS learner_name,
    l.country   AS country,
    FORMAT(SUM(p.quantity * c.unit_price), 2) AS total_spending
FROM learners l
JOIN purchases p ON l.learner_id = p.learner_id
JOIN courses  c  ON p.course_id  = c.course_id
GROUP BY l.learner_id, l.full_name, l.country
ORDER BY SUM(p.quantity * c.unit_price) DESC;

-- ---- Q2: Top 3 most purchased courses by quantity ----
SELECT
    c.course_name AS course_name,
    c.category    AS category,
    SUM(p.quantity) AS total_quantity_sold
FROM purchases p
JOIN courses c ON p.course_id = c.course_id
GROUP BY c.course_id, c.course_name, c.category
ORDER BY total_quantity_sold DESC
LIMIT 3;

-- ---- Q3: Each category's total revenue and number of unique learners ----
SELECT
    c.category AS category,
    FORMAT(SUM(p.quantity * c.unit_price), 2) AS total_revenue,
    COUNT(DISTINCT p.learner_id) AS unique_learners
FROM purchases p
JOIN courses c ON p.course_id = c.course_id
GROUP BY c.category
ORDER BY SUM(p.quantity * c.unit_price) DESC;

-- ---- Q4: Learners who purchased from more than one category ----
SELECT
    l.full_name AS learner_name,
    COUNT(DISTINCT c.category) AS category_count
FROM learners l
JOIN purchases p ON l.learner_id = p.learner_id
JOIN courses  c  ON p.course_id  = c.course_id
GROUP BY l.learner_id, l.full_name
HAVING COUNT(DISTINCT c.category) > 1
ORDER BY category_count DESC;

-- ---- Q5: Courses never purchased ----
SELECT
    c.course_id   AS course_id,
    c.course_name AS course_name,
    c.category    AS category
FROM courses c
LEFT JOIN purchases p ON c.course_id = p.course_id
WHERE p.purchase_id IS NULL;

-- SECTION 4: SUBQUERIES & CORRELATED SUBQUERIES (Q6-Q8)

-- ---- Q6: Learners whose total spending is above the average learner spending ----

SELECT
    l.full_name AS learner_name,
    FORMAT(lt.total_spending, 2) AS total_spending
FROM learners l
JOIN (
    SELECT learner_id, SUM(quantity * unit_price) AS total_spending
    FROM purchases p
    JOIN courses c ON p.course_id = c.course_id
    GROUP BY learner_id
) lt ON l.learner_id = lt.learner_id
WHERE lt.total_spending > (
    SELECT AVG(learner_total)
    FROM (
        SELECT SUM(quantity * unit_price) AS learner_total
        FROM purchases p
        JOIN courses c ON p.course_id = c.course_id
        GROUP BY learner_id
    ) AS avg_calc
)
ORDER BY lt.total_spending DESC;

-- ---- Q7: Courses whose price is higher than ANY course in the 'Beginner' category ----

SELECT
    course_name AS course_name,
    category    AS category,
    FORMAT(unit_price, 2) AS unit_price
FROM courses
WHERE unit_price > ANY (
    SELECT unit_price FROM courses WHERE category = 'Beginner'
)
ORDER BY unit_price DESC;

-- ---- Q8: Learners who spent more than the average spending in their own country ----
SELECT
    l.full_name AS learner_name,
    l.country   AS country,
    FORMAT(SUM(p.quantity * c.unit_price), 2) AS total_spending
FROM learners l
JOIN purchases p ON l.learner_id = p.learner_id
JOIN courses  c  ON p.course_id  = c.course_id
GROUP BY l.learner_id, l.full_name, l.country
HAVING SUM(p.quantity * c.unit_price) > (
    SELECT AVG(learner_total)
    FROM (
        SELECT l2.learner_id, SUM(p2.quantity * c2.unit_price) AS learner_total
        FROM learners l2
        JOIN purchases p2 ON l2.learner_id = p2.learner_id
        JOIN courses  c2  ON p2.course_id  = c2.course_id
        WHERE l2.country = l.country
        GROUP BY l2.learner_id
    ) AS country_avg
)
ORDER BY total_spending DESC;



-- SECTION 5: CTE, CASE, VIEW, AND NULL HANDLING (Q9-Q12) 

-- ---- Q9: CTE to calculate total spending per learner, then filter > 10,000 ----
WITH learner_spending AS (
    SELECT
        l.learner_id,
        l.full_name,
        SUM(p.quantity * c.unit_price) AS total_spending
    FROM learners l
    JOIN purchases p ON l.learner_id = p.learner_id
    JOIN courses  c  ON p.course_id  = c.course_id
    GROUP BY l.learner_id, l.full_name
)
SELECT
    full_name AS learner_name,
    FORMAT(total_spending, 2) AS total_spending
FROM learner_spending
WHERE total_spending > 10000
ORDER BY total_spending DESC;

-- ---- Q10: CASE expression to classify learners by spending tier ----
WITH learner_spending AS (
    SELECT
        l.learner_id,
        l.full_name,
        SUM(p.quantity * c.unit_price) AS total_spending
    FROM learners l
    JOIN purchases p ON l.learner_id = p.learner_id
    JOIN courses  c  ON p.course_id  = c.course_id
    GROUP BY l.learner_id, l.full_name
)
SELECT
    full_name AS learner_name,
    FORMAT(total_spending, 2) AS total_spending,
    CASE
        WHEN total_spending > 15000 THEN 'High Value'
        WHEN total_spending BETWEEN 8000 AND 15000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS value_segment
FROM learner_spending
ORDER BY total_spending DESC;

-- ---- Q11: NULL handling - all courses, NULL purchase counts replaced with 0 ----
SELECT
    c.course_id   AS course_id,
    c.course_name AS course_name,
    c.category    AS category,
    COALESCE(SUM(p.quantity), 0) AS total_units_purchased
    
FROM courses c
LEFT JOIN purchases p ON c.course_id = p.course_id
GROUP BY c.course_id, c.course_name, c.category
ORDER BY total_units_purchased DESC;

-- ---- Q12: View - category_performance_view ----
CREATE OR REPLACE VIEW category_performance_view AS
SELECT
    c.category AS category,
    SUM(p.quantity * c.unit_price) AS total_revenue,
    COUNT(p.purchase_id) AS number_of_purchases,
    ROUND(SUM(p.quantity * c.unit_price) / COUNT(p.purchase_id), 2) AS avg_revenue_per_purchase
FROM purchases p
JOIN courses c ON p.course_id = c.course_id
GROUP BY c.category;

-- Query the view
SELECT
    category,
    FORMAT(total_revenue, 2) AS total_revenue,
    number_of_purchases,
    FORMAT(avg_revenue_per_purchase, 2) AS avg_revenue_per_purchase
FROM category_performance_view
ORDER BY total_revenue DESC;
