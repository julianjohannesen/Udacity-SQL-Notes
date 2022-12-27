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

### HAVING
Say you want to get a list of accounts with total sales greater than $250,000. This isn't something that you can do with a WHERE clause, because you can not include aggregations in a WHERE clause. Instead, you need to use the HAVING clause. The HAVING clause must appear after the GROUP BY clause, because it is executed after any aggregate functions have been performed. Note that the HAVING clause really only works when you're group by 1 or 2 columns.

So, this will NOT work:
```sql
SELECT account_id,
       SUM(total_amt_usd) AS sum_total_amt_usd
FROM orders
/* This will NOT work! */
WHERE SUM(total_amt_usd) >= 250000
GROUP BY 1
ORDER BY 2 DESC
```

However, you can successfully do this:
```sql
SELECT account_id,
       SUM(total_amt_usd) AS sum_total_amt_usd
FROM orders
GROUP BY 1
HAVING SUM(total_amt_usd) >= 250000
ORDER BY 2 DESC
```
As you can see the WHERE clause has been replaced by a HAVING clause that appears after the GROUP BY clause.

### Problems 

1. How many of the sales reps have more than 5 accounts that they manage?
```sql
select sr.name, count(a.id) as acc_count
from sales_reps sr
join accounts a
on a.sales_rep_id = sr.id
group by sr.name
having count(a.id) > 5
```
You can also get this result using a subquery, like this:
```sql
SELECT COUNT(*) num_reps_above5
FROM(SELECT s.id, s.name, COUNT(*) num_accounts
     FROM accounts a
     JOIN sales_reps s
     ON s.id = a.sales_rep_id
     GROUP BY s.id, s.name
     HAVING COUNT(*) > 5
     ORDER BY num_accounts) AS Table1;
```

2. How many accounts have more than 20 orders?
```sql
select accounts.id, count(orders.id) 
from accounts
join orders 
on orders.account_id = accounts.id
group by accounts.id
having count(orders.id) > 20
order by count(orders.id) desc
```
In the solution provided by Udacity, they use count(*) in both the select clause and the having clause, rather than count(orders.id). I guess that works, because we're looking at the inner join of the two tables, which means that every orders.account_id is associated with an account.id.

3. Which account has the most orders?
```sql
select accounts.name, count(orders.id)
from accounts
join orders 
on orders.account_id = accounts.id
group by accounts.name
order by count(orders.id) desc
limit 1
```

4. Which accounts spent more than 30,000 usd total across all orders?
```sql
select a.name, sum(o.total_amt_usd)
from accounts a
join orders o
on o.account_id = a.id
group by a.name
having sum(o.total_amt_usd) > 30000
order by sum(o.total_amt_usd) desc
```
Note that you can alias the sum of the totals and use that alias in the order by clause, but you can't use the alias in the having clause.

5. Which accounts spent less than 1,000 usd total across all orders?
```sql
select a.name, sum(o.total_amt_usd)
from accounts a
join orders o
on o.account_id = a.id
group by a.name
having sum(o.total_amt_usd) < 1000
order by sum(o.total_amt_usd) desc
```

6. Which account has spent the most with us?
```sql
select a.name, sum(o.total_amt_usd)
from accounts a
join orders o
on o.account_id = a.id
group by a.name
order by sum(o.total_amt_usd) desc
limit 1
```

7. Which account has spent the least with us?
```sql
select a.name, sum(o.total_amt_usd)
from accounts a
join orders o
on o.account_id = a.id
group by a.name
order by sum(o.total_amt_usd)
limit 1
```

8. Which accounts used facebook as a channel to contact customers more than 6 times?
```sql
select a.name
from accounts a
join web_events we
on we.account_id = a.id
where we.channel = 'facebook'
group by a.name
having count(a.id) > 6
order by a.name
```
Udacity solved this differently, choosing not to use the where clause and to put the "we.channel = 'facebook'" expression into the having clause. 

