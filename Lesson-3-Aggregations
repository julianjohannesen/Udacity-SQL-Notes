## Lesson 3: Aggregations

### What is a NULL
NULLs are a datatype that specifies where no data exists in SQL. That's not the same thing as 0. NULLs are often ignored in our aggregation functions. 

### How do you use a NULL?
When identifying NULLs in a WHERE clause, we write IS NULL or IS NOT NULL. We don't use =, because NULL isn't considered a value in SQL. Rather, it is a property of the data. For example:
```sql
SELECT *
FROM accounts
WHERE primary_poc IS NOT NULL
```
Here, we SELECT all columns FROM the account table WHERE the primary_poc IS NOT NULL. In other words, return all the records that do not have a null value in the primary_poc column.

### What are two circumstances in which you might encounter NULL?

- NULLs frequently occur when performing a LEFT or RIGHT JOIN. You saw in the last lesson - when some rows in the left table of a left join are not matched with rows in the right table, those rows will contain some NULL values in the result set.
- NULLs can also occur from simply missing data in our database.

### COUNT
The COUNT function gives you the total number of records in a table or the number of non-null records in a particular column in a table. COUNT works in columns with numerical values, but also in other columns. That's not true of some functions, like SUM and AVG. 

An example,
```sql
SELECT COUNT(*) AS order_count
FROM orders
WHERE occurred_at >= '2016-12-01'
AND occurred_at < '2017-01-01'
```
Here, we SELECT the COUNT of all records, which we'll call order_count, FROM the orders table WHERE occurred_at is great than or equal to '2016-12-01' AND less than '2017-01-01'. 

### SUM
SUM will add up all of the numerical values in a column, ignoring the null values. Here's an example,
```sql
SELECT SUM(standard_qty) AS standard,
       SUM(gloss_qty) AS gloss,
       SUM(poster_qty) AS poster
FROM orders
```
Here, we SELECT the SUM for each of three different columns: standard_qty, gloss_qty, and poster_qty. We also assign them aliases: standard, gloss, and poster. We get all of these FROM the orders table.

### MIN and MAX
MIN and MAX work similarly to SUM. However, functionally, MIN and MAX are similar to COUNT in that they can be used on non-numerical columns. Depending on the column type, MIN will return the lowest number, earliest date, or non-numerical value as early in the alphabet as possible. As you might suspect, MAX does the opposite—it returns the highest number, the latest date, or the non-numerical value closest alphabetically to “Z.” Here's an example:
```sql
SELECT MIN(standard_qty) AS standard_min,
       MIN(gloss_qty) AS gloss_min,
       MIN(poster_qty) AS poster_min,
       MAX(standard_qty) AS standard_max,
       MAX(gloss_qty) AS gloss_max,
       MAX(poster_qty) AS poster_max
FROM   orders
```
Here, we getting the minimum value and the maximum value for 3 columns: standard_qty, gloss_qty, and poster_qty. 

### AVG
The average function, AVG, gives us the average for a range of numerical values in a column. Rows with NULL values are ignored. If you want to get an average that considers NULLs as 0, then you'll have to divide the SUM by the COUNT for a column. Interestingly, it's apparetly difficult to find the median value in a column of numerical values. Here's an example:
```sql
SELECT AVG(standard_qty) AS standard_avg,
       AVG(gloss_qty) AS gloss_avg,
       AVG(poster_qty) AS poster_avg
FROM orders
```
### Practice Problems with MIN, MAX, and AVG

Problem 1. When was the earliest order ever placed? You only need to return the date.
```sql
select min(orders.occurred_at)
from orders
```

Problem 2. Try performing the same query as in question 1 without using an aggregation function.
```sql
select orders.occurred_at
from orders
order by orders.occurred_at
limit 1
```

Problem 3. When did the most recent (latest) web_event occur?
```sql
select max(we.occurred_at)
from web_events we
```

Problem 4. Try to perform the result of the previous query without using an aggregation function.
```sql
select we.occurred_at
from web_events we
order by we.occurred_at desc
limit 1
```

Problem 5. Find the mean (AVERAGE) amount spent per order on each paper type, as well as the mean amount of each paper type purchased per order. Your final answer should have 6 values - one for each paper type for the average number of sales, as well as the average amount.
```sql
select avg(o.standard_amt_usd), avg(o.gloss_amt_usd), avg(o.poster_amt_usd), avg(o.standard_qty), avg(o.gloss_qty), avg(o.poster_qty)
from orders o
```

