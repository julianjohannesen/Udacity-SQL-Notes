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