9. Which account used facebook most as a channel?
```sql
select a.name, count(a.id) as num_uses
from accounts a
join web_events we
on we.account_id = a.id
where we.channel = 'facebook'
group by a.name
order by num_uses desc
limit 1
```
Udacity notes that using limit like this only works if there are no ties. It's a good idea to check that by trying limit 5 first.

10. Which channel was most frequently used by most accounts?

This question is badly worded. It sounds like they want a result with one channel name and that's it, i.e. the one channel that was used more frequently than any other channel for at least half the accounts. But what they wanted was a list of account names, the most frequently used channel for that account name, and the number of times the channel was used.
```sql
SELECT a.id, a.name, w.channel, COUNT(*) use_of_channel
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
GROUP BY a.id, a.name, w.channel
ORDER BY use_of_channel DESC
LIMIT 10;
```

### Dates
Storing dates as YY-MM-DD is useful because it means that dates will be in the correct chronological order even when sorted as text, i.e. 10-01-23 will appear before 10-01-24, etc.

DATE_TRUNC is a function that allows you to truncate your date to a particular part of your date-time column. Common truncations are *day*, *month*, and *year*.

DATE_PART can be useful for pulling a specific portion of a date, but notice pulling month or day of the week (dow) means that you are no longer keeping the years in order. Rather you are grouping for certain components regardless of which year they belonged in.

Note: 'dow' stands for day of week and returns a number from 0-6 where 0 is Sunday and 6 is Saturday.

Example 1. How much standard paper was sold on April 1st, 2016?
```sql
select date_trunc('day', o.occurred_at) as the_date, 
	sum(o.standard_qty) as total_standard_sold
from orders o
group by 1
having date_trunc('day', o.occurred_at) = '2016-04-01:00:00:00'
```
Here we're truncating the occurred_at column to just the day and calling it the_date. We're also getting the sum of standard_qty and calling it total_standard_qty. We're selecting these aggregates from the orders table. We're also group by the_date, which we can refer to as just "1". And we're setting the truncated date to April, 1st 2016. 

Example 2. Which day of the week does Parch and Posey sell the most paper?
```sql
select date_part('dow', occurred_at) as day_of_week,
   sum(total) as total_qty
from orders
group by 1
order by 2 desc
```
Here, we're selecting the occurred_at column and aggregating by day of the week using the date_trunc function. We're also selecting the total column and aggregating by the sum of total. We've aliased both of those aggregations. We're selecting from the orders table and grouping by day_of_week, which we refer to here as "1". Finally, we're ordering by total_qty, which we refer to here as "2" with the totals in descending order.

### Using numbers in the GROUP BY and ORDER BY clause to refer to previously identified columns
You can use numbers in the GROUP BY and ORDER BY clause to refer to columns previously identified in the SELECT clause. For example,
```sql
SELECT standard_qty, COUNT(*)
FROM orders
GROUP BY 1 /*this 1 refers to standard_qty since it is the first of the columns included in the select statement*/
ORDER BY 1 /*this 1 refers to standard_qty since it is the first of the columns included in the select statement*/
```

### Date and Time Problems
1. Find the sales in terms of total dollars for all orders in each year, ordered from greatest to least. Do you notice any trends in the yearly sales totals?
```sql
select date_trunc('year', o.occurred_at) as year, sum(o.total_amt_usd) as sum
from orders o
group by 1
order by 2 desc
```
Here, we're selecting the occurred_at and total_amt_usd columns from the orders table, but we're truncating the date by year and summing the orders. We're grouping by the truncated occurred_at column, and ordering in descending order by the sum of total_amt_usd.

2. Which month did Parch & Posey have the greatest sales in terms of total dollars? Are all months evenly represented by the dataset?

I used date_trunc, not date_part here. It's tough to tell what the course designers are asking for. I thought they were asking for the single month that had the highest sales, starting back in 2013 and moving right up through 2017 inclusive. But it turns out that that's not what they were asking. Instead, they wanted to know, if you group all of the months together by name, which "month type" has the highest sales. The answer is still December, but the totals are obviously different. They also excluded 
```sql
select date_trunc('month', o.occurred_at) as month, sum(o.total_amt_usd) as sum
from orders o
group by date_trunc('month', o.occurred_at)
order by sum desc
limit 1
```

