Request 1 
SELECT distinct(market) FROM dim_customer
where customer='Atliq Exclusive' and  region ='APAC';

Request 2 
with cte1 as(
  SELECT
    count(distinct(product_code)) as unique_product_2021
  FROM
    fact_sales_monthly
  where
    fiscal_year = 2021
)
select
  cte1.unique_product_2021,
  count(distinct(product_code)) as unique_product_2020,
  round(
    (
     (cte1.unique_product_2021 -count(distinct(product_code)))*100/ count(distinct(product_code))
    ),
    2
  ) as precentage_Chg
FROM
  fact_sales_monthly
  cross join cte1
  
where
  fiscal_year = 2020

Request 3 
SELECT count(segment) as product_counts , segment  FROM dim_product 
group by segment order by product_counts desc;

Request 4
with cte3 as(
  SELECT
    s.*,
    p.segment
  FROM
    gdb023.fact_sales_monthly s
    join dim_product p on p.product_code = s.product_code
),
cte1 as(
  SELECT
    count(distinct(product_code)) as unique_product_2021,
    p.segment
  FROM
    fact_sales_monthly s
    join cte3 p using(product_code, date, customer_code, fiscal_year)
  where
    fiscal_year = 2021
  group by
    segment
),
cte2 as(
  SELECT
    count(distinct(product_code)) as unique_product_2020,
    p.segment
  FROM
    gdb023.fact_sales_monthly s
    join cte3 p using(product_code, date, customer_code, fiscal_year)
  where
    fiscal_year = 2020
  group by
    segment
)
select
  t1.segment,
  t1.unique_product_2021,
  t2.unique_product_2020,
  (t1.unique_product_2021 - t2.unique_product_2020) as difference
from
  cte1 t1
  join cte2 t2 using(segment)
order by
  difference desc

Request 5
SELECT
  s.product_code,
  p.product,
  s.manufacturing_cost as manufacturing_cost
FROM
  fact_manufacturing_cost s
  join dim_product p on p.product_code = s.product_code
where
  s.manufacturing_cost in (
    (
      select
        min(manufacturing_cost)
      from
        fact_manufacturing_cost
    ),
    (
      select
        max(manufacturing_cost)
      from
        fact_manufacturing_cost
    )
  )

Request 6
SELECT
  c.customer,
  pre.customer_code,
  avg(pre.pre_invoice_discount_pct) as Avg_pct
FROM
  fact_pre_invoice_deductions pre
  join dim_customer c using(customer_code)
where
  market = 'india'
  and pre.fiscal_year = 2021
group by
  pre.customer_code
order by
  Avg_pct desc
limit
  5
  
  Request 7
  SELECT
  year(date) as Year,
  month(date) as Month,
  c.customer,
  round(sum(s.sold_quantity * gp.gross_price) / 1000000, 2) as gross_price_amt
FROM
  fact_sales_monthly s
  join fact_gross_price gp on gp.product_code = s.product_code
  join dim_customer c on c.customer_code = s.customer_code
where
  c.customer = 'Atliq Exclusive'
group by
  Month,
  Year
 
 Request 8 
with cte1 as (
  SELECT
    date,
    sold_quantity,fiscal_year,
    month(date_add(date, interval 4 month)) as FY_month
  from
    fact_sales_monthly
)
select
  round(sum(sold_quantity) / 1000000, 2) as Sold_quantity_mln,
  concat("Q",(CEIL(fy_month / 3))) as quater
from
  cte1
  where fiscal_year=2020
group by
  quater
order by 
sold_quantity_mln desc;

Request 9
with cte1 as(
  SELECT
    c.channel,
    round(sum(sold_quantity * gp.gross_price) / 1000000, 2) as gross_sales_mln
  FROM
    gdb023.fact_sales_monthly s
    join fact_gross_price gp on gp.product_code = s.product_code
    join dim_customer c on c.customer_code = s.customer_code
  where
    s.fiscal_year = 2021
  group by
    channel
)
select
  *,
  round(
    gross_sales_mln * 100 / sum(gross_sales_mln) over(),
    2
  ) as percentage
from
  cte1
order by 
	percentage desc
   


