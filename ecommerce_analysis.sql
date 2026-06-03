--table creation -> customers, products, orders

CREATE TABLE customers (
  customer_id INTEGER PRIMARY KEY,
  name        TEXT,
  city        TEXT,
  signup_date TEXT
);

CREATE TABLE products (
  product_id   INTEGER PRIMARY KEY,
  product_name TEXT,
  category     TEXT,
  price        REAL
);

CREATE TABLE orders (
  order_id    INTEGER PRIMARY KEY,
  customer_id INTEGER,
  product_id  INTEGER,
  quantity    INTEGER,
  order_date  TEXT,
  status      TEXT
);

-- inserting data into all 3 tables
INSERT INTO customers VALUES
(1,'Priya Sharma','Mumbai','2023-01-15'),
(2,'Rahul Verma','Delhi','2023-03-22'),
(3,'Sneha Iyer','Bangalore','2023-02-10'),
(4,'Arjun Nair','Chennai','2023-05-01'),
(5,'Divya Patel','Ahmedabad','2023-04-18'),
(6,'Karan Mehta','Mumbai','2023-06-30'),
(7,'Anjali Singh','Delhi','2023-07-14'),
(8,'Rohan Das','Kolkata','2023-08-05');

INSERT INTO products VALUES
(1,'Wireless Earbuds','Electronics',2499),
(2,'Yoga Mat','Fitness',899),
(3,'Laptop Stand','Electronics',1499),
(4,'Water Bottle','Fitness',349),
(5,'Desk Lamp','Home',799),
(6,'Notebook Set','Stationery',299),
(7,'USB Hub','Electronics',1199),
(8,'Running Shoes','Fitness',3299);

INSERT INTO orders VALUES
(1,1,1,1,'2024-01-05','delivered'),
(2,2,3,2,'2024-01-12','delivered'),
(3,3,2,1,'2024-01-18','delivered'),
(4,1,5,1,'2024-02-02','delivered'),
(5,4,1,1,'2024-02-14','cancelled'),
(6,5,8,1,'2024-02-20','delivered'),
(7,2,6,3,'2024-03-01','delivered'),
(8,6,7,1,'2024-03-15','delivered'),
(9,3,4,2,'2024-03-22','delivered'),
(10,7,1,2,'2024-04-04','delivered'),
(11,8,3,1,'2024-04-18','cancelled'),
(12,1,8,1,'2024-04-25','delivered'),
(13,4,5,2,'2024-05-10','delivered'),
(14,5,2,1,'2024-05-18','delivered'),
(15,6,6,4,'2024-06-01','delivered');

--see all products
SELECT * FROM products;

--only electronics
SELECT product_name, price FROM products
WHERE category = 'Electronics'
ORDER BY price DESC;

--customers from Mumbai or Delhi
SELECT name, city FROM customers
WHERE city IN ('Mumbai', 'Delhi')
ORDER BY city;

--total orders per category

SELECT p.category,
       COUNT(o.order_id) AS total_orders
FROM orders o
JOIN products p ON o.product_id = p.product_id
WHERE o.status = 'delivered'
GROUP BY p.category
ORDER BY total_orders DESC;

--revenue by category

SELECT p.category,
       SUM(p.price * o.quantity) AS total_revenue
FROM orders o
JOIN products p ON o.product_id = p.product_id
WHERE o.status = 'delivered'
GROUP BY p.category
ORDER BY total_revenue DESC;

--high value customers only (HAVING)

SELECT c.name,
       COUNT(o.order_id)             AS orders_placed,
       SUM(p.price * o.quantity)     AS total_spent
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN products  p ON o.product_id  = p.product_id
WHERE o.status = 'delivered'
GROUP BY c.customer_id, c.name
HAVING total_spent > 2000
ORDER BY total_spent DESC;

--full order details (3-table join)

SELECT o.order_id,
       c.name        AS customer,
       c.city,
       p.product_name,
       p.category,
       o.quantity,
       (p.price * o.quantity) AS order_value,
       o.order_date,
       o.status
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN products  p ON o.product_id  = p.product_id
ORDER BY o.order_date;

--cancelled orders analysis

SELECT c.name,
       c.city,
       p.product_name,
       p.category,
       o.order_date
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN products  p ON o.product_id  = p.product_id
WHERE o.status = 'cancelled';

--products above average price (subquery)

SELECT product_name, category, price
FROM products
WHERE price > (SELECT AVG(price) FROM products)
ORDER BY price DESC;

--monthly revenue CTE

WITH monthly_revenue AS (
  SELECT strftime('%Y-%m', o.order_date) AS month,
         SUM(p.price * o.quantity)       AS revenue
  FROM orders o
  JOIN products p ON o.product_id = p.product_id
  WHERE o.status = 'delivered'
  GROUP BY month
)
SELECT month,
       revenue,
       ROUND(revenue * 100.0 /
         (SELECT SUM(revenue) FROM monthly_revenue), 1) AS pct_of_total
FROM monthly_revenue
ORDER BY month;
/*
WITH creates a CTE (Common Table Expression) — a temporary named result that can reference like a table. Here monthly_revenue is calculated once, then used twice in the main query (for the revenue and for the percentage calculation). CTEs make complex queries readable. strftime extracts year-month from a date string.
*/

--rank products by revenue (window function)

SELECT p.product_name,
       p.category,
       SUM(p.price * o.quantity)  AS total_revenue,
       RANK() OVER (
         ORDER BY SUM(p.price * o.quantity) DESC
       ) AS revenue_rank
FROM orders o
JOIN products p ON o.product_id = p.product_id
WHERE o.status = 'delivered'
GROUP BY p.product_id, p.product_name, p.category;

/* RANK() OVER is a window function — it assigns a rank to each row without collapsing the rows (unlike GROUP BY). The OVER clause defines what to rank over and in what order.  */

--the insight query 

WITH customer_stats AS (
  SELECT c.customer_id,
         c.name,
         c.city,
         COUNT(o.order_id)            AS total_orders,
         SUM(p.price * o.quantity)    AS total_spent,
         MIN(o.order_date)            AS first_order,
         MAX(o.order_date)            AS last_order
  FROM customers c
  LEFT JOIN orders o   ON c.customer_id = o.customer_id
  LEFT JOIN products p ON o.product_id  = p.product_id
  WHERE o.status = 'delivered' OR o.status IS NULL
  GROUP BY c.customer_id, c.name, c.city
)
SELECT name,
       city,
       total_orders,
       COALESCE(total_spent, 0)   AS total_spent,
       first_order,
       last_order,
       CASE
         WHEN total_spent >= 5000 THEN 'High value'
         WHEN total_spent >= 2000 THEN 'Mid value'
         WHEN total_spent > 0     THEN 'Low value'
         ELSE 'No orders'
       END AS customer_segment
FROM customer_stats
ORDER BY total_spent DESC;

