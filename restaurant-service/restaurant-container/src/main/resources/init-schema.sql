DROP SCHEMA IF EXISTS restaurant CASCADE;

CREATE SCHEMA restaurant;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

DROP TABLE IF EXISTS restaurant.restaurants CASCADE;

CREATE TABLE restaurant.restaurants
(
    id uuid NOT NULL,
    name character varying COLLATE pg_catalog."default" NOT NULL,
    active boolean NOT NULL,
    CONSTRAINT restaurants_pkey PRIMARY KEY (id)
);

DROP TYPE IF EXISTS approval_status;

CREATE TYPE approval_status AS ENUM ('APPROVED', 'REJECTED');

DROP TABLE IF EXISTS restaurant.order_approval CASCADE;

CREATE TABLE restaurant.order_approval
(
    id uuid NOT NULL,
    restaurant_id uuid NOT NULL,
    order_id uuid NOT NULL,
    status approval_status NOT NULL,
    CONSTRAINT order_approval_pkey PRIMARY KEY (id)
);

DROP TABLE IF EXISTS restaurant.products CASCADE;

CREATE TABLE restaurant.products
(
    id uuid NOT NULL,
    name character varying COLLATE pg_catalog."default" NOT NULL,
    price numeric(10,2) NOT NULL,
    available boolean NOT NULL,
    CONSTRAINT products_pkey PRIMARY KEY (id)
);

DROP TABLE IF EXISTS restaurant.restaurant_products CASCADE;

CREATE TABLE restaurant.restaurant_products
(
    id uuid NOT NULL,
    restaurant_id uuid NOT NULL,
    product_id uuid NOT NULL,
    CONSTRAINT restaurant_products_pkey PRIMARY KEY (id)
);

