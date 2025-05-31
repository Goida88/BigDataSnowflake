BEGIN;

INSERT INTO dim_customer
(first_name, last_name, age, email, country, postal_code,
 pet_type, pet_name, pet_breed)
SELECT DISTINCT
  customer_first_name,
  customer_last_name,
  customer_age,
  customer_email,
  customer_country,
  customer_postal_code,
  customer_pet_type,
  customer_pet_name,
  customer_pet_breed
FROM public.mock_data
WHERE customer_email IS NOT NULL
ON CONFLICT (email) DO NOTHING;

INSERT INTO dim_seller
(first_name, last_name, email, country, postal_code)
SELECT DISTINCT
  seller_first_name,
  seller_last_name,
  seller_email,
  seller_country,
  seller_postal_code
FROM public.mock_data
WHERE seller_email IS NOT NULL
ON CONFLICT (email) DO NOTHING;

INSERT INTO dim_store
(store_name, location, city, state, country, phone, email)
SELECT DISTINCT
  store_name,
  store_location,
  store_city,
  store_state,
  store_country,
  store_phone,
  store_email
FROM public.mock_data
WHERE store_name IS NOT NULL
ON CONFLICT (store_name) DO NOTHING;

INSERT INTO dim_supplier
(name, contact, email, phone, address, city, country)
SELECT DISTINCT
  supplier_name,
  supplier_contact,
  supplier_email,
  supplier_phone,
  supplier_address,
  supplier_city,
  supplier_country
FROM public.mock_data
WHERE supplier_name IS NOT NULL
ON CONFLICT (name) DO NOTHING;

INSERT INTO dim_product
(product_name, category, pet_category, brand, description,
 color, size, material, weight, price,
 rating, reviews, release_date, expiry_date)
SELECT DISTINCT
  product_name,
  product_category,
  pet_category,
  product_brand,
  product_description,
  product_color,
  product_size,
  product_material,
  product_weight,
  product_price,
  product_rating,
  product_reviews,
  product_release_date,
  product_expiry_date
FROM public.mock_data
WHERE product_name IS NOT NULL
ON CONFLICT (product_name, brand) DO NOTHING;

INSERT INTO dim_date
(full_date, year, quarter, month, day, week, day_of_week, is_weekend)
SELECT DISTINCT
  sale_date,
  EXTRACT(YEAR    FROM sale_date)::SMALLINT,
  EXTRACT(QUARTER FROM sale_date)::SMALLINT,
  EXTRACT(MONTH   FROM sale_date)::SMALLINT,
  EXTRACT(DAY     FROM sale_date)::SMALLINT,
  EXTRACT(WEEK    FROM sale_date)::SMALLINT,
  EXTRACT(DOW     FROM sale_date)::SMALLINT,
  CASE WHEN EXTRACT(DOW FROM sale_date) IN (0,6) THEN TRUE ELSE FALSE END
FROM public.mock_data
WHERE sale_date IS NOT NULL
ON CONFLICT (full_date) DO NOTHING;

COMMIT;

INSERT INTO fact_sales
(date_id, customer_id, seller_id, product_id, store_id, supplier_id,
 quantity, total_price)
SELECT
  d.date_id,
  c.customer_id,
  s.seller_id,
  p.product_id,
  st.store_id,
  sup.supplier_id,
  md.sale_quantity,
  md.sale_total_price
FROM public.mock_data          md
JOIN dim_date        d   ON d.full_date     = md.sale_date
JOIN dim_customer    c   ON c.email         = md.customer_email
JOIN dim_seller      s   ON s.email         = md.seller_email
JOIN dim_product     p   ON p.product_name  = md.product_name
                           AND (p.brand = md.product_brand OR md.product_brand IS NULL)
JOIN dim_store       st  ON st.store_name   = md.store_name
JOIN dim_supplier    sup ON sup.name        = md.supplier_name;