--------------наполнение таблиц без FK ------------
--segment
INSERT INTO superstore.segment_dim
SELECT 100+row_number() OVER () AS ID, * FROM (SELECT DISTINCT(segment) FROM public.orders) AS a;
SELECT * FROM superstore.segment_dim

--sub_category
INSERT INTO superstore.sub_category_dim
SELECT 100+row_number() OVER () AS ID, * FROM (SELECT DISTINCT(subcategory) FROM public.orders) AS a;
SELECT * FROM superstore.sub_category_dim

--category
INSERT INTO superstore.category_dim
SELECT 100+row_number() OVER () AS ID, * FROM (SELECT DISTINCT(category) FROM public.orders) AS a;
SELECT * FROM superstore.category_dim

--ship_mode
INSERT INTO superstore.ship_mode_dim
SELECT 100+row_number() OVER () AS ID, * FROM (SELECT DISTINCT(ship_mode) FROM public.orders) AS a;
SELECT * FROM superstore.ship_mode_dim

--manager
INSERT INTO superstore.manager_dim
SELECT 100+row_number() OVER () AS ID, * FROM (SELECT DISTINCT(person) FROM public.people) AS a;
SELECT * FROM superstore.manager_dim

--------------наполнение таблиц с FK, связанные с уже наполненными таблицами------------

--superstore.customer_dim
INSERT INTO superstore.customer_dim
SELECT 100+row_number() OVER () AS ID, s."ID" AS segment_id, customer_name, customer_id
FROM (SELECT DISTINCT customer_id, customer_name, segment FROM public.orders) AS o
JOIN superstore.segment_dim s ON s.segment = o.segment;
SELECT * FROM superstore.customer_dim

--superstore.product_dim
INSERT INTO superstore.product_dim
SELECT 100+row_number() OVER () AS ID, o.product_name, c."ID" AS category_id, sc."ID" AS subcategory_id 
FROM (SELECT DISTINCT product_name, category, subcategory FROM public.orders) AS o
JOIN superstore.sub_category_dim sc ON sc.sub_category = o.subcategory
JOIN superstore.category_dim c ON c.category = o.category;
SELECT * FROM superstore.product_dim

--superstore.region_dim
INSERT INTO superstore.region_dim
SELECT 100+row_number() OVER () AS ID, p.region, m."ID" AS manager_id
FROM (SELECT DISTINCT region, person FROM public.people) AS p
JOIN superstore.manager_dim AS m ON p.person=m.manager 
SELECT * FROM superstore.region_dim

--superstore.state_dim
INSERT INTO superstore.state_dim
SELECT 100+row_number() OVER () AS ID, o.state, r."ID" AS region_id
FROM (SELECT DISTINCT state, region FROM public.orders) AS o
JOIN superstore.region_dim AS r USING (region)
SELECT * FROM superstore.state_dim

--superstore.city_dim
INSERT INTO superstore.city_dim
SELECT 100+row_number() OVER() AS ID, o.city, s."ID" AS state_id
FROM (SELECT DISTINCT city, state FROM public.orders) AS o
JOIN superstore.state_dim AS s USING (state);
SELECT * FROM superstore.city_dim
WHERE city='Huntsville'

--superstore.order_dim
INSERT INTO 
	superstore.order_dim
SELECT 
	100+row_number() OVER () AS ID,
	order_date,
	ship_date,
	s."ID" AS ship_mode_id,
	c."ID" AS geography_id,
	order_id,
	postal_code
FROM (SELECT DISTINCT order_date, ship_date, ship_mode, city, order_id, postal_code, state FROM public.orders) AS o
JOIN superstore.city_dim c ON c.city=o.city
JOIN superstore.state_dim st ON st.state=o.state AND st."ID" =c.state_id --толькотак исключается возможность задвоения заказов, когда город называется одинаково, а стат - разный
JOIN superstore.ship_mode_dim s USING (ship_mode);
SELECT * FROM superstore.order_dim

SELECT DISTINCT city, state FROM public.orders
WHERE postal_code IS NULL OR city IS NULL OR state IS NULL; -- у Burlington нет почтового кода
UPDATE public.orders
SET postal_code = '05401'
WHERE city = 'Burlington'; --добавил почтовый код в таблице orders

--superstore.sale_fact

INSERT INTO 
	superstore.sale_fact
SELECT
	100+row_number() OVER () AS ID,
	o.sales,
	o.quantity,
	o.discount,
	o.profit,
	CASE 
		WHEN r.returned IS NULL THEN 'No'
		ELSE r.returned
	END,
	cus."ID" AS customer_id,
	ord."ID" AS order_id,
	p."ID" AS product_id
FROM
	public.orders o
LEFT JOIN
	public."returns" r USING (order_id)
JOIN
	superstore.order_dim ord ON ord.order_id=o.order_id
JOIN
	superstore.city_dim c ON c.city =o.city AND c."ID" =ord.geography_id 
JOIN
	superstore.customer_dim cus ON cus.customer_name=o.customer_name
JOIN
	superstore.product_dim p ON p.product_name=o.product_name
JOIN
	superstore.sub_category_dim sc ON sc.sub_category=o.subcategory AND sc."ID" = p."sub_category_ID" 
JOIN
	superstore.category_dim cat ON cat.category=o.category AND cat."ID" = p."category_ID" 	

SELECT COUNT(*) FROM superstore.sale_fact

