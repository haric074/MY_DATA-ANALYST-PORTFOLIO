
/* --------------------
   Case Study Questions
   --------------------

 1. What is the total amount each customer spent at the restaurant?
 2. How many days has each customer visited the restaurant?
 3. What was the first item from the menu purchased by each customer?
 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
 5. Which item was the most popular for each customer?
 6. Which item was purchased first by the customer after they became a member?
 7. Which item was purchased just before the customer became a member?
 8. What is the total items and amount spent for each member before they became a member?
 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
*/
-- Select table Query:

-- Create tables and insert data

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 
CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  
CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

-- Select data from tables

SELECT * FROM dbo.sales;
SELECT * FROM dbo.menu;
SELECT * FROM dbo.members;

-- What is the total amount each customer spent at the restaurant?

SELECT s.customer_id AS customerID, SUM(m.price) AS totalsales FROM sales s 
JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id;

-- How many days has each customer visited the restaurant?

SELECT customer_id, COUNT(DISTINCT order_date) AS visit_count
FROM dbo.sales
GROUP BY customer_id;

-- What was the first item from the menu purchased by each customer?

-- Main query: 
SELECT customer_id, MIN(product_name) AS product_name FROM ordered_sales WHERE rank = 1
GROUP BY customer_id;

-- Subquery:
SELECT s.customer_id, m.product_name, 
  DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS rank
FROM sales s
JOIN menu m ON s.product_id = m.product_id;

-- Example of DENSE_RANK() function:
CREATE TABLE student_scores (
  student_id INT,
  score INT
);

INSERT INTO student_scores VALUES (1, 85);
INSERT INTO student_scores VALUES (2, 92);
INSERT INTO student_scores VALUES (3, 78);
INSERT INTO student_scores VALUES (4, 92);
INSERT INTO student_scores VALUES (5, 85);
INSERT INTO student_scores VALUES (6, 78);

SELECT student_id, score,
  DENSE_RANK() OVER (ORDER BY score DESC) AS score_rank
FROM student_scores;
/*
 Output:
 | student_id | score | score_rank |  Students with the same score receive the same rank, and the next rank is not skipped.
 |------------|-------|------------|  For example,both students with a score of 92 receive a rank of 1, and students
 | 2          | 92    | 1          |  with a score of 85 receive a rank of 2.This is how DENSE_RANK() works to with a score 
 | 4          | 92    | 1          |  of 85 receive a rank of 2.This is how DENSE_RANK() works to provide a ranking without 
 | 1          | 85    | 2          |  gaps for tied values
 | 5          | 85    | 2          |
 | 3          | 78    | 3          |
 | 6          | 78    | 3          |

*/

SELECT 
  customer_id, 
  MIN(product_name) AS product_name
FROM (
  SELECT 
    s.customer_id, 
    m.product_name,
    DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS rank
  FROM sales s
  JOIN menu m ON s.product_id = m.product_id
) ordered_sales
WHERE rank = 1
GROUP BY customer_id,product_name order by customer_id;

-- What is the most purchased item on the menu and how many times was it purchased by all customers

SELECT TOP 1
  menu.product_name, COUNT(sales."product_id") AS product_count
FROM menu 
JOIN sales ON menu."product_id" = sales."product_id"
GROUP BY menu.product_name
ORDER BY product_count DESC;

-- Which item was the most popular for each customer

SELECT 
  customer_id, 
  product_name, 
  order_count
FROM (
  SELECT 
    s.customer_id, 
    m.product_name, 
    COUNT(m.product_id) AS order_count,
    DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY COUNT(s.customer_id) DESC) AS rank
  FROM menu m
  JOIN sales s ON m.product_id = s.product_id
  GROUP BY s.customer_id, m.product_name
) ranked_data
WHERE rank = 1;

-- Which item was purchased first by the customer after they became a member

WITH RankedPurchases AS (
  SELECT
    s.customer_id,
    m.product_name,
    s.order_date,
    ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS purchase_rank
  FROM
    sales s
    JOIN menu m ON s.product_id = m.product_id
    JOIN members mem ON s.customer_id = mem.customer_id AND s.order_date > mem.join_date
  WHERE
    s.order_date >= mem.join_date
)
SELECT
  customer_id,
  product_name
FROM
  RankedPurchases
WHERE
  purchase_rank = 1;

-- Which item was purchased just before the customer became a member

WITH purchased_prior_member AS (
  SELECT 
    m.customer_id, 
    s.product_id,
    ROW_NUMBER() OVER (
      PARTITION BY m.customer_id
      ORDER BY s.order_date DESC
    ) AS rank
  FROM 
    members m
    JOIN sales s
      ON m.customer_id = s.customer_id
      AND s.order_date < m.join_date
)

SELECT 
  ppm.customer_id, 
  menu.product_name 
FROM 
  purchased_prior_member ppm
  JOIN menu menu
    ON ppm.product_id = menu.product_id
WHERE 
  ppm.rank = 1
ORDER BY 
  ppm.customer_id ASC;

-- What is the total items and amount spent for each member before they became a member

SELECT 
  sales.customer_id, 
  COUNT(sales.product_id) AS No_of_products, 
  SUM(menu.price) AS total_sales
FROM 
  sales 
  JOIN members ON sales.customer_id = members.customer_id AND sales.order_date < members.join_date 
  JOIN menu ON sales.product_id = menu.product_id
GROUP BY 
  sales.customer_id
ORDER BY 
  sales.customer_id;

-- If each $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have?

WITH Total$ AS (
  SELECT 
    menu.product_id, 
    CASE
      WHEN product_id = 1 THEN price * 20
      ELSE price * 10
    END AS points
  FROM menu
)
SELECT 
  sales.customer_id, 
  SUM(Total$.points) AS total_points 
FROM 
  sales
  JOIN Total$ ON sales.product_id = Total$.product_id
GROUP BY 
  sales.customer_id
ORDER BY 
  sales.customer_id;

-- Join All the tables
-- CREATE TABLE Dannys_Dinner_sorted AS
SELECT 
  sales.customer_id, 
  sales.order_date, 
  sales.product_id, 
  menu.product_name, 
  menu.price,
  CASE
    WHEN members.join_date > sales.order_date THEN 'N'
    WHEN members.join_date <= sales.order_date THEN 'Y'
    ELSE 'N' 
  END AS Subscription_status
FROM 
  sales
  LEFT JOIN members ON sales.customer_id = members.customer_id
  JOIN menu ON sales.product_id = menu.product_id
ORDER BY 
  sales.customer_id, 
  sales.order_date;



