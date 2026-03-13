# 🍕 Pizza Sales Analysis Project

## 📊 Project Overview

This project presents an end‑to‑end **SQL data analysis of a Pizza Sales dataset**. The goal is to transform raw transactional order data into **actionable business insights** using structured SQL queries.

The analysis focuses on identifying:

* 💰 Revenue performance
* 🍕 Product popularity
* 🕒 Customer ordering patterns
* 📈 Sales trends over time

The SQL analysis is organized into **three progressive analytical levels** to demonstrate increasing query complexity:

* 🟢 Basic Analysis
* 🟡 Intermediate Analysis
* 🔴 Advanced Analysis

These queries can be executed in **MySQL or PostgreSQL environments** and can support further integration with **BI tools such as Power BI, Excel, or Tableau**.

---

# 🗄️ Database Setup

```sql
CREATE DATABASE IF NOT EXISTS PIZZAS;
USE PIZZAS;
```

---

# 📁 Dataset Tables

| Table         | Description                                         |
| ------------- | --------------------------------------------------- |
| orders        | Stores order information including date and time    |
| order_details | Contains the quantity of pizzas purchased per order |
| pizzas        | Stores pizza size and price information             |
| pizza_types   | Contains pizza names and category classifications   |

---

# 🔗 Table Relationships

| Primary Table | Foreign Table | Key           |
| ------------- | ------------- | ------------- |
| orders        | order_details | order_id      |
| pizzas        | order_details | pizza_id      |
| pizza_types   | pizzas        | pizza_type_id |

These relationships allow the dataset to connect **orders, pizza types, and pricing data** for comprehensive analysis.

---

# 🟢 Basic SQL Analysis

## 1️⃣ Total Number of Orders

```sql
SELECT DISTINCT COUNT(order_id) AS total_orders
FROM orders;
```

| Metric       | Description                          |
| ------------ | ------------------------------------ |
| Total Orders | Total number of unique orders placed |

---

## 2️⃣ Total Revenue Generated

```sql
SELECT CONCAT("$ ", ROUND(SUM(od.quantity * p.price),2)) AS total_revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id;
```

| Metric  | Formula          |
| ------- | ---------------- |
| Revenue | Quantity × Price |

---

## 3️⃣ Highest Priced Pizza

```sql
SELECT p.price, pt.name
FROM pizzas p
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;
```

This query identifies the **most expensive pizza available on the menu**.

---

## 4️⃣ Most Common Pizza Size Ordered

```sql
SELECT p.size, SUM(od.quantity) AS total_orders
FROM order_details od
JOIN pizzas p ON p.pizza_id = od.pizza_id
GROUP BY p.size
ORDER BY total_orders DESC;
```

This analysis highlights **which pizza size customers order the most**.

---

## 5️⃣ Top 5 Most Ordered Pizza Types

```sql
SELECT p.pizza_type_id, SUM(o.quantity) AS total_quantities
FROM order_details o
JOIN pizzas p ON p.pizza_id = o.pizza_id
GROUP BY p.pizza_type_id
ORDER BY total_quantities DESC
LIMIT 5;
```

| Rank | Description                                   |
| ---- | --------------------------------------------- |
| 1–5  | Pizza types with the highest order quantities |

---

# 🟡 Intermediate SQL Analysis

## 6️⃣ Total Quantity Ordered by Pizza Category

```sql
SELECT SUM(od.quantity) AS total_quantities, pt.category
FROM order_details od
JOIN pizzas p ON p.pizza_id = od.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category;
```

This query evaluates **which pizza categories generate the highest demand**.

---

## 7️⃣ Distribution of Orders by Hour

```sql
SELECT HOUR(time) AS hours, COUNT(order_id) AS total_orders
FROM orders
GROUP BY hours
ORDER BY total_orders DESC;
```

| Insight   | Description                               |
| --------- | ----------------------------------------- |
| Peak Hour | Time period with the highest order volume |

---

## 8️⃣ Category‑wise Pizza Distribution

```sql
SELECT pt.category, COUNT(p.pizza_id) AS no_pizzas
FROM pizza_types pt
JOIN pizzas p ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category;
```

This query shows **how many pizzas exist in each category**.

---

## 9️⃣ Average Number of Pizzas Ordered Per Day

```sql
WITH avg_pizzas_ordered AS (
SELECT o.date, SUM(od.quantity) AS sum_pizzas
FROM order_details od
JOIN orders o ON od.order_id = o.order_id
GROUP BY o.date
)
SELECT AVG(sum_pizzas) AS avg_per_day
FROM avg_pizzas_ordered;
```

This helps measure **average daily demand**.

---

## 🔟 Top 3 Pizza Types by Revenue

```sql
SELECT pt.name, SUM(p.price * od.quantity) AS most_revenue
FROM pizzas p
JOIN order_details od ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.name
ORDER BY most_revenue DESC
LIMIT 3;
```

This identifies the **most profitable pizzas**.

---

# 🔴 Advanced SQL Analysis

## 1️⃣1️⃣ Revenue Contribution Percentage

```sql
SELECT
pt.name,
SUM(p.price * od.quantity) *100 / SUM(SUM(p.price * od.quantity)) OVER() AS revenue_percentage
FROM pizzas p
JOIN order_details od ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.name
ORDER BY revenue_percentage DESC;
```

This determines **how much each pizza contributes to total revenue**.

---

## 1️⃣2️⃣ Cumulative Revenue Over Time

```sql
SELECT ord.date,
SUM(p.price * od.quantity) AS daily_revenue,
SUM(SUM(p.price * od.quantity)) OVER (ORDER BY ord.date) AS cumulative_revenue
FROM pizzas p
JOIN order_details od ON p.pizza_id = od.pizza_id
JOIN orders ord ON od.order_id = ord.order_id
GROUP BY ord.date
ORDER BY ord.date;
```

This analysis tracks **revenue growth trends over time**.

---

## 1️⃣3️⃣ Top 3 Pizzas per Category by Revenue

```sql
SELECT name, category, revenue
FROM (
SELECT
pt.name,
pt.category,
SUM(p.price * od.quantity) AS revenue,
ROW_NUMBER() OVER (
PARTITION BY pt.category
ORDER BY SUM(p.price * od.quantity) DESC
) AS rn
FROM pizzas p
JOIN order_details od ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.name, pt.category
) t
WHERE rn <= 3
ORDER BY category, revenue DESC;
```

This highlights **top‑performing pizzas within each category**.

---

## 1️⃣4️⃣ Top 5 Days with Highest Revenue

```sql
SELECT o.date, ROUND(SUM(p.price * od.quantity),2) AS revenue
FROM orders o
JOIN order_details od ON od.order_id = o.order_id
JOIN pizzas p ON od.pizza_id = p.pizza_id
GROUP BY date
ORDER BY revenue DESC
LIMIT 5;
```

---

## 1️⃣5️⃣ Busiest Day of the Week

```sql
SELECT DAYNAME(date) AS days,
COUNT(order_id) AS total_orders
FROM orders
GROUP BY days
ORDER BY total_orders DESC;
```

This query identifies **which day generates the most orders**.

---

## 1️⃣6️⃣ Rank Pizzas by Quantity Sold

```sql
SELECT pt.name,
SUM(od.quantity) AS quantity_sold,
RANK() OVER(
ORDER BY SUM(od.quantity) DESC
) AS rnk
FROM pizzas p
JOIN order_details od ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.name;
```

---

## 1️⃣7️⃣ Revenue Growth Compared to Previous Day

```sql
SELECT o.date,
ROUND(SUM(p.price * od.quantity),2) AS revenue,
LAG(ROUND(SUM(p.price * od.quantity),2)) OVER(
ORDER BY o.date ASC
) AS previous_day
FROM orders o
JOIN order_details od ON od.order_id = o.order_id
JOIN pizzas p ON od.pizza_id = p.pizza_id
GROUP BY o.date;
```

This measures **day‑to‑day revenue change**.

---

# 📊 Visualization Suggestions

The following dashboards can be created using **Power BI, Excel, or Tableau**:

| Analysis              | Visualization        |
| --------------------- | -------------------- |
| Revenue Trend         | Line Chart           |
| Orders by Hour        | Bar Chart            |
| Revenue Contribution  | Pie Chart            |
| Top Pizzas            | Horizontal Bar Chart |
| Category Distribution | Donut Chart          |

---

# 🏗 Project Structure

```
pizza-sales-analysis

├── dataset
│   └── order_details.csv
|   └── orders.csv
|   └── pizza_types.csv

├── sql
│   └── pizza_analysis_queries.sql

├── dashboard
│   └── pizza_dashboard.png

├── images
│   ├── database_schema.png
│   ├── query_output_examples.png
│   └── dashboard_visualization.png

└── README.md
```

---

# 🔌 Database Connection Example

```
Host: localhost
Port: 3306
Database: pizzas
```

---

# 📈 Key Business Insights

* Identifies top‑performing pizza categories
* Highlights peak ordering hours
* Tracks revenue growth trends
* Supports demand forecasting

---

# 🧰 Technology Stack

| Tool             | Purpose             |
| ---------------- | ------------------- |
| SQL              | Data Analysis       |
| MySQL            | Database Management |
| Power BI / Excel | Visualization       |
| GitHub           | Version Control     |

---

# 👨‍💻 Author

*Prajyot wadibhasme*
Data Analyst | SQL | Power BI | Python