Problem 6. Via the video, you might be interested in how to calculate the MEDIAN. Though this is more advanced than what we have covered so far try finding - what is the MEDIAN total_usd spent on all orders?
```sql
SELECT *
FROM (SELECT total_amt_usd
   FROM orders
   ORDER BY total_amt_usd
   LIMIT 3457) AS Table1
ORDER BY total_amt_usd DESC
LIMIT 2;
```
Since there are 6912 orders - we want the average of the 3457 and 3456 order amounts when ordered. This is the average of 2483.16 and 2482.55. This gives the median of 2482.855. This obviously isn't an ideal way to compute. If we obtain new orders, we would have to change the limit. SQL didn't even calculate the median for us. The above used a SUBQUERY, but you could use any method to find the two necessary values, and then you just need the average of them.

Tom Chan suggested this solution, which uses syntax that hasn't been covered yet:
```sql
SELECT a.l_mid,
   a.r_mid,
   b.total_amt_usd as l_total_amt_usd,
   c.total_amt_usd as r_total_amt_usd,
   (b.total_amt_usd + c.total_amt_usd)*1.0/2 AS MEDIAN		
FROM (SELECT CASE WHEN COUNT(1)%2=0 THEN COUNT(1)/2   ELSE (COUNT(1)+1)/2 END AS l_mid,
             CASE WHEN COUNT(1)%2=0 THEN COUNT(1)/2+1 ELSE (COUNT(1)+1)/2 END AS r_mid
      FROM orders) a
   JOIN (SELECT total_amt_usd, ROW_NUMBER() 
         OVER(ORDER BY total_amt_usd) AS rn 
         FROM orders) b 
   ON a.l_mid=b.rn
   JOIN (SELECT total_amt_usd, ROW_NUMBER() 
         OVER(ORDER BY total_amt_usd) AS rn 
         FROM orders) c 
   ON a.r_mid=c.rn 
```

### GROUP BY
Thus far, we've used aggregrates to aggregate entire columns in a table. But let's say you want to get the sum of all of the sales by paper type for each account. How would you do that? Well, that requires GROUP BY. Group by allows us to create segments within a column that will be aggregated independently of one another. 

### Where does GROUP BY go?
GROUP BY goes between the WHERE clause and the ORDER BY clause. 

### How do you use GROUP BY?
Any column included the SELECT clause that is not being aggregated, must be included in the GROUP BY clause. For example:

```sql
SELECT account_id,
       SUM(standard_qty) AS standard,
       SUM(gloss_qty) AS gloss,
       SUM(poster_qty) AS poster
FROM orders
GROUP BY account_id
ORDER BY account_id
```
Here, we select orders.account_id and the sums of quantities of each type of paper. We get those FROM the orders table. However, we must GROUP BY account_id if what we want to see is the sums per account. It also helps to ORDER BY the account_id.

### GROUP BY Practice Problems from section 14

1. Which account (by name) placed the earliest order? Your solution should have the account name and the date of the order.
```sql
select accounts.name, orders.occurred_at
from orders
join accounts
on orders.account_id = accounts.id
order by orders.occurred_at
limit 1
```

2. Find the total sales in usd for each account. You should include two columns - the total sales for each company's orders in usd and the company name.
```sql
select a.name, sum(o.total) as total
from accounts a
join orders o
on o.account_id = a.id
group by a.name
order by a.name
```

3. Via what channel did the most recent (latest) web_event occur, which account was associated with this web_event? Your query should return only three values - the date, channel, and account name.
```sql
select a.name, we.channel, max(we.occurred_at) as occurred_at
from accounts a
join web_events we
on we.account_id = a.id
group by a.name, we.channel
order by occurred_at desc
limit 1
```
Note that this solution works, but it turns out that the max function is unnecessary and probably slows the query down a bit. You get the exact same answer with this solution:
```sql
SELECT w.occurred_at, w.channel, a.name
FROM web_events w
JOIN accounts a
ON w.account_id = a.id 
ORDER BY w.occurred_at DESC
LIMIT 1;
```

4. Find the total number of times each type of channel from the web_events was used. Your final table should have two columns - the channel and the number of times the channel was used.
```sql
select we.channel, count(we.channel) as channel_count
from web_events we
group by we.channel
```

5. Who was the primary contact associated with the earliest web_event?
```sql
select a.primary_poc, min(we.occurred_at) as occurred_at
from accounts a
join web_events we
on we.account_id = a.id
group by a.primary_poc
order by occurred_at
limit 1
```
This is another error. The solution returns the correct result, but the function isn't necessary, and it probably slows things down. The solution given in section 15 is:
```sql
SELECT a.primary_poc
FROM web_events w
JOIN accounts a
ON a.id = w.account_id
ORDER BY w.occurred_at
LIMIT 1;
```

6. What was the smallest order placed by each account in terms of total usd. Provide only two columns - the account name and the total usd. Order from smallest dollar amounts to largest.
```sql
select a.name, min(o.total_amt_usd) as total
from orders o
join accounts a
on o.account_id = a.id
group by a.name
order by total
```

