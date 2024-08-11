--Total Sales
select sum(sales)
from public.orders_new

--Total Profit
select sum(profit)
from public.orders_new

--Profit Ratio
select (sum(profit)/sum(sales)) as profit_ratio
from public.orders_new

--Profit per Order
select order_id, sum(profit)
from public.orders_new
group by order_id

--Sales per Customer
select customer_id, sum(sales)
from public.orders_new
group by customer_id
order by sum asc

--Avg. Discount
select avg(discount)
from public.orders_new

--Monthly Sales by Segment ( табличка и график)
select 
	segment,
	extract (month from order_date) as month_num,
	sum(sales) as tot_sales
from public.orders_new
group by segment, month_num
order by month_num

--Monthly Sales by Product Category (табличка и график)
select 
	category,
	extract (month from order_date) as month_num,
	sum(sales) as tot_sales,
from public.orders_new
group by category, month_num
order by month_num

--Sales by Product Category over time (Продажи по категориям)
select 
	category,
	sum(sales) as tot_sales
from public.orders_new
group by category

--Sales and Profit by Customer
select 
	customer_name,
	sum (sales) as tot_sales,
	sum (profit) as tot_profit
from public.orders_new
group by customer_name

--Customer Ranking
select 
	customer_name,
	sum (profit) as tot_profit
from public.orders_new
group by customer_name
order by tot_profit desc

--Sales per region
select
	sum (sales) as tot_sales,
	region
from public.orders_new
group by region