3. Which year did Parch & Posey have the greatest sales in terms of the total number of orders? Are all years evenly represented by the dataset?

In this case, it makes no difference whether you use date_trunc or date_part, except that the table just looks nice if you use date_part.
```sql
select date_trunc('year', o.occurred_at) as year, count(*) as orders_count
from orders o
group by date_trunc('year', o.occurred_at)
order by orders_count desc
```

4. Which month did Parch & Posey have the greatest sales in terms of the total number of orders? Are all months evenly represented by the dataset?

I made the same mistake here that I did in quesiton 2.
```sql
select date_trunc('month', o.occurred_at) as year, count(*) as orders_count
from orders o
group by date_trunc('month', o.occurred_at)
order by orders_count desc
```

5. In which month of which year did Walmart spend the most on gloss paper in terms of dollars?
```sql
select a.name, date_trunc('month', o.occurred_at) as month, sum(gloss_amt_usd) as gloss_sales
from orders o
join accounts a
on o.account_id = a.id
where a.name = 'Walmart'
group by a.name, date_trunc('month', o.occurred_at)
order by gloss_sales desc
limit 1
```

### CASE Statement
The CASE statement is SQL's way of handling if...then logic. 

- The CASE statement always goes in the SELECT clause.
- CASE must include the following components: WHEN, THEN, and END. ELSE is an optional component to catch cases that didn’t meet any of the other previous CASE conditions.
- You can make any conditional statement using any conditional operator (like WHERE) between WHEN and THEN. This includes stringing together multiple conditional statements using AND and OR.
- You can include multiple WHEN statements, as well as an ELSE statement again, to deal with any unaddressed conditions.

Here's an example. Say you want to find the unit price for standard paper for each order by dividing standard_amt_usd by standard_qty. The answer below will cause an error due to divison by 0.
```sql
SELECT id, account_id, standard_amt_usd/standard_qty AS unit_price
FROM orders
```

However, we can avoid this error by using a case clause.
```sql
SELECT id, account_id,
   case when standard_qty = 0  or standard_qty is null then 0 
         else standard_amt_usd/standard_qty end AS unit_price
FROM orders
LIMIT 10;
```

Here's another example. Say you want to create a column to identify whether a record is within a certain total quantity range. 
```sql
SELECT account_id,
       occurred_at,
       total,
       CASE WHEN total > 500 THEN 'Over 500'
            WHEN total > 300 AND total <= 500 THEN '301 - 500'
            WHEN total > 100 AND total <=300 THEN '101 - 300'
            ELSE '100 or under' END AS total_group
FROM orders
```

### CASE and Aggregations
How do you aggregate based on derived columns created with CASE statements? Here's an example. Say you want to know how many orders have a total quantity under 500 and how many have a total quantity over 500. The query looks like this:
```sql
select case when total < 500 then 'Less than 500'
            else 'Greater than or equal to 500' end as category,
   count(*) as order_count
from orders
/* We use 1 in the group by statement to avoid repeating the entire case statement */
group by 1 
```

Can you do this with a WHERE clause? Yes:
```sql
SELECT COUNT(1) AS orders_over_500_units
FROM orders
WHERE total > 500
```
The limitation is that this kind of query can only handle 1 condition. The results will display only the orders over 500. For more complicated conditions, you need to use case with aggregations.

### Problems with CASE and Aggregations
1. Write a query to display for each order, the account ID, the total amount of the order, and the level of the order - ‘Large’ or ’Small’ - depending on if the order is $3000 or more, or smaller than $3000.
```sql
select o.account_id, o.total_amt_usd, 
   case when o.total_amt_usd > 3000 then 'Large' 
        else 'Small' end
from orders o
```

2. Write a query to display the number of orders in each of three categories, based on the total number of items in each order. The three categories are: 'At Least 2000', 'Between 1000 and 2000' and 'Less than 1000'.

