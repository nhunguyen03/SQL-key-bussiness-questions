# [SQL] Explore Ecommerce Dataset
## I. Introduction
### 1. About dataset
This project contains an eCommerce dataset that I will explore using SQL on Google BigQuery. 
The dataset is based on the [Google Analytics Sample của Bigquery Public Dataset](https://support.google.com/analytics/answer/3437719?hl=en) and contains data from an eCommerce website.

This project only focuses on a few columns rather than all columns. The purpose of the project is to showcase SQL skills and address key business problems through the calculation of key metrics.

**NOTE**: Within each dataset, a table is imported for each day of export. Daily tables have the format "ga_sessions_YYYYMMDD".
### 2. Explain dataset
[View explanation of all columns here](https://support.google.com/analytics/answer/3437719?hl=en)
![image](https://github.com/user-attachments/assets/1dc93967-9448-4c0e-8535-6a3dd43809f3)

## II. Exploring the Dataset
This project revolves around 8 key business questions corresponding to 8 queries.

**Context 1**: A retail business has recently launched an advertising campaign to increase website traffic. The marketing team requests to measure the effectiveness of the campaign through three metrics: **visits, pageviews, and transactions**

### Question 1: Calculate total visit, pageview, transaction and revenue for January, February and March 2017 order by month

**SQL code**
- [_table_suffix](https://cloud.google.com/bigquery/docs/querying-wildcard-tables): often used in BigQuery, refers to a special parameter that allows you to specify a suffix for table names. This is particularly useful for querying across multiple tables with a common naming pattern.
![image](https://github.com/user-attachments/assets/1b138543-3362-466a-b04c-3ce31ef6fc51)


**Query result**

![image](https://github.com/user-attachments/assets/0d85268f-b1d9-494b-aefd-57748a02ac99)

**Context 2**: After the phase of attracting customers to the website (**Question 1**), the second phase will require analyzing which traffic sources bring in the most customers (**Question 2**) and the highest revenue (**Question 3**). From there, the focus will be on strengthening the advertising campaign on effective traffic sources, while eliminating inefficient sources to save costs.

### Question 2: Bounce rate per traffic source in July 2017
**SQL code**
- **Bounce_rate = num_bounce/total_visit**
- [_table_suffix](https://cloud.google.com/bigquery/docs/querying-wildcard-tables): often used in BigQuery, refers to a special parameter that allows you to specify a suffix for table names. This is particularly useful for querying across multiple tables with a common naming pattern.
- If get all days in July, we do not need condition (WHERE clause). But I add condition to easily reuse SQL code
![image](https://github.com/user-attachments/assets/3652aaf4-7fe0-478a-bfda-266a0fa18b98)

**Query result**
- Although there are results with duplicate values (google, google.com, sites.google.com, etc.), within the scope of this question, the SQL code only focuses on calculating key metrics and does not address duplicate values.

![image](https://github.com/user-attachments/assets/d867191c-af31-4ab8-898d-7bd69beedf36)


### Question 3: Revenue by traffic source by week, by month in June 2017
**SQL code**
- Create CTEs month and week (adding condition product revenue is not null), then using UNION ALL and order by source, time.
- [UNNEST](https://thedigitalskye.com/2021/01/21/explore-arrays-and-structs-for-better-performance-in-google-bigquery/): In SQL and data processing, UNNEST is a function used to expand an array or a nested structure into a set of rows.

![image](https://github.com/user-attachments/assets/baa7b143-3d5c-47b6-b303-c2b55aa35538)

**Query result**

![image](https://github.com/user-attachments/assets/30f7ec43-5747-4d90-91a1-2e0d35dfe880)


**Context 3**: After selecting the most effective traffic sources (in terms of revenue and quantity) to focus on (**Question 2, 3**), the next phase is to assess whether the website content is engaging enough or meets users' needs (**Question 4**). This will be measured through the **pageviews metric** of both purchasers and non-purchasers. If the pageviews of non-purchasers are lower than those of purchasers, it indicates that the website may need adjustments in terms of information or offer additional promotions to encourage customer conversion.

### Question 4: Average number of product pageviews by purchaser type (purchasers vs non-purchasers) in June, July 2017
**SQL code**
- Define **Purchaser**: customers have more than 1 transaction and product revenue is not null in July 2017. 
- Define **Non-purchaser**: customers do not any transactions (null) and product revenue is null in July 2017.
- Create CTEs purchaser_data, non_purchaser_data with conditions. Then using FULL JOIN
- **NOTE**: DO NOT USE INNER JOIN OR LEFT JOIN as it will result in data loss for non-purchasers. We must use FULL JOIN. For example, over a longer period, there might be a month x with data for non-purchasers but no data for purchasers. If you use INNER JOIN OR LEFT JOIN, the data for non-purchasers in month x will not appear
- [UNNEST](https://thedigitalskye.com/2021/01/21/explore-arrays-and-structs-for-better-performance-in-google-bigquery/): In SQL and data processing, UNNEST is a function used to expand an array or a nested structure into a set of rows.

![image](https://github.com/user-attachments/assets/db9b49fc-067c-4cbc-9b22-54f716e3f296)

**Query result**

![image](https://github.com/user-attachments/assets/deb85a35-64e8-49d1-892b-e1c0cf056f84)

**Context 4**: In July, the company decided to run a promotional campaign to clear out inventory. The Sales team wants to measure the effectiveness of the campaign through two metrics: the average number of orders per customer and the average spending per session (**Question 5, 6**)

### Question 5: Average number of transactions per user that made a purchase in July 2017
**SQL code**
- Define **Purchaser**: customers have more than 1 transaction and product revenue is not null in July 2017. 
- [UNNEST](https://thedigitalskye.com/2021/01/21/explore-arrays-and-structs-for-better-performance-in-google-bigquery/): In SQL and data processing, UNNEST is a function used to expand an array or a nested structure into a set of rows.

![image](https://github.com/user-attachments/assets/3eecd629-679c-4a56-a9d8-b9a0984bc7bb)

**Query result**

![image](https://github.com/user-attachments/assets/be634039-0a9a-4e6f-8cd2-340e79fc67bc)


### Question 6: Average amount of money spent per session. Only include purchaser data in July 2017
**SQL code**
- Define **Purchaser**: customers have more than 1 transaction and product revenue is not null in July 2017. 
- **POWER(10,6) means 10^6**
- [UNNEST](https://thedigitalskye.com/2021/01/21/explore-arrays-and-structs-for-better-performance-in-google-bigquery/): In SQL and data processing, UNNEST is a function used to expand an array or a nested structure into a set of rows.

![image](https://github.com/user-attachments/assets/d94095f7-4c9c-44f5-af2c-d241ba59fbe2)

**Query result**

![image](https://github.com/user-attachments/assets/6b717698-754e-42da-9953-59141b494bb5)


### Question 7: Other products purchased by customers who purchased product "YouTube Men's Vintage Henley" in July 2017. Output should show product name and the quantity was ordered.
**SQL code**
- Define **Purchaser**: customers have more than 1 transaction, product revenue is not null and one of products they purchased is YouTube Men's Vintage Henley in July 2017. 

**NOTE**: In the buyer_list table, I only want to find the list of buyers, but they might make multiple purchases. 
When I **SELECT DISTINCT** fullVisitorId, it shows 3 people, but if I **SELECT** fullVisitorId directly, it results in 6 rows, corresponding to 6 records in the table. Then these 6 rows are mapped again with the query below, causing duplication.

- [UNNEST](https://thedigitalskye.com/2021/01/21/explore-arrays-and-structs-for-better-performance-in-google-bigquery/): In SQL and data processing, UNNEST is a function used to expand an array or a nested structure into a set of rows.
  
![image](https://github.com/user-attachments/assets/b70fbc2a-2901-4e9b-9927-5a6f6d8d56c3)

**Query result**

![image](https://github.com/user-attachments/assets/70b63c3e-25a8-4bc5-afe8-d964aa946bb8)

**Context 5**: The company ran a campaign aimed at boosting the purchase rate in March 2017. The Sales team wants to know if there are any differences in how customers interacted over time during the campaign compared to before the campaign (**Question 8**). This requires using a cohort map to understand customer interactions and compare March with the previous two months (January and February).

### Question 8: Calculate cohort map from pageview to addtocart to purchase in last 3 month.
**SQL code**
- **Add_to_cart_rate = number product add to cart/number product view.** 
- **Purchase_rate = number product purchase/number product view. **
- Create CTEs product_view, add_to_cart, purchase. Then using LEFT JOIN to calculate cohort map.

**NOTE**: in purchase table, we need to add condition product revenue is not null in order to advoid mistakes.

**NOTE**: We can use a LEFT JOIN without encountering data loss issues, because when customers want to add items to their cart or purchase a product, they must view that product first.

- [UNNEST](https://thedigitalskye.com/2021/01/21/explore-arrays-and-structs-for-better-performance-in-google-bigquery/): In SQL and data processing, UNNEST is a function used to expand an array or a nested structure into a set of rows.

![image](https://github.com/user-attachments/assets/7c9ff5ce-7570-4d03-add3-45783fe3f06b)
![image](https://github.com/user-attachments/assets/a6791df6-fad4-487c-9f9b-0483eeb81da1)


**Query result**

![image](https://github.com/user-attachments/assets/82391266-f03c-4605-a606-820ff027511b)

## III. Conclusion
- By exploring eCommerce dataset, I have gained valuable information about total visits, pageview, transactions, bounce rate, and revenue per traffic source,.... which could inform future business decisions.
- Overall, this project has demonstrated the power of using SQL and big data tools like Google BigQuery to gain insights into large datasets and showed my SQL skills.

