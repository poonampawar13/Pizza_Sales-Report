create database pizza_sales_project;
use pizza_sales_project;

# 1. Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id) AS 'Total orders'
FROM
    orders;

# 2. Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(od.quantity * p.price), 2) AS 'Total Revenue'
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id;

# 3. Identify the highest-priced pizza.
SELECT 
    pt.name, p.price
FROM
    pizzas p
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;

# 4. Identify the most common pizza size ordered.
SELECT 
	p.size
FROM
    pizzas p
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY p.size
ORDER BY COUNT(size) DESC
LIMIT 1;


# 5. List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pt.name, SUM(od.quantity) AS 'quantity'
FROM
    pizzas p
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
        JOIN
    pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.name
ORDER BY SUM(od.quantity) DESC
LIMIT 5;

# 6. Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
	pt.category, COUNT(od.quantity) as 'Total quantity'
FROM
    pizzas p
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
        JOIN
    pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.category;

# 7. Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY HOUR(order_time);

# 8. Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(category) as count
FROM
    pizza_types
GROUP BY category;

# 9. Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(quantity), 2) AS 'avg quantity'
FROM
    (SELECT 
        order_date AS date, SUM(od.quantity) AS quantity
    FROM
        orders o
    JOIN order_details od ON o.order_id = od.order_id
    JOIN pizzas p ON p.pizza_id = od.pizza_id
    GROUP BY order_date) AS order_quantity;

# 10. Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pt.name, ROUND(SUM(od.quantity * p.price), 2) AS revenue
FROM
    orders o
        JOIN
    order_details od ON o.order_id = od.order_id
        JOIN
    pizzas p ON p.pizza_id = od.pizza_id
        JOIN
    pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.name
ORDER BY revenue DESC
LIMIT 3;

# 11. Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pt.category,
    ROUND((SUM(p.price * ot.quantity) / (SELECT 
                    SUM(p.price * ot.quantity)
                FROM
                    order_details ot
                        JOIN
                    pizzas p ON ot.pizza_id = p.pizza_id)) * 100,
            2) AS revenue
FROM
    order_details ot
        JOIN
    pizzas p ON ot.pizza_id = p.pizza_id
        JOIN
    pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.category
ORDER BY revenue DESC;

# 12. Analyze the cumulative revenue generated over time.
SELECT order_date, sum(revenue) 
     OVER (ORDER BY order_date) AS "cumulative revenue"
FROM
(SELECT 
    o.order_date, SUM(p.price * ot.quantity) AS 'revenue'
FROM
    order_details ot
        JOIN
    pizzas p ON ot.pizza_id = p.pizza_id
        JOIN
    orders o ON o.order_id = ot.order_id
GROUP BY (o.order_date)
ORDER BY order_date) as sale;

# 13. Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT 
    category, name, revenue 
FROM 
    (SELECT 
         category, name, revenue, 
         RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rn
     FROM
        (SELECT 
            pt.category, pt.name, SUM(od.quantity * p.price) AS revenue
         FROM
            pizza_types pt
         JOIN
            pizzas p ON pt.pizza_type_id = p.pizza_type_id
         JOIN
            order_details od ON od.pizza_id = p.pizza_id
         GROUP BY pt.category, pt.name
        ) AS a
    ) AS b
WHERE rn <= 3;
