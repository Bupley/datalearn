create schema superstore_dw;
----------------------создание таблицы CUSTOMER----------------------
CREATE TABLE superstore_dw.customer_dim
(
cust_id serial NOT NULL,
customer_id   varchar(8) NOT NULL,
customer_name varchar(22) NOT NULL,
segment       varchar(11) NOT NULL,
 CONSTRAINT PK_customer PRIMARY KEY ( cust_id )
);

----------------------наполнение таблицы CUSTOMER----------------------
INSERT INTO superstore_dw.customer_dim
SELECT
	100+ROW_NUMBER () OVER() AS cust_id,
	*
FROM (SELECT DISTINCT(customer_id), customer_name, segment FROM	public.orders) AS a;

SELECT * FROM superstore_dw.customer_dim

----------------------создание таблицы MANAGER----------------------
CREATE TABLE superstore_dw.manager_dim
(
 region_id serial NOT NULL,
 region    varchar(7) NOT NULL,
 person    varchar(17) NOT NULL,
 CONSTRAINT PK_manager PRIMARY KEY ( region_id )
);

----------------------наполнение таблицы MANAGER----------------------
INSERT INTO superstore_dw.manager_dim
SELECT 	100+ROW_NUMBER() OVER() AS region_id, 	region,	person FROM public.people;

----------------------создание таблицы GEOGRAPHY----------------------
CREATE TABLE superstore_dw.geo_dim
(
 geo_id serial NOT NULL,
 country   varchar(13) NOT NULL,
 state   varchar(20) NOT NULL,
 city   varchar(17) NOT NULL,
 postal_code    varchar(20) NOT NULL,
 CONSTRAINT PK_geo PRIMARY KEY (geo_id)
);

----------------------наполнение таблицы GEOGRAPHY----------------------
INSERT INTO superstore_dw.geo_dim
SELECT 	100+ROW_NUMBER() OVER() AS geo_id, * FROM
(SELECT DISTINCT country, state, city, postal_code FROM public.orders) AS a;

UPDATE public.orders
SET postal_code ='05401' WHERE city='Burlington' AND postal_code IS NULL

ALTER TABLE public.orders 
ALTER COLUMN postal_code TYPE varchar(20);

SELECT * FROM superstore_dw.geo_dim

----------------------создание таблицы PRODUCT----------------------
CREATE TABLE superstore_dw.product_dim
(
prod_id serial NOT NULL,
 product_id   varchar(15) NOT NULL,
 product_name varchar(127) NOT NULL,
 category     varchar(15) NOT NULL,
 sub_category varchar(11) NOT NULL,
 CONSTRAINT PK_product PRIMARY KEY ( prod_id )
);

----------------------наполнение таблицы PRODUCT----------------------
INSERT INTO	superstore_dw.product_dim
SELECT	100+ROW_NUMBER () OVER () AS prod_id, * FROM 
(SELECT	DISTINCT (product_id),	product_name,	category,	subcategory	FROM public.orders) AS a;

SELECT * FROM superstore_dw.product_dim

----------------------создание таблицы CALENDAR----------------------

CREATE TABLE superstore_dw.calendar_dim
(
 "date"  date NOT NULL,
 day     int NOT NULL,
 dow     text NOT NULL,
 week    int NOT NULL,
 month   int NOT NULL,
 quarter int NOT NULL,
 year    int NOT NULL,
 CONSTRAINT PK_calendar PRIMARY KEY ( "date")
);

----------------------наполнение таблицы CALENDAR----------------------
INSERT INTO 
	superstore_dw.calendar_dim
SELECT
	"date"::date,
	EXTRACT('day' FROM date):: int AS "day",
	to_char(date, 'dy') AS week_day,
	EXTRACT('week' FROM date):: int AS week,
	EXTRACT('month' FROM date):: int AS "month",
	EXTRACT('quarter' FROM date):: int AS quarter,
	EXTRACT('year' FROM date):: int AS "year"
