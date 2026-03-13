create database project_joint;
use project_joint;

select * from pizzas;
select * from pizza_types;
select * from orders;
select * from order_details;

-- Basic:
-- 1. Retrieve the total number of orders placed.
select count(order_id) from orders;

-- 2. Calculate the total revenue generated from pizza sales.
select sum(p.price * od.quantity)  from pizzas p
join order_details od on p.pizza_id = od.pizza_id;

-- 3. Identify the highest-priced pizza.
select pt.name, p.price from pizza_types pt
join pizzas p on p.pizza_type_id =  pt.pizza_type_id
order by p.price desc
limit 1;

-- 4. Identify the most common pizza size ordered.
select p.size ,sum(od.quantity) as total  from  order_details od 
join pizzas p on od.pizza_id = p.pizza_id 
join pizza_types pt on p.pizza_type_id =pt.pizza_type_id 
group by p.size
order by total desc
limit 1 ;

-- 5. List the top 5 most ordered pizza types along with their quantities.
select pt.name , sum(od.quantity) as total_quantity from order_details od
join pizzas p on p.pizza_id = od.pizza_id
join pizza_types pt on pt.pizza_type_id = p.pizza_type_id
group by pt.name
order by total_quantity desc
limit 5 ;

-- Question Intermediate:
-- 6. Join the necessary tables to find the total quantity of each pizza category ordered.
select pt.category , sum(od.quantity) as total_count from order_details od
join pizzas p on od.pizza_id = p.pizza_id
join pizza_types pt on pt.pizza_type_id = p.pizza_type_id
group by category;  

-- 7. Determine the distribution of orders by hour of the day.
select hour(time) as order_hour ,
count(order_id) as total_order from orders
group by order_hour 
order by total_order desc;

-- 8. Join relevant tables to find thse category-wise distribution of pizzas.
select pt.category,count(p.pizza_id) as no_pizza from pizza_types pt
join pizzas p on p.pizza_type_id = pt.pizza_type_id
group by pt.category;

-- 9. Group the orders by date and calculate the average number of pizzas ordered per day.
 with avg_pizza as(
 select o.date , sum(od.quantity) as sum_quantity from order_details od
 join orders o on o.order_id = od.order_id 
 group by o.date)
 select avg(sum_quantity) as total_avg from avg_pizza;
 
 -- 10. Determine the top 3 most ordered pizza types based on revenue.
select pt.name , sum(od.quantity * price) as total_revenue from order_details od
join pizzas p on p.pizza_id = od.pizza_id
join pizza_types pt on pt.pizza_type_id = p.pizza_type_id
group by pt.name
order by total_revenue desc
limit 3;

-- Advanced:
-- 11. Calculate the percentage contribution of each pizza type to total revenue.
select pt.name , sum(p.price * od.quantity) * 100 / sum(sum(p.price * od.quantity)) over() as revenu_percentage
from pizzas p join order_details od on p.pizza_id = od.pizza_id
join pizza_types pt on pt.pizza_type_id = p.pizza_type_id
group by pt.name
order by revenu_percentage desc;

-- 12. Analyze the cumulative revenue generated over time.
Select ord.date, sum(p.price *od.quantity) as daily_revenue ,
SUM(SUM(p.price *od.quantity)) OVER (ORDER BY ord.date) AS cumulative_revenue
from pizzas p
join order_details od on p.pizza_id = od.pizza_id 
join orders ord on od.order_id =ord.order_id 
group by ord.date
order by ord.date ;

-- 13. Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select name, category , most_revenu from(
select pt.name, pt.category, sum(p.price * od.quantity ) as most_revenu , rank() over(
partition by pt.category
order by sum(p.price * od.quantity )  desc
) as rnk from pizzas p
join ORDER_DETAILS od on od.pizza_id = p.pizza_id
join PIZZA_TYPES pt on pt.pizza_type_id = p.pizza_type_id
group by pt.name, category
order by category
) t
where  rnk <= 3 ;

-- 14 Determine the top 5 days with the highest revenue
select o.date ,round(sum(p.price * od.quantity) ashghest_revenue from orders o
join order_details od on od.order_id = o.order_id
join pizzas p on p.pizza_id = od.pizza_id
group by date
order by highest_revenue desc
limit 5;

 
-- 15 Find the busiest day of the week based on number of orders
select dayname(date) as days,
count(order_id) as total_order from orders
group by days
order by total_order desc;

-- 16 Rank pizzas based on total quantity sold
select pt.name,sum(od.quantity) as quantity_sold , rank() over(
order by sum(od.quantity) desc
) as rnk from pizzas p 
join order_details od on od.pizza_id = p.pizza_id
join pizza_types pt on pt.pizza_type_id = p.pizza_type_id
group by pt.name;

-- 17 Calculate revenue growth compared to previous day
select o.date,(round(sum(p.price * od.quantity),2)) as revenue , lag (round(sum(p.price * od.quantity),2)) over(
order by o.date asc
) as pervious_day from orders o
join order_details od on od.order_id = o.order_id
join pizzas p on od.pizza_id = p.pizza_id
group by o.date;
