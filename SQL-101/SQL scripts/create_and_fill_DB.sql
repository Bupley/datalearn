----------------------создание таблицы CUSTOMER----------------------
CREATE TABLE customer
(
 customer_id   varchar(8) NOT NULL,
 customer_name varchar(22) NOT NULL,
 segment       varchar(11) NOT NULL,
 CONSTRAINT PK_5 PRIMARY KEY ( customer_id )
);

----------------------наполнение таблицы CUSTOMER----------------------
INSERT INTO customer
SELECT
	DISTINCT(customer_id), 
	customer_name,
	segment
FROM
	public.orders
	
---------------------------------чек--------------------------------
SELECT * FROM public.customer

----------------------создание таблицы MANAGER----------------------
CREATE TABLE manager
(
 region_id int NOT NULL,
 region    varchar(7) NOT NULL,
 person    varchar(17) NOT NULL,
 CONSTRAINT PK_7 PRIMARY KEY ( region_id )
);

----------------------наполнение таблицы MANAGER----------------------
INSERT INTO 
	manager
SELECT
	100+ROW_NUMBER() OVER() AS region_id,
	region,
	person 
FROM 
	public.people
	
---------------------------------чек--------------------------------
SELECT * FROM public.manager
	
----------------------создание таблицы ORDER----------------------
DROP TABLE "order" CASCADE
CREATE TABLE "order"
(
 order_id    varchar(14) NOT NULL,
 order_date  date NOT NULL,
 ship_date   date NOT NULL,
 ship_mode   varchar(14) NOT NULL,
 returned    boolean NOT NULL,
 country     varchar(13) NOT NULL,
 city        varchar(17) NOT NULL,
 "state"     varchar(20) NOT NULL,
 postal_code int NOT NULL,
 CONSTRAINT PK_3 PRIMARY KEY ( order_id )
);

------------добавление почтового кода для города Burlington, Vermont state---------
UPDATE
	public.orders
SET 
	postal_code = 05401 --код взял в исходном sql
WHERE
	postal_code IS  NULL
AND
	city='Burlington';

----------------------наполнение таблицы ORDER----------------------
INSERT INTO 
	public."order"
SELECT
	DISTINCT(o.order_id),
	o.order_date,
	o.ship_date,
	o.ship_mode,
	CASE
		WHEN r.returned LIKE 'Yes' THEN CAST(true AS boolean) -- создал в таблице тип boolean, поэтому пришлось конвертировать из varchar
		ELSE CAST(false AS boolean)
	END AS returned,
	o.country,
	o.city,
	o.state,
	o.postal_code --вот тут ругнулся, что значения нулевые, поэтому пришлось подставлять значения
FROM 
	public.orders o
LEFT JOIN
	public."returns" r
ON
	r.order_id=o.order_id;

---------------------------------чек--------------------------------
SELECT	* FROM	public."order"
	
----------------------создание таблицы PRODUCT----------------------
DROP TABLE public.product CASCADE
CREATE TABLE product
(
prod_id int NOT NULL,
 product_id   varchar(15) NOT NULL,
 product_name varchar(127) NOT NULL,
 category     varchar(15) NOT NULL,
 sub_category varchar(11) NOT NULL,
 CONSTRAINT PK_2 PRIMARY KEY ( prod_id )
);

----------------------наполнение таблицы PRODUCT----------------------
INSERT INTO
	public.product
SELECT 
	100+ROW_NUMBER () OVER () AS prod_id, --пришлось добавить, потому что product_id не уникален
	*
FROM
	(SELECT
		DISTINCT (product_id),
		product_name,
		category,
		subcategory

	FROM 
		public.orders);
	
---------------------------------чек--------------------------------
SELECT * FROM public.product

----------------------создание таблицы SALE----------------------
DROP TABLE sale CASCADE
CREATE TABLE sale
(
 row_id     int NOT NULL,
 sales       numeric(8,3) NOT NULL,
 quantity    int NOT NULL,
 discount    numeric(3,2) NOT NULL,
 profit      numeric(9,4) NOT NULL,
 prod_id  int NOT NULL,
 order_id    varchar(14) NOT NULL,
 customer_id varchar(8) NOT NULL,
 region_id   int NOT NULL,
 CONSTRAINT PK_1 PRIMARY KEY ( row_id),
 CONSTRAINT FK_1 FOREIGN KEY ( order_id ) REFERENCES "order" ( order_id ),
 CONSTRAINT FK_3 FOREIGN KEY ( customer_id ) REFERENCES customer ( customer_id ),
 CONSTRAINT FK_4 FOREIGN KEY ( region_id ) REFERENCES manager ( region_id ),
 CONSTRAINT FK_5 FOREIGN KEY ( prod_id ) REFERENCES product ( prod_id )
)
;
CREATE INDEX FK_1 ON sale
(
 order_id
);

CREATE INDEX FK_3 ON sale
(
 customer_id
);

CREATE INDEX FK_4 ON sale
(
 region_id
);

CREATE INDEX FK_5 ON sale
(
 prod_id
);

----------------------наполнение таблицы SALE----------------------
INSERT INTO 
	public.sale
SELECT
	o.row_id,
	o.sales,
	o.quantity,
	o.discount,
	o.profit,
	p.prod_id,
	o.order_id,
	o.customer_id,
	m.region_id
FROM
	public.orders o
JOIN
	public.product p ON o.product_id=p.product_id AND o.product_name=p.product_name AND o.category=p.category
JOIN
	public.manager m USING (region)
	
---------------------------------чек--------------------------------
SELECT * FROM public.sale
	