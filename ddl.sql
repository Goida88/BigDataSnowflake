CREATE SCHEMA IF NOT EXISTS analytics;
SET search_path TO analytics, public;

CREATE TABLE dim_customer (
  customer_id      BIGSERIAL PRIMARY KEY,
  first_name       TEXT        NOT NULL,
  last_name        TEXT        NOT NULL,
  age              INT,
  email            TEXT        NOT NULL,
  country          TEXT,
  postal_code      TEXT,
  pet_type         TEXT,
  pet_name         TEXT,
  pet_breed        TEXT,
  CONSTRAINT uq_dim_customer_email UNIQUE (email)
);

CREATE TABLE dim_seller (
  seller_id        BIGSERIAL PRIMARY KEY,
  first_name       TEXT        NOT NULL,
  last_name        TEXT        NOT NULL,
  email            TEXT        NOT NULL,
  country          TEXT,
  postal_code      TEXT,
  CONSTRAINT uq_dim_seller_email UNIQUE (email)
);

CREATE TABLE dim_store (
  store_id         BIGSERIAL PRIMARY KEY,
  store_name       TEXT        NOT NULL,
  location         TEXT,
  city             TEXT,
  state            TEXT,
  country          TEXT,
  phone            TEXT,
  email            TEXT,
  CONSTRAINT uq_dim_store_name UNIQUE (store_name)
);

CREATE TABLE dim_supplier (
  supplier_id      BIGSERIAL PRIMARY KEY,
  name             TEXT        NOT NULL,
  contact          TEXT,
  email            TEXT,
  phone            TEXT,
  address          TEXT,
  city             TEXT,
  country          TEXT,
  CONSTRAINT uq_dim_supplier_name UNIQUE (name)
);

CREATE TABLE dim_product (
  product_id       BIGSERIAL PRIMARY KEY,
  product_name     TEXT        NOT NULL,
  category         TEXT,
  pet_category     TEXT,
  brand            TEXT,
  description      TEXT,
  color            TEXT,
  size             TEXT,
  material         TEXT,
  weight           NUMERIC(10,2),
  price            NUMERIC(10,2),
  rating           NUMERIC(3,2),
  reviews          INT,
  release_date     DATE,
  expiry_date      DATE,
  CONSTRAINT uq_dim_product_name_brand UNIQUE (product_name, brand)
);

CREATE TABLE dim_date (
  date_id          BIGSERIAL PRIMARY KEY,
  full_date        DATE        NOT NULL UNIQUE,
  year             SMALLINT    NOT NULL,
  quarter          SMALLINT    NOT NULL,
  month            SMALLINT    NOT NULL,
  day              SMALLINT    NOT NULL,
  week             SMALLINT    NOT NULL,
  day_of_week      SMALLINT    NOT NULL,        
  is_weekend       BOOLEAN     NOT NULL
);

CREATE TABLE fact_sales (
  sale_id          BIGSERIAL PRIMARY KEY,
  date_id          BIGINT      NOT NULL REFERENCES dim_date(date_id),
  customer_id      BIGINT      NOT NULL REFERENCES dim_customer(customer_id),
  seller_id        BIGINT      NOT NULL REFERENCES dim_seller(seller_id),
  product_id       BIGINT      NOT NULL REFERENCES dim_product(product_id),
  store_id         BIGINT      NOT NULL REFERENCES dim_store(store_id),
  supplier_id      BIGINT      NOT NULL REFERENCES dim_supplier(supplier_id),
  quantity         INT         NOT NULL,
  total_price      NUMERIC(10,2) NOT NULL
);

CREATE INDEX idx_fact_sales_date     ON fact_sales (date_id);
CREATE INDEX idx_fact_sales_customer ON fact_sales (customer_id);
CREATE INDEX idx_fact_sales_product  ON fact_sales (product_id);
