----------------------создание таблиц----------------------

CREATE TABLE IF NOT EXISTS superstore.customer_dim
(
    "ID" integer NOT NULL,
    first_name character varying(22) NOT NULL,
    last_name character varying(22) NOT NULL,
    segment_id integer NOT NULL,
    PRIMARY KEY ("ID")
);

CREATE TABLE IF NOT EXISTS superstore.region_dim
(
    "ID" integer NOT NULL,
    region character varying(7) NOT NULL,
    manager_id integer NOT NULL,
    PRIMARY KEY ("ID")
);

CREATE TABLE IF NOT EXISTS superstore.sale_fact
(
    "ID" integer NOT NULL,
    sales numeric(8, 3) NOT NULL,
    quantity integer NOT NULL,
    discount numeric(3, 2) NOT NULL,
    profit numeric(9, 4) NOT NULL,
    returned character varying(3) NOT NULL DEFAULT 'No',
    customer_id integer NOT NULL,
    order_id integer NOT NULL,
    product_id integer NOT NULL,
    PRIMARY KEY ("ID")
);

CREATE TABLE IF NOT EXISTS superstore.product_dim
(
    "ID" integer NOT NULL,
    product_name character varying(127) NOT NULL,
    "category_ID" integer NOT NULL,
    "sub_category_ID" integer NOT NULL,
    PRIMARY KEY ("ID")
);

CREATE TABLE IF NOT EXISTS superstore.order_dim
(
    "ID" integer NOT NULL,
    order_date date NOT NULL,
    ship_date date NOT NULL,
    ship_mode_id integer NOT NULL,
    geography_id integer NOT NULL,
    CONSTRAINT "order_PK" PRIMARY KEY ("ID")
);

CREATE TABLE IF NOT EXISTS superstore.city_dim
(
    "ID" integer NOT NULL,
    city character varying(17) NOT NULL,
    postal_code integer NOT NULL,
    state_id integer NOT NULL,
    PRIMARY KEY ("ID")
);

CREATE TABLE IF NOT EXISTS superstore.segment_dim
(
    "ID" integer NOT NULL,
    segment character varying(11) NOT NULL,
    PRIMARY KEY ("ID")
);

CREATE TABLE IF NOT EXISTS superstore.manager_dim
(
    "ID" integer NOT NULL,
    manager character varying(17) NOT NULL,
    PRIMARY KEY ("ID")
);

CREATE TABLE IF NOT EXISTS superstore.ship_mode_dim
(
    "ID" integer NOT NULL,
    ship_mode character varying(20) NOT NULL,
    PRIMARY KEY ("ID")
);

CREATE TABLE IF NOT EXISTS superstore.sub_category_dim
(
    "ID" integer NOT NULL,
    sub_category character varying(11) NOT NULL,
    PRIMARY KEY ("ID")
);

CREATE TABLE IF NOT EXISTS superstore.category_dim
(
    "ID" integer NOT NULL,
    category character varying(15) NOT NULL,
    PRIMARY KEY ("ID")
);

CREATE TABLE IF NOT EXISTS superstore.state_dim
(
    "ID" integer NOT NULL,
    state character varying(20) NOT NULL,
    region_id integer NOT NULL,
    PRIMARY KEY ("ID")
);

ALTER TABLE IF EXISTS superstore.customer_dim
    ADD CONSTRAINT "segment_FK" FOREIGN KEY (segment_id)
    REFERENCES superstore.segment_dim ("ID") MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS superstore.region_dim
    ADD CONSTRAINT "manager_FK" FOREIGN KEY (manager_id)
    REFERENCES superstore.manager_dim ("ID") MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS superstore.sale_fact
    ADD CONSTRAINT "customer_FK" FOREIGN KEY (customer_id)
    REFERENCES superstore.customer_dim ("ID") MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS superstore.sale_fact
    ADD CONSTRAINT "order_FK" FOREIGN KEY (order_id)
    REFERENCES superstore.order_dim ("ID") MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS superstore.sale_fact
    ADD CONSTRAINT "product_FK" FOREIGN KEY (product_id)
    REFERENCES superstore.product_dim ("ID") MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS superstore.product_dim
    ADD CONSTRAINT "sub_category_ID" FOREIGN KEY ("sub_category_ID")
    REFERENCES superstore.sub_category_dim ("ID") MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS superstore.product_dim
    ADD CONSTRAINT "category_ID" FOREIGN KEY ("category_ID")
    REFERENCES superstore.category_dim ("ID") MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS superstore.order_dim
    ADD CONSTRAINT "geography_FK" FOREIGN KEY (geography_id)
    REFERENCES superstore.city_dim ("ID") MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS superstore.order_dim
    ADD FOREIGN KEY (ship_mode_id)
    REFERENCES superstore.ship_mode_dim ("ID") MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS superstore.city_dim
    ADD CONSTRAINT "state_FK" FOREIGN KEY (state_id)
    REFERENCES superstore.state_dim ("ID") MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS superstore.state_dim
    ADD FOREIGN KEY (region_id)
    REFERENCES superstore.region_dim ("ID") MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

	
    
    	