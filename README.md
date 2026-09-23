Assignment Task Overview
Problem Statement:
An online learning platform sells various digital courses to learners across different countries. Each
learner can purchase multiple courses, and each course belongs to a specific category.
The management team wants to analyze purchase data to understand:

● Sales trends
● Learner behavior
● Popular course categories

Your task is to use MySQL to design, query, and extend a relational database to derive meaningful
insights from this e-learning purchase data.
Dataset Description:

You will work with the following three tables:

Table: learners

Column Description

learner_id Primary Key
full_name Learner name
country Country of residence

Table: courses

Column Description

course_id Primary Key
course_name Course title
category Course category
unit_price Price per course

Table: purchases

Task
1. Database Setup & Data Entry
● Create a new database.
● Create the three tables with proper:
○ Primary keys, Foreign keys, Appropriate data types
● Insert sample data:
○ 4–5 learners
○ 4–5 courses (different categories)
○ 6–8 purchase records
2. Data Exploration Using Joins
Use INNER, LEFT, and RIGHT JOIN to:
● Combine learner, course, and purchase data
● Display: Learner name, Course name, Category, Quantity, Total amount, Purchase
date
● Presentation Requirements:
■ Format currency to 2 decimal places
■ Use column aliases
■ Sort by the highest total amount
Columns Description

purchase_id Primary Key
learner_id Foreign Key → learners
course_id Foreign Key → courses
quantity Number of courses purchased
purchase_date Date of purchase

3. Core Analytical Queries (Q1–Q5)
Q1. Display each learner’s total spending with their country.
Q2. Find the top 3 most purchased courses by quantity.
Q3. Show each category’s:
● Total revenue
● Number of unique learners

Q4. List learners who purchased from more than one category.
Q5. Identify courses never purchased.
4. Subqueries & Correlated Subqueries
Q6. Find learners whose total spending is above the average learner spending.
Q7. Display courses whose price is higher than any course in the ‘Beginner’ category.
Q8 . Find learners who spent more than the average spending in their country.
5. CTE, CASE, View, and NULL Handling
Q9. Use a CTE to calculate total spending per learner, then:
Display learners with spending above 10,000.
Q10. CASE Expression
Classify learners based on spending:
● Above 15,000 → “High Value”,
● 8,000–15,000 → “Medium Value”,
● Below 8,000 → “Low Value”.

Q11 . NULL Handling

● Display all courses and replace NULL purchase counts with 0 using: IFNULL() or
COALESCE()

Q12 . View

● Create a view: category_performance_view
● Showing:
● Category
● Total revenue
● Number of purchases
● Average revenue per purchase