ALTER TABLE restaurant.restaurant_products
    ADD CONSTRAINT "FK_RESTAURANT_ID" FOREIGN KEY (restaurant_id)
    REFERENCES restaurant.restaurants (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE RESTRICT
    NOT VALID;

ALTER TABLE restaurant.restaurant_products
    ADD CONSTRAINT "FK_PRODUCT_ID" FOREIGN KEY (product_id)
    REFERENCES restaurant.products (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE RESTRICT
    NOT VALID;

DROP MATERIALIZED VIEW IF EXISTS restaurant.order_restaurant_m_view;

CREATE MATERIALIZED VIEW restaurant.order_restaurant_m_view
TABLESPACE pg_default
AS
 SELECT r.id AS restaurant_id,
    r.name AS restaurant_name,
    r.active AS restaurant_active,
    p.id AS product_id,
    p.name AS product_name,
    p.price AS product_price,
    p.available AS product_available
   FROM restaurant.restaurants r,
    restaurant.products p,
    restaurant.restaurant_products rp
  WHERE r.id = rp.restaurant_id AND p.id = rp.product_id
WITH DATA;

refresh materialized VIEW restaurant.order_restaurant_m_view;

DROP function IF EXISTS restaurant.refresh_order_restaurant_m_view;

CREATE OR replace function restaurant.refresh_order_restaurant_m_view()
returns trigger
AS '
BEGIN
    refresh materialized VIEW restaurant.order_restaurant_m_view;
    return null;
END;
'  LANGUAGE plpgsql;

DROP trigger IF EXISTS refresh_order_restaurant_m_view ON restaurant.restaurant_products;

CREATE trigger refresh_order_restaurant_m_view
after INSERT OR UPDATE OR DELETE OR truncate
ON restaurant.restaurant_products FOR each statement
EXECUTE PROCEDURE restaurant.refresh_order_restaurant_m_view();

-- Seed data: 2 restaurants, 18 products
INSERT INTO restaurant.restaurants (id, name, active) VALUES
('d215b5f8-0249-4dc5-89a3-51fd148cfb45', 'restaurant_1', true),
('d215b5f8-0249-4dc5-89a3-51fd148cfb46', 'restaurant_2', true);

INSERT INTO restaurant.products (id, name, price, available) VALUES
('d215b5f8-0249-4dc5-89a3-51fd148cfb47', '番茄炒蛋', 25.00, true),
('d215b5f8-0249-4dc5-89a3-51fd148cfb48', '红烧牛肉面', 50.00, true),
('d215b5f8-0249-4dc5-89a3-51fd148cfb49', '宫保鸡丁', 20.00, true),
('d215b5f8-0249-4dc5-89a3-51fd148cfb50', '鱼香肉丝', 40.00, true),
('d215b5f8-0249-4dc5-89a3-51fd148cfb60', '麻婆豆腐', 22.00, true),
('d215b5f8-0249-4dc5-89a3-51fd148cfb61', '蛋炒饭', 18.00, true),
('d215b5f8-0249-4dc5-89a3-51fd148cfb62', '糖醋里脊', 35.00, true),
('d215b5f8-0249-4dc5-89a3-51fd148cfb63', '清炒时蔬', 16.00, true),
('d215b5f8-0249-4dc5-89a3-51fd148cfb64', '酸菜鱼', 55.00, true),
('d215b5f8-0249-4dc5-89a3-51fd148cfb65', '水煮肉片', 38.00, true),
('d215b5f8-0249-4dc5-89a3-51fd148cfb80', '回锅肉', 32.00, true),
('d215b5f8-0249-4dc5-89a3-51fd148cfb81', '干煸四季豆', 20.00, true),
('d215b5f8-0249-4dc5-89a3-51fd148cfb82', '辣子鸡', 28.00, true),
('d215b5f8-0249-4dc5-89a3-51fd148cfb83', '凉拌黄瓜', 12.00, true),
('d215b5f8-0249-4dc5-89a3-51fd148cfb84', '口水鸡', 30.00, true),
('d215b5f8-0249-4dc5-89a3-51fd148cfb85', '地三鲜', 22.00, true),
('d215b5f8-0249-4dc5-89a3-51fd148cfb86', '小炒黄牛肉', 45.00, true),
('d215b5f8-0249-4dc5-89a3-51fd148cfb87', '蒜蓉西兰花', 18.00, true);

INSERT INTO restaurant.restaurant_products (id, restaurant_id, product_id) VALUES
(gen_random_uuid(), 'd215b5f8-0249-4dc5-89a3-51fd148cfb45', 'd215b5f8-0249-4dc5-89a3-51fd148cfb47'),
(gen_random_uuid(), 'd215b5f8-0249-4dc5-89a3-51fd148cfb45', 'd215b5f8-0249-4dc5-89a3-51fd148cfb48'),
(gen_random_uuid(), 'd215b5f8-0249-4dc5-89a3-51fd148cfb45', 'd215b5f8-0249-4dc5-89a3-51fd148cfb49'),
(gen_random_uuid(), 'd215b5f8-0249-4dc5-89a3-51fd148cfb45', 'd215b5f8-0249-4dc5-89a3-51fd148cfb50'),
(gen_random_uuid(), 'd215b5f8-0249-4dc5-89a3-51fd148cfb45', 'd215b5f8-0249-4dc5-89a3-51fd148cfb60'),
(gen_random_uuid(), 'd215b5f8-0249-4dc5-89a3-51fd148cfb45', 'd215b5f8-0249-4dc5-89a3-51fd148cfb61'),
(gen_random_uuid(), 'd215b5f8-0249-4dc5-89a3-51fd148cfb45', 'd215b5f8-0249-4dc5-89a3-51fd148cfb62'),
(gen_random_uuid(), 'd215b5f8-0249-4dc5-89a3-51fd148cfb45', 'd215b5f8-0249-4dc5-89a3-51fd148cfb63'),
(gen_random_uuid(), 'd215b5f8-0249-4dc5-89a3-51fd148cfb45', 'd215b5f8-0249-4dc5-89a3-51fd148cfb64'),
(gen_random_uuid(), 'd215b5f8-0249-4dc5-89a3-51fd148cfb46', 'd215b5f8-0249-4dc5-89a3-51fd148cfb65'),
(gen_random_uuid(), 'd215b5f8-0249-4dc5-89a3-51fd148cfb46', 'd215b5f8-0249-4dc5-89a3-51fd148cfb80'),
(gen_random_uuid(), 'd215b5f8-0249-4dc5-89a3-51fd148cfb46', 'd215b5f8-0249-4dc5-89a3-51fd148cfb81'),
(gen_random_uuid(), 'd215b5f8-0249-4dc5-89a3-51fd148cfb46', 'd215b5f8-0249-4dc5-89a3-51fd148cfb82'),
(gen_random_uuid(), 'd215b5f8-0249-4dc5-89a3-51fd148cfb46', 'd215b5f8-0249-4dc5-89a3-51fd148cfb83'),
(gen_random_uuid(), 'd215b5f8-0249-4dc5-89a3-51fd148cfb46', 'd215b5f8-0249-4dc5-89a3-51fd148cfb84'),
(gen_random_uuid(), 'd215b5f8-0249-4dc5-89a3-51fd148cfb46', 'd215b5f8-0249-4dc5-89a3-51fd148cfb85'),
(gen_random_uuid(), 'd215b5f8-0249-4dc5-89a3-51fd148cfb46', 'd215b5f8-0249-4dc5-89a3-51fd148cfb86'),
(gen_random_uuid(), 'd215b5f8-0249-4dc5-89a3-51fd148cfb46', 'd215b5f8-0249-4dc5-89a3-51fd148cfb87');

REFRESH MATERIALIZED VIEW restaurant.order_restaurant_m_view;