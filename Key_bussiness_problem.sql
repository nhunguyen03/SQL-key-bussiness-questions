''' 
QUERY 1
Calculate total visit, pageview, transaction for Jan, Feb and March 2017 (order by month)
'''
SELECT FORMAT_DATE('%Y%m',PARSE_DATE('%Y%m%d',date)) AS month
  , SUM(totals.visits) AS visits
  , SUM(totals.pageviews) AS pageviews
  , SUM(totals.transactions) AS transactions
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
WHERE _table_suffix between '0101' and '0331'
GROUP BY 1
ORDER BY 1 ASC;
















''' 
QUERY 2
Bounce rate per traffic source in July 2017 (Bounce_rate = num_bounce/total_visit)
'''
SELECT  trafficSource.source
  , SUM(totals.visits) AS total_visits
  , SUM(totals.bounces) AS total_no_of_bounces
  , ROUND(SUM(totals.bounces)/SUM(totals.visits)*100,3) AS bounce_rate
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
WHERE _table_suffix BETWEEN '01' AND '31' 
    --If get all days in July, we do not need this condition. But I add condition to easily reuse SQL code
GROUP BY 1
ORDER BY 2 DESC;
















''' 
QUERY 3
Revenue by traffic source by week, by month in June 2017
'''
-- Create subset with time_type = 'month'
SELECT 'Month' AS time_type 
  , FORMAT_DATE('%Y%m',PARSE_DATE('%Y%m%d',date)) AS time
  , trafficSource.source AS source
  , ROUND(SUM(product.productRevenue)/1000000,4) AS revenue

FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201706*` 
  , UNNEST(hits) AS hits
  , UNNEST(hits.product) AS product
WHERE product.productRevenue IS NOT NULL
GROUP BY 1,2,3


  UNION ALL


-- Create subset with time_type = 'week'
SELECT 'Week' AS time_type 
  , FORMAT_DATE("%Y%m", parse_date("%Y%m%d", date)) AS week,
  , trafficSource.source AS source
  , ROUND(SUM(product.productRevenue)/1000000,4) AS revenue
  
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201706*` 
  , UNNEST(hits) AS hits
  , UNNEST(hits.product) AS product
WHERE product.productRevenue IS NOT NULL
GROUP BY 1,2,3
ORDER BY source, time;
















''' 
QUERY 4
Average number of pageviews by purchaser type (purchasers vs non-purchasers) in June, July 2017
'''
WITH 
purchaser_data as(
  SELECT
      FORMAT_DATE("%Y%m",PARSE_DATE("%Y%m%d",date)) AS month,
      (SUM(totals.pageviews)/COUNT(DISTINCT fullvisitorid)) AS avg_pageviews_purchase,
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
    ,UNNEST(hits) AS hits
    ,UNNEST(product) AS product
  WHERE _table_suffix BETWEEN '0601' AND '0731'
  AND totals.transactions>=1
  AND product.productRevenue is not null
  GROUP BY month
),

non_purchaser_data AS(
  SELECT
      FORMAT_DATE("%Y%m",PARSE_DATE("%Y%m%d",date)) AS month,
      SUM(totals.pageviews)/COUNT(DISTINCT fullvisitorid) AS avg_pageviews_non_purchase,
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
      ,UNNEST(hits) hits
      ,UNNES(product) product
  WHERE _table_suffix BETWEEN '0601' AND '0731'
  AND totals.transactions is null
  AND product.productRevenue is null
  GROUP BY month
)

SELECT
    pd.*,
    avg_pageviews_non_purchase
FROM purchaser_data pd
FULL JOIN non_purchaser_data USING(month)
ORDER BY pd.month;
















''' 
QUERY 5
Average number of transactions per user that made a purchase in July 2017
'''
SELECT
    FORMAT_DATE("%Y%m",PARSE_DATE("%Y%m%d",date)) AS month,
    SUM(totals.transactions)/COUNT(distinct fullvisitorid) AS Avg_total_transactions_per_user
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
    , UNNEST(hits) hits
    , UNNEST(product) product
WHERE totals.transactions>=1
AND product.productRevenue is not null
GROUP BY month;
















'''
QUERY 6
Average amount of money spent per session. Only include purchaser data in July 2017
'''

SELECT
    FORMAT_DATE("%Y%m",PARSE_DATE("%Y%m%d",date)) AS month,
    ((SUM(product.productRevenue)/SUM(totals.visits))/POWER(10,6)) AS avg_revenue_by_user_per_visit
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
  , UNNEST(hits) hits
  , UNNEST(product) product
WHERE product.productRevenue is not null
AND totals.transactions>=1
GROUP BY month;
















'''
QUERY 7
Other products purchased by customers who purchased product [YouTube Mens Vintage Henley] in July 2017. 
Output should show product name and the quantity was ordered.
'''
SELECT
    product.v2productname AS other_purchased_product,
    sum(product.productQuantity) AS quantity
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
    , UNNEST(hits) AS hits
    , UNNEST(hits.product) AS product
WHERE fullvisitorid IN (SELECT DISTINCT fullvisitorid
                        FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
                        , UNNEST(hits) AS hits
                        , UNNEST(hits.product) AS product
                        WHERE product.v2productname = "YouTube Men's Vintage Henley"
                        AND product.productRevenue is not null)
AND product.v2productname != "YouTube Men's Vintage Henley"
AND product.productRevenue is not null
GROUP BY other_purchased_product
ORDER BY quantity DESC;

--CTE:
--ở bảng buyer_list này, mình chỉ muốn tìm ra danh sách nhưng ng mua, thì nó người ngta sẽ mua nhiều lần chẳng hặn
--khi mình select distinct fullVisitorId, nó sẽ 3 người, nhưng nếu mình select fullVisitorId
--nó ra 6 dòng, tường ứng với 6 record trong bảng, rồi nó mang 6 dòng này, đi mapping tiếp với câu dưới, nên nó bị dup lên

WITH buyer_list AS(
    SELECT
        distinct fullVisitorId
    FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
    , UNNEST(hits) AS hits
    , UNNEST(hits.product) as product
    WHERE product.v2ProductName = "YouTube Men's Vintage Henley"
    AND totals.transactions>=1
    AND product.productRevenue is not null
)

SELECT
  product.v2ProductName AS other_purchased_products,
  SUM(product.productQuantity) AS quantity
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
, UNNEST(hits) AS hits
, UNNEST(hits.product) as product
JOIN buyer_list using(fullVisitorId)
WHERE product.v2ProductName != "YouTube Men's Vintage Henley"
 and product.productRevenue is not null
GROUP BY other_purchased_products
ORDER BY quantity DESC;
















-- QUERY 8: Calculate cohort map from product view to addtocart to purchase in Jan, Feb and March 2017. For example, 100% product view then 40% add_to_cart and 10% purchase.
-- Add_to_cart_rate = number product add to cart/number product view. 
-- Purchase_rate = number product purchase/number product view. 
-- The output should be calculated in product level.
WITH
product_view AS(
  SELECT
    FORMAT_DATE("%Y%m", PARSE_DATE("%Y%m%d", date)) AS month,
    COUNT(product.productSKU) AS num_product_view
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
  , UNNEST(hits) AS hits
  , UNNEST(hits.product) AS product
  WHERE _TABLE_SUFFIX BETWEEN '20170101' AND '20170331'
  AND hits.eCommerceAction.action_type = '2'
  GROUP BY 1
),

add_to_cart AS(
  SELECT
    FORMAT_DATE("%Y%m", PARSE_DATE("%Y%m%d", date)) AS month,
    COUNT(product.productSKU) AS num_addtocart
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
  , UNNEST(hits) AS hits
  , UNNEST(hits.product) AS product
  WHERE _TABLE_SUFFIX BETWEEN '20170101' AND '20170331'
  AND hits.eCommerceAction.action_type = '3'
  GROUP BY 1
),

purchase AS(
  SELECT
    FORMAT_DATE("%Y%m", PARSE_DATE("%Y%m%d", date)) AS month,
    COUNT(product.productSKU) AS num_purchase
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
  , UNNEST(hits) AS hits
  , UNNEST(hits.product) AS product
  WHERE _TABLE_SUFFIX BETWEEN '20170101' AND '20170331'
  AND hits.eCommerceAction.action_type = '6'
  AND product.productRevenue is not null   --phải thêm điều kiện này để đảm bảo có revenue
  GROUP BY 1
)

SELECT
    pv.*
    , num_addtocart
    , num_purchase
    , ROUND(num_product_view*100/num_product_view,2) AS add_to_cart_rate
    , ROUND(num_addtocart*100/num_product_view,2) AS add_to_cart_rate
    , ROUND(num_purchase*100/num_product_view,2) AS purchase_rate
FROM product_view pv
LEFT JOIN add_to_cart a on pv.month = a.month
LEFT JOIN purchase p on pv.month = p.month
ORDER BY pv.month;