7. Find the number of sales reps in each region. Your final table should have two columns - the region and the number of sales_reps. Order from the fewest reps to most reps.
```sql
select r.name, count(sr.name) as number_of_reps
from region r
join sales_reps sr
on sr.region_id = r.id
group by r.name
order by number_of_reps
```

### Grouping by Multiple Columns
You can GROUP BY and ORDER BY multiple columns in the same query. For example, say you want to get the number of events per channel per account id. Because we're only after the account_id, we can confine our query to the web_events table without needing to join any other table. And because each id in the web_events table represents an event, we can just count the ids to get the number of events. Because we're counting the ids, we know we'll need at least one group by value. But we don't just want to events per channel or events per account id. Instead, we want events per channel *per account id*. To get that, we need both of those columns in our GROUP BY clause.
```sql
SELECT account_id,
       channel,
       COUNT(id) as events
FROM web_events
GROUP BY account_id, channel
ORDER BY account_id, channel DESC
```
Here, we're getting the account id, channel and count of id from web_events, and we're grouping by both account_id and channel. We're also ordering by account_id first, then channel. Note that the order that you list the columns in the GROUP BY clause doesn't matter, but the order that list columns in the ORDER BY clause does.

### Problems from Section 17
1. For each account, determine the average amount of each type of paper they purchased across their orders. Your result should have four columns - one for the account name and one for the average quantity purchased for each of the paper types for each account.
```sql
select a.name, avg(o.standard_qty) as stand, avg(o.gloss_qty) as gloss, avg(o.poster_qty) as poster
from orders o
join accounts a
on o.account_id = a.id
group by a.name
order by a.name
```

2. For each account, determine the average amount spent per order on each paper type. Your result should have four columns - one for the account name and one for the average amount spent on each paper type.
```sql
select a.name, avg(standard_amt_usd) as stand, avg(gloss_amt_usd) as gloss, avg(poster_amt_usd) as poster
from orders o
join accounts a
on o.account_id = a.id
group by a.name
order by a.name
```

3. Determine the number of times a particular channel was used in the web_events table for each sales rep. Your final table should have three columns - the name of the sales rep, the channel, and the number of occurrences. Order your table with the highest number of occurrences first.
```sql
select sr.name, we.channel, count(we.id) as occurrences
from accounts a
join sales_reps sr
on a.sales_rep_id = sr.id
join web_events we
on we.account_id = a.id
group by sr.name, we.channel
order by occurrences desc
```

4. Determine the number of times a particular channel was used in the web_events table for each region. Your final table should have three columns - the region name, the channel, and the number of occurrences. Order your table with the highest number of occurrences first.
```sql
select r.name, we.channel, count(we.id) as occurrences
from region r
join sales_reps sr
on sr.region_id = r.id
join accounts a
on a.sales_rep_id = sr.id
join web_events we
on we.account_id = a.id
group by r.name, we.channel
order by occurrences desc

```

### DISTINCT
DISTINCT is always used in SELECT statements, and it provides the unique rows for all columns written in the SELECT statement. Therefore, you only use DISTINCT once in any particular SELECT statement. Note that DISTINCT, especially in aggregations, can slow your queries.

### Problems

1. Are there any accounts associated with more than one region?

This is the solution that makes the most sense to me:
```sql
select a.name as account_name, count(r.name) as region_count
from region r
join sales_reps sr on sr.region_id = r.id
join accounts a    on a.sales_rep_id = sr.id
group by account_name
order by region_count, account_name
```
This solution shows us the account names and the number of regions associated with each account. However, it turns out that this is a very roundabout way to answer the question being asked.

This is the most succinct (and probably fastest) solution, using DISTINCT:
```sql
SELECT DISTINCT id, name
FROM accounts;
```
I think the reasoning is that if there were any accounts that had more than one region, then there would have to be duplicate account ids and names in the accounts table to allow for a single account having two or more regions. There are no such duplicate accounts, therefore there are no accounts associated with more than one region.

2. Have any sales reps worked in more than one account?

This is what makes sense to me:
```sql
select distinct sr.id as sr_id, sr.name as sr_name, a.id as a_id, a.name as a_name
from sales_reps sr
join accounts a
on a.sales_rep_id = sr.id
order by sr.id, a.id
```
The result we get here shows us the sales reps' names and account names, making it obvious that all sales reps are associated with more than just one account.

This is the actual answer:
```sql
SELECT DISTINCT id, name
FROM sales_reps;
```
What this query returns is a list of 50 names, but if you know that there are more than 50 accounts (there are), then you quickly realize that at least one sales rep has more than one account. As it turns out, all of the sales reps have more than one account. 

It's pretty annoying that there isn't more explanation offered in the course material. This stuff may seem quite obvious to the course designers, but I don't think it will be obvious to everyone.
