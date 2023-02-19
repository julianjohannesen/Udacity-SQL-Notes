# Query Examples

## 1. Find the first 10 web events ever to occur and return the dates that those events occurred and the names of the customers that were involved. Order by order date ascending.

```sql
select a.name, we.occurred_at
from web_events we
join accounts a
on we.account_id = a.id
order by 2
limit 10
```

Answer:
name | occurred_at
-----|-------------
DISH Network	| 12/4/2013 4:18
American Family Insurance Group	| 12/4/2013 4:44
American Family Insurance Group	| 12/4/2013 8:27
DISH Network	| 12/4/2013 18:22
Citigroup	| 12/5/2013 20:17
Citigroup	| 12/5/2013 21:22
Altria Group	| 12/6/2013 2:03
Guardian Life Ins. Co. of America	| 12/6/2013 7:52
Altria Group	| 12/6/2013 11:48
United States Steel	| 12/6/2013 12:31

## 2. Who were the top 10 customers in terms of web events in 2016?

```sql
select a.name, count(we.occurred_at)
from web_events we
join accounts a
on we.account_id = a.id
where occurred_at between '2015-12-31 23:59:59' and '2017-01-01 00:00:00'
group by 1
order by 2 desc
limit 10
```

Answer:
name | count
-----|-------
Performance Food Group	|38
Merck	|35
Philip Morris International	|34
Colgate-Palmolive	|34
Charter Communications	|33
Lowe's	|33
Cigna	|33
Texas Instruments	|32
American Express	|32
Coca-Cola	|32

## 3. When was Walmart's first web event?

```sql
select a.name, we.occurred_at
from web_events we
join accounts a
on we.account_id = a.id
where a.name = 'Walmart'
order by 2
limit 1
```

Answer:
name | occurred_at
-----|-------------
Walmart | "2015-10-06 04:22:11"

## 4. How many regions and accounts is each sales rep responsible for? Group by accounts per region per rep and show all three columns.

```sql
select sr.name, r.name as region, count(*) as num_accounts
from sales_reps sr
join region r
on sr.region_id = r.id
join accounts a
on a.sales_rep_id = sr.id
group by 1,2
order by 1,2
```

Answer (showing just the first 5 of 50 rows):

name|	region|	num_accounts
----|---------|------------
Akilah Drinkard	|Northeast	|3
Arica Stoltzfus	|West	|10
Ayesha Monica	|Northeast	|3
Babette Soukup	|Southeast	|7
Brandie Riva	|West	|10

This is interesting because when we look at all 50 rows we can immediately see that each sales rep has only one region and that several sales rep might be assigned to the same region. We can also see that some sales reps have as many as 5 times the number of accounts as other sales reps.

## 5. Create a table of order price by account by region for all orders. Show region name, account name, and total price columns. Order by region and then account name.

```sql
select region.name as region_name, accounts.name as account_name, orders.total_amt_usd as total_order_price
from region
join sales_reps
on region.id = sales_reps.region_id
join accounts
on accounts.sales_rep_id = sales_reps.id
join orders
on orders.account_id = accounts.id
order by 1,2
```

Answer (first 5 of 6,912 rows)
region_name	| account_name | total_order_price
-|-|-
Midwest	|Abbott Laboratories	|8721.7
Midwest	|Abbott Laboratories	|10355.08
Midwest	|Abbott Laboratories	|8825.7
Midwest	|Abbott Laboratories	|5047.28
Midwest	|Abbott Laboratories	|8877.01



## 6. Create a table of total order cost by account by region for all accounts.

```sql
select region.name as region_name, accounts.name as account_name, sum(orders.total_amt_usd) as total_orders_cost
from region
join sales_reps
on region.id = sales_reps.region_id
join accounts
on accounts.sales_rep_id = sales_reps.id
join orders
on orders.account_id = accounts.id
group by 1,2
order by 1,2
```

Answer (first 5 of 350 rows)
region_name	| account_name | total_orders_cost
-|-|-
Midwest	|Abbott Laboratories	|96819.92
Midwest	|AbbVie	|11243.63
Midwest	|Aflac	|117862.77
Midwest	|Alcoa	|19882.16
Midwest	|Altria Group	|116165.15


## 7. Use a left or right join to create a table that shows the name of the one account that does not have any orders in the orders table. The table should show the name of the account and the orders total for that account (NULL in this case).

```sql
select a.name, o.total
from orders o
right join accounts a
on o.account_id = a.id
order by o.total desc
limit 1
```

Answer:
name | total
-|-
Goldman Sachs Group	| NULL

## 8. Create a table that shows sales reps whose last name starts with "M" and show their region and all associated accounts.

```sql
select sr.name as sales_rep, r.name as region_name, a.name as account
from sales_reps sr
join accounts a
on a.sales_rep_id = sr.id
join region r
on sr.region_id = r.id
where sr.name like '% M%'
order by 1,2,3
```

