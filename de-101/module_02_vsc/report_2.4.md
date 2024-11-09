# Домашнее задание к модулю 2
## Раздел 2.3
Используя исходный файл [Sample Suprestore](https://github.com/Bupley/datalearn/blob/main/de-101/module_02_vsc/Sample%20-%20Superstore.xls),
создано 3 таблицы в DBeaver, исполняя поочередно 3 запроса:
- [orders](https://github.com/Bupley/datalearn/blob/main/de-101/module_02_vsc/SQL%20requests/orders_sql.sql) 
- [people](https://github.com/Bupley/datalearn/blob/main/de-101/module_02_vsc/SQL%20requests/people_sql.sql)
- [returns](https://github.com/Bupley/datalearn/blob/main/de-101/module_02_vsc/SQL%20requests/returns_sql.sql)  

Сформированы команды на PostgreSQL для отображения следующих метрик:

* Total Sales - сумма дохода
```
select 
    sum(sales)
from 
    public.orders
```
Ответ: 2297200.8603

* Total Profit - сумма прибыли
```
select 
    sum(profit)
from 
    public.orders
```
Ответ: 286397.0216999999887055

* Profit Ratio - отношение прибыли к доходу
```
select 
	(sum(profit)/sum(sales)) as profit_ratio
from 
	public.orders
```
Ответ: 0.12467217240315604661

* Profit per Order - выручка за каждый заказ
```
select 
	order_id, 
	sum(profit)
from 
	public.orders
group by 
	order_id
```
Ответ: [Profit per Order](https://github.com/Bupley/datalearn/blob/main/de-101/module_02_vsc/CSV%20results/profit_per_order_csv.csv)

* Sales per Customer - продажи на одного клиента
```
select 
	customer_id, 
	sum(sales) AS "sum"
from 
	public.orders
group by 
	customer_id
order by 
    "sum" asc
```
Ответ: [Sales per Customer](https://github.com/Bupley/datalearn/blob/main/de-101/module_02_vsc/CSV%20results/Sales_per_customer_csv.csv)

* Avg. Discount - средняя скидка
```
select 
	avg(discount)
from 
	public.orders
 ```
Ответ: 0.15620272163297978787 

* Monthly Sales by Segment - средний доход по сегментам и по месцам
```
select 
	segment,
	extract (month from order_date) as month_num,
	sum(sales) as tot_sales
from 
	public.orders
group by 
	segment,
	month_num
order by 
	month_num
```
Ответ: [Monthly_sales_by_segment](https://github.com/Bupley/datalearn/blob/main/de-101/module_02_vsc/CSV%20results/Monthly_sales_by_segment_csv.csv)

* Monthly Sales by Product Category - средний доход по категориям и по месяцам
```
select 
	category,
	extract (month from order_date) as month_num,
	sum(sales) as tot_sales
from 
	public.orders
group by 
	category, 
	month_num
order by 
	month_num
```
Ответ: [Monthly_sales_by_product_category](https://github.com/Bupley/datalearn/blob/main/de-101/module_02_vsc/CSV%20results/Monthly_sales_by_product_category_csv.csv)

* Sales by Product Category over time - средний доход по категориям за все время
```
select 
	category,
	sum(sales) as tot_sales
from 
public.orders
group by 
	category
```
Ответ:  
Category |tot_sales
:-:|:-:
Furniture|	741999.7953
Office Supplies|	719047.0320
Technology|	836154.0330

* Sales and Profit by Customer - суммарный доход и выручка по клиентам
```
select 
	customer_name,
	sum (sales) as tot_sales,
	sum (profit) as tot_profit
from 
	public.orders
group by 
	customer_name
```
Ответ: 
[Sales_and_profit_by_customer](https://github.com/Bupley/datalearn/blob/main/de-101/module_02_vsc/CSV%20results/Sales_and_profit_by_customer_csv.csv)

* Customer Ranking - ранжирование клиентов по выручке
```
select 
	customer_name,
	sum (profit) as tot_profit
from 
	public.orders
group by 
	customer_name
order by 
	tot_profit desc
```
Ответ: [Customer_ranking](https://github.com/Bupley/datalearn/blob/main/de-101/module_02_vsc/CSV%20results/Customer_ranking_csv.csv)

* Sales per region - продажи по регионам за все время
```
select
	sum (sales) as tot_sales,
	region
from 
public.orders
group by region
```
Ответ:  
tot_sales|region
:-:|:-:
391721.9050|	South
725457.8245|	West
678781.2400|	East
501239.8908|	Central

## Раздел 2.4
В [sqlDBM](https://sqldbm.com/Home/) построена физическая модель данных:

![here we go](https://github.com/Bupley/datalearn/blob/main/de-101/module_02_vsc/PICS/superstore_ERD.PNG)  
Логическую пришлось скипнуть, потому что в бесплатной версии она не отображается. Да и так понятно вроде все.  
DDL-запрос для создания и DML-запрос для наполнения таблиц исполнен в DBeaver. [Вот он, полюбуйтесь](https://github.com/Bupley/datalearn/blob/main/de-101/module_02_vsc/SQL%20requests/2.4_create_and_fill_DB.sql).  


