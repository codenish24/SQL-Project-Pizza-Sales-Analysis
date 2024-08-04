-- Retrieve the total number of orders placed.
select count(order_id) as total_order from orders;

-- Calculate the total revenue generated from pizza sales.

select round(sum(pizzas.price * orders_details.quantity),2) as total_sales
from orders_details
join pizzas 
on orders_details.pizza_id = pizzas.pizza_id;

-- Identify the highest-priced pizza.
select pizza_types.name, pizzas.price
from pizza_types
join pizzas 
on pizzas.pizza_type_id = pizza_types.pizza_type_id
order by 2 desc
limit 1;

-- Identify the most common pizza size ordered.
select pizzas.size, count(orders_details.order_details_id)
from pizzas join orders_details
on pizzas.pizza_id = orders_details.pizza_id
group by pizzas.size
order by count(orders_details.order_details_id) desc
limit 1;

-- List the top 5 most ordered pizza types along with their quantities.
select pizza_types.name , sum(orders_details.quantity)
from pizza_types
join pizzas 
on pizzas.pizza_type_id = pizza_types.pizza_type_id
join orders_details 
on orders_details.pizza_id = pizzas.pizza_id
group by pizza_types.name 
order by sum(orders_details.quantity) desc
limit 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.
select pizza_types.category, sum(orders_details.quantity) as total
FROM orders_details
join pizzas
on orders_details.pizza_id = pizzas.pizza_id
join pizza_types 
on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.category;

-- Determine the distribution of orders by hour of the day.
select hour(order_time), count(order_id) from orders
group by hour(order_time);

-- Join relevant tables to find the category-wise distribution of pizzas.
select category, count(name) from pizza_types
group by category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
select round(avg(order_quantity),0) as avg_no_of_pizza_per_day from
(select orders.order_date, sum(orders_details.quantity) as order_quantity
from orders 
join orders_details
on orders.order_id = orders_details.order_id
group by orders.order_date) as order_quantity;

-- Determine the top 3 most ordered pizza types based on revenue.
select pizza_types.name, sum(pizzas.price * orders_details.quantity) as revenue
from pizza_types 
join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join orders_details on pizzas.pizza_id = orders_details.pizza_id
group by pizza_types.name
order by revenue desc
limit 3;

-- Calculate the percentage contribution of each pizza type to total revenue.

select pizza_types.category, round((sum(pizzas.price * orders_details.quantity) / (select round(sum(pizzas.price * orders_details.quantity),2) as total_sales
from orders_details
join pizzas 
on orders_details.pizza_id = pizzas.pizza_id))*100,2) as revenue
from pizza_types 
join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join orders_details on pizzas.pizza_id = orders_details.pizza_id
group by pizza_types.category
order by revenue desc;

-- Analyze the cumulative revenue generated over time.
select order_date,
sum(revenue) over(order by order_date) as cum_revenue
from
(select orders.order_date, sum(orders_details.quantity*pizzas.price) as revenue
from orders_details join pizzas
on orders_details.pizza_id = pizzas.pizza_id
join orders 
on orders.order_id = orders_details.order_id
group by orders.order_date) as sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select name, revenue from
(select category, name, revenue,
rank() over(partition by category order by revenue desc) as rn
from
(select pizza_types.category, pizza_types.name, sum(orders_details.quantity * pizzas.price) as revenue
from pizza_types join pizzas
on pizzas.pizza_type_id = pizza_types.pizza_type_id
join orders_details
on orders_details.pizza_id = pizzas.pizza_id
group by pizza_types.category, pizza_types.name) as a) as b
where rn <=3;