Remember what you're trying to display: a number of orders column, and a category column that has 3 possible categories. The number of orders column is going to be a count of the orders within each category. How do you know that the count will be correctly divided into our 3 possible categories? In the group by clause we group by the case statement, and that ensures that the count will be divided according to the conditions we set up in the case statement.
```sql
select case when total >= 2000 then 'At least 2000'
            when total < 2000 and total >= 1000 then 'Between 1000 and 2000'
            else 'Less than 1000' end as category,
      count(*) as count 
from orders
group by 1
```

3. We would like to understand 3 different levels of customers based on the amount associated with their purchases. 

The top-level includes anyone with a Lifetime Value (total sales of all orders) greater than 200,000 usd. The second level is between 200,000 and 100,000 usd. The lowest level is anyone under 100,000 usd. 

Provide a table that includes the level associated with each account. You should provide the account name, the total sales of all orders for the customer, and the level. Order with the top spending customers listed first.

Again, what do we want to display? Three columns. Column 1 will show the account name. Column 2 will show their total purchase amount per account. Column 3 will show our categories, which we set up with our case statement. 

How do we get the total amount spent per account? We need to sum the total_amt_usd for each order associated with that account. There may be several orders associated with each account. We can use sum(total_amt_usd) to do this and then group by account to make sure the sum is broken up by account.

How do we get the conditions for the case statement? We need to use the same sum(total_amt_usd) function in the first two conditions of the case statement. The group by clause will ensure that we're only dealing with the total_lifetime for this account name.

### For me, the big takeaway is that you can use aggregations inside the conditions of a case statement and your group by clause will make sure that they're grouped appropriately.
```sql
select 
   a.name, 
   sum(o.total_amt_usd) as total_lifetime,
   case when sum(o.total_amt_usd) > 200000 then 'top'
      when sum(o.total_amt_usd) <= 200000 and sum(o.total_amt_usd) > 100000 then 'mid'
      else 'low' end as Lifetime_Value
from accounts a
join orders o
on o.account_id = a.id
group by 1
order by 2 desc
```

4. We would now like to perform a similar calculation to that in question 3, but we want to obtain the total amount spent by customers only in 2016 and 2017. Keep the same levels as in the previous question. Order with the top spending customers listed first.
```sql
select 
   a.name, 
   sum(o.total_amt_usd) as total_lifetime,
   case when sum(o.total_amt_usd) > 200000 then 'top'
      when sum(o.total_amt_usd) <= 200000 and sum(o.total_amt_usd) > 100000 then 'mid'
      else 'low' end as Lifetime_Value
from accounts a
join orders o
on o.account_id = a.id
where o.occurred_at > '2015-12-31'
group by 1
order by 2 desc
```

5. We would like to identify top-performing sales reps, which are sales reps associated with more than 200 orders. Create a table with the sales rep name, the total number of orders, and a column with top or not depending on if they have more than 200 orders. Place the top salespeople first in your final table.
```sql
select sr.name, count(o.id),
   case when count(o.id) > 200 then 'top'
        else 'bottom' end
from sales_reps sr
join accounts a
on a.sales_rep_id = sr.id
join orders o
on o.account_id = a.id
group by 1
order by 2 desc
```

6. Question 5 didn't account for the middle, nor the dollar amount associated with the sales. Management decides they want to see these characteristics represented as well. We would like to identify top-performing sales reps, which are sales reps associated with more than 200 orders or more than 750000 in total sales. The middle group has any rep with more than 150 orders or 500000 in sales. Create a table with the sales rep name, the total number of orders, total sales across all orders, and a column with top, middle, or low depending on these criteria. Place the top salespeople based on the dollar amount of sales first in your final table. You might see a few upset salespeople by this criteria!
```sql
select sr.name, count(o.id), sum(o.total_amt_usd),
   case when count(o.id) > 200 or sum(o.total_amt_usd) > 200000 then 'top'
        when count(o.id) > 150 or sum(o.total_amt_usd) > 150000 then 'middle'
        else 'bottom' end
from sales_reps sr
join accounts a
on a.sales_rep_id = sr.id
join orders o
on o.account_id = a.id
group by 1
order by 3 desc
```
