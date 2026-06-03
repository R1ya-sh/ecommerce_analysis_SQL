# E-commerce Sales Analysis — SQL

## Project summary
Analysed a simulated e-commerce dataset using SQL to uncover revenue trends, customer segments, and product performance.

## Tools used
- SQLite (DB Browser for SQLite)
- SQL concepts: SELECT, JOIN, GROUP BY, subqueries, CTEs, window functions

## Key findings
1. Electronics generated the highest revenue despite fewer orders
2. 3 out of 8 customers qualify as mid-to-high value spenders
3. 2 cancelled orders both involved first-time buyers — possible UX issue
4. Monthly revenue peaked in April 2024

## Queries covered
| Query | Concept used |
| Products by category | SELECT, WHERE, ORDER BY |
| Revenue by category | JOIN, GROUP BY, SUM |
| High-value customers | HAVING, multi-table JOIN |
| Customer segmentation | CTE, LEFT JOIN, CASE, COALESCE |
| Product revenue ranking | Window function, RANK() |