Answer (first 5 of 28 rows):
sales_rep | region_name	| account
-|-|-
Ayesha Monica	|Northeast	|AmerisourceBergen
Ayesha Monica	|Northeast	|Anthem
Ayesha Monica	|Northeast	|Cisco Systems
Cliff Meints	|Midwest	|Aflac

## 9. How many times has "Cognizant Technology Solutions" visited Parch & Posey via adwords?

```sql
select a.name, we.channel, count(*)
from accounts a 
join web_events we
on we.account_id = a.id
where a.name like 'Cog%' and we.channel like 'ad%'
group by 1,2
```

Answer
name|channel|count
-|-|-
Cognizant Technology Solutions	|adwords	|1

## 10. Which web event channels has Walmart used?

```sql
select distinct a.name, we.channel
from web_events we
join accounts a
on we.account_id = a.id
where a.name = 'Walmart'
```

Answer
name|channel
-|-
Walmart	|adwords
Walmart	|banner
Walmart	|direct
Walmart	|facebook
Walmart	|organic
Walmart	|twitter

## 11. Who placed the most recent order?

```sql
-- this took about 36ms on my machine
select accounts.name, orders.occurred_at
from accounts
join orders
on orders.account_id = accounts.id
where orders.occurred_at = (select max(orders.occurred_at) from orders)
```

You can solve this without a subquery like this:

```sql
-- this also took about 36ms, but randomly sometimes took as long as 50ms
select accounts.name, orders.occurred_at
from accounts
join orders
on orders.account_id = accounts.id
order by 2 desc
limit 1
```

Answer:
name|	occurred_at
-|-
W.W. Grainger|	1/2/2017 0:02

## 12. Find the median (not mean) total_amt_usd spent on all orders.

This solution uses Tom Chan's solution for finding the median value, regardless of the number of orders in the orders table. I've annotated it below, because it's a quite advanced.

```sql
SELECT 
    a.l_mid,
    a.r_mid,
    b.total_amt_usd AS l_total_amt_usd,
    c.total_amt_usd AS r_total_amt_usd,
    -- This is where we get our median. The subqueries below allow us to get these two numbers, so that we can add them and then divide by 2.
    (b.total_amt_usd + c.total_amt_usd)*1.0/2 AS MEDIAN
FROM 
/* We want the two middle values for our column of orders, whatever number of orders we have. */
(SELECT
    /* We want the "left mid value" which is the value 3456, given that we have 6912 orders */
	CASE
        -- if the number of orders is even, ...
        -- (fyi, count(1) returns the total count of orders, 6912)
        -- (fyi, x%2=0 is only true when x is an even number)
		WHEN COUNT(1)%2=0 
        -- then simply divide total number of orders by 2
		THEN COUNT(1)/2
        -- otherwise, add 1 to the total number of orders to make it even, and then divide by 2
		ELSE (COUNT(1)+1)/2 
	END AS l_mid,
    /* We want the "right mid value" which is the value 3457, given that we have 6912 orders */
    CASE
        -- if the number of orders is even, ...
		WHEN COUNT(1)%2=0 
        -- then divide the total number of orders by 2 and add 1 to the result
		THEN COUNT(1)/2+1 
        -- otherwise, add 1 to the total number of orders to make it even, and then divide by 2
		ELSE (COUNT(1)+1)/2 
	END AS r_mid
FROM orders) AS a
JOIN
/* We want to assign a row number to each order total cost for every one of our 6912 orders, but we want the orders to be in order from smallest value to largest value. Thus, row number 1 would 0 and row number 6912 would be  232,207.07 */
(SELECT 
    total_amt_usd, 
    -- (fyi, ROW_NUMBER() is a window function that assigns a number to each row in the query’s result set)
    -- (fyi, we don't need a partition because we want all 6912 orders to be considered)
    -- (fyi, we do need an order by clause because we want the orders in order from smallest to largest value)
    ROW_NUMBER() OVER(ORDER BY total_amt_usd) AS rn 
FROM orders) AS b
-- Join a and b on the condition that the left mid value is equal to the row number. This gives us the order price that is in row 3456, which is 2482.55
ON a.l_mid=b.rn
JOIN
/* This is the exact same subquery as b */
(SELECT 
    total_amt_usd, 
    ROW_NUMBER() OVER(ORDER BY total_amt_usd) AS rn 
FROM orders) AS c
-- Join a and c on the condition that the right mid value is equal to the row number. This gives us the order price that is in the row 3457, which is 2483.16
ON a.r_mid=c.rn 
```

Answer:
l_mid|	r_mid|	l_total_amt_usd|	r_total_amt_usd|	median
-|-|-|-|-
3456|	3457|	2482.55|	2483.16|	2482.855

## 13. What was the smallest order in terms of cost, placed by each account?

```sql
select a.name, min(o.total_amt_usd)
from accounts a
join orders o on o.account_id = a.id
group by 1
order by 2
```

Answer (first 5 of 350 rows):
name|min
-|-
Disney|0
Chevron|0
Twenty-First Century Fox|0
Reynolds American|0
Navistar International|0