FROM
	generate_series(date('2000-01-01'), date('2030-01-01'), INTERVAL '1 day') AS t(date) -- генетрирует последовательнсоть значений с 2000 по 2030 год с шагом 1 день, псеводним таблицы - t, созданного столбца - date

SELECT * FROM superstore_dw.calendar_dim

----------------------создание таблицы ORDER----------------------

CREATE TABLE superstore_dw.order_dim
(
 ord_id serial NOT NULL,
 order_id    varchar(14) NOT NULL,
 order_date  date NOT NULL,
 ship_date   date NOT NULL,
 ship_mode   varchar(14) NOT NULL,
 CONSTRAINT PK_order PRIMARY KEY ( ord_id )
);

----------------------наполнение таблицы ORDER----------------------
INSERT INTO superstore_dw.order_dim
SELECT 100+ROW_NUMBER() OVER() AS ord_id, * FROM
(SELECT DISTINCT order_id, order_date, ship_date, ship_mode FROM public.orders) AS a;
	
SELECT * FROM superstore_dw.order_dim

----------------------создание таблицы SALE----------------------
DROP TABLE superstore_dw.sale_fact
CREATE TABLE superstore_dw.sale_fact
(
 row_id int NOT NULL,
 ord_id int NOT NULL,
 geo_id int NOT NULL,
 region_id int NOT NULL, 
 cust_id int NOT NULL,
 prod_id int NOT NULL,
 sales       numeric(8,3) NOT NULL,
 quantity    int NOT NULL,
 discount    numeric(3,2) NOT NULL,
 profit      numeric(9,4) NOT NULL,
 returned varchar(3),
 
 CONSTRAINT PK_row PRIMARY KEY ( row_id),
 CONSTRAINT FK_order FOREIGN KEY ( ord_id ) REFERENCES superstore_dw.order_dim (ord_id),
 CONSTRAINT FK_cust FOREIGN KEY ( cust_id ) REFERENCES superstore_dw.customer_dim ( cust_id ),
 CONSTRAINT FK_manager FOREIGN KEY ( region_id ) REFERENCES superstore_dw.manager_dim ( region_id ),
 CONSTRAINT FK_product FOREIGN KEY ( prod_id ) REFERENCES superstore_dw.product_dim ( prod_id ),
 CONSTRAINT FK_geo FOREIGN KEY ( geo_id ) REFERENCES superstore_dw.geo_dim ( geo_id )
)
;
CREATE INDEX FK_order ON superstore_dw.sale_fact (ord_id);
CREATE INDEX FK_cust ON superstore_dw.sale_fact (cust_id);
CREATE INDEX FK_manager ON superstore_dw.sale_fact (region_id);
CREATE INDEX FK_product ON superstore_dw.sale_fact (prod_id);
CREATE INDEX FK_geo ON superstore_dw.sale_fact (geo_id);

----------------------наполнение таблицы SALE----------------------
INSERT INTO 
	superstore_dw.sale_fact
WITH cleared_return AS (SELECT DISTINCT * FROM public."returns")
	SELECT
	o.row_id,
	ord.ord_id,
	g.geo_id,
	m.region_id,
	c.cust_id,
	p.prod_id,
	o.sales,
	o.quantity,
	o.discount,
	o.profit,
	CASE
		WHEN r.returned IS NULL THEN 'No'
		ELSE r.returned
	END AS returned
FROM
	public.orders o
JOIN superstore_dw.order_dim AS ord ON o.order_id=ord.order_id AND o.order_date=ord.order_date AND o.ship_date=ord.ship_date AND o.ship_mode=ord.ship_mode
JOIN superstore_dw.geo_dim AS g ON o.country=g.country AND o.state=g.state AND o.city=g.city AND o.postal_code = g.postal_code 
JOIN superstore_dw.manager_dim AS m ON o.region=m.region
JOIN superstore_dw.customer_dim	AS c ON o.customer_id=c.customer_id AND o.customer_name=c.customer_name
JOIN superstore_dw.product_dim AS p ON o.product_id=p.product_id AND o.product_name =p.product_name
LEFT JOIN cleared_return AS r ON o.order_id = r.orderid 


