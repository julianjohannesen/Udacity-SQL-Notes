## Lesson 4: Subqueries and Temporary Tables

### Goals for Lesson 4:
- Create subqueries to solve real-world problems
- Differentiate between Subqueries and Joins
- Implement the best type of Subqueries
- Consider the tradeoffs to using subqueries
- Implement the best subquery strategy

### Why do we need subqueries?
We need subqueries, because somtimes, the question you are trying to answer can't be solved with the set of tables in your database. Instead, there's a need to manipulate existing tables and join them to solve the problem at hand. Subqueries can do that.

### What exactly are subqueries?
A subquery is a query within a query. As far as I can tell "subquery" and "inner query" are interchangable. 

Here's an example:
```sql
SELECT product_id,
       name,
       price
FROM db.product
/* Note that subqueries always appear in parentheses) */
Where price > (SELECT AVG(price)
              FROM db.product)
```
Here we want to show a table including product ids, names, and prices, but only where the price is greater than the average price of products. To get the average price of products, we run a separate subquery with its own SELECT and FROM clauses. The lesson doesn't make it clear whether there is any way to construct this query without using a subquery.

### When do you use a subquery?
In the example above, you have to use a subquery, because you can't use just an aggregation in a WHERE clause. In this case, the whole subquery is executed first and the only thing the outer query sees in a number representing whatever that average is, e.g. WHERE price > 40.23.

Here are some examples of situations in which you would need to use a subquery:
| Problem                                                                           | Existing Table                            | Subquery              |
|-----------------------------------------------------------------------------------|-------------------------------------------|-----------------------|
| ID the top-selling Amazon products in months where sales have exceeded $1m        | Amazon daily sales                        | Daily to month        |
| Examine the average price of a brand’s products for the highest-grossing brands   | Product pricing data across all retailers | Individual to average |
| Order the annual salary of employees that are working less than 150 hours a month | Daily time-table of employees             | Daily to Monthly      |

### What the difference between joins and subqueries?
Both joins and subqueries combine data from one or more tables into a single result. They also work similarly under the hood. However, the strength of joins is that they allow you to display any number of columns or derived columns from both tables. Whereas the strength of subqueries is that they allow you to build an output that will be used in an outer query. There are some tradeoffs regarding performance and readability when trying to decide whether to use a join or subquery to solve a problem.

### Differences between joins and subqueries.
(If you're just looking at the markdown file, the table below will look really strange. You need to view the file in a markdown viewer.)

|              | Subquery                                                                                                                                                                          | Join                                                                                                                                 |
|--------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------|
| Use Cases    | When an existing table needs to be manipulated or aggregated to then be joined to a larger table.                                                                                 | A fully flexible and discretionary use case where a user wants to bring two or more tables together and select and filter as needed. |
| Syntax       | A subquery is query within a query. The syntax has multiple SELECT and FROM clauses.                                                                                              | A join stitches together multiple tales with a common key or column. A join clause cannot stand and be run independently.            |
| Dependencies | A subquery clause can be run completely independently. Why trying to debug code, subqueries are often run independently to pressure test results before running the larger query. | A join clause cannot stand and be run independently.                                                                                 |

### Similarities between joins and subqueries.
- Output: Both bring together multiple tables to generate a single output. 
- Deep-Dive: They're similar under the hood.

### More similarities and differences

Subqueries:
- Output: Either a scalar (a single value) or rows that have met a condition. 
- Use Case: Calculate a scalar value to use in a later part of the query (e.g., average price as a filter). 
- Dependencies: Stand independently and be run as complete queries themselves.

Joins:
- Output: A joint view of multiple tables stitched together using a common “key”. 
- Use Case: Fully stitch tables together and have full flexibility on what to “select” and “filter from”. 
- Dependencies: Cannot stand independently. (There's an exception for correlated nested or inline queries.)

### Placement and Dependencies
Placement:
There are four places where subqueries can be inserted within a larger query:
- With - This subquery is used when you’d like to “pseudo-create” a table from an existing table and visually scope the temporary table at the top of the larger query. For example,
```sql
WITH subquery_name (column_name1, ...) AS
 (SELECT ...)
SELECT ...
```

- Nested - This subquery is used when you’d like the temporary table to act as a filter within the larger query, which implies that it often sits within the where clause. For example,
```sql
SELECT s.s_id, s.s_name, g.final_grade
FROM student s, grades g
WHERE s.s_id = g.s_id
IN (SELECT final_grade FROM grades g WHERE final_grade > 3.7);
```

- Inline - Similar to the with case, but instead of the temporary table sitting on top of the larger query, it’s embedded within the from clause. For example,
```sql
SELECT student_name
FROM
  (SELECT student_id, student_name, grade
   FROM student
   WHERE teacher =10)
WHERE grade >80;
```

- Scalar - This subquery is used when you’d like to generate a scalar value to be used as a benchmark of some sort.
```sql
SELECT s.student_name
  (SELECT AVG(final_score)
   FROM grades g
   WHERE g.student_id = s.student_id) AS
     avg_score
FROM student s;
```

With and Nested subqueries are most advantageous for readability.

Scalar subqueries are advantageous for performance and are often used on smaller datasets.

Dependencies:
A subquery can be dependent on the outer query or independent of the outer query.

(This is the article that the instructor recommends: [Microsoft's Article on Subqueries](https://learn.microsoft.com/en-us/sql/relational-databases/performance/subqueries?view=sql-server-ver15) Note: I'm not sure how applicaable material from this MS article is to standard SQL or PostgreSQL.)

### Our First Subquery

Problem:  On an average day, which channels send the most traffic to Parch and Posey?

So, we already know how to see how much total web traffic each channel sends. 
```sql
select channel, count(*) as event_count
from web_events
group by 1
```

We can also break this down a little further to the total traffic sent to each channel per day.
```sql
select channel, count(*) as event_count, date_trunc('day', occurred_at) as the_day
from web_events
group by 1, 3
order by 1, 3
```

But if we want to see the average number of events per channel per day, then we have to use a subquery, specifically an inline query, which means that the subquery will appear in the FROM clause.

We want something like this:
```sql
select channel, avg(event_count) as avg_event_count
from ...
group by channel
order by avg_event_count desc
```

But how do we get event_count? That's where the subquery comes in.
```sql
select channel, avg(event_count) as avg_event_count
from (select 
        channel,
        count(*) as event_count, /* Here it is */
        date_trunc('day', occurred_at) as day
      from web_events
      group by 1, 3) as my_subquery
group by 1
order by 2 desc
```
As you can see, the second query we tried is now the subquery in the solution. That subquery gave us the correct number of total events per day for each channel.

Put another way, in order to get our average, we needed a table that looked like this:

| "channel"  | "event_count" | "day"                 |
|------------|---------------|-----------------------|
| "twitter"  | 1             | "2016-05-30 00:00:00" |
| "adwords"  | 1             | "2016-05-28 00:00:00" |
| "banner"   | 3             | "2016-05-04 00:00:00" |
| "twitter"  | 1             | "2016-08-26 00:00:00" |
| "adwords"  | 1             | "2016-10-25 00:00:00" |
| "organic"  | 1             | "2016-08-24 00:00:00" |
| "facebook" | 2             | "2016-09-04 00:00:00" |

And that's what the subquery gave us. With this query, we can now get an average for the event_count column per channel.

### Steps when building a subquery:
1. Build the Subquery: The aggregation of an existing table that you’d like to leverage as a part of the larger query.
2. Run the Subquery: Because a subquery can stand independently, it’s important to run its content first to get a sense of whether this aggregation is the interim output you are expecting.
3. Encapsulate and Name: Close this subquery off with parentheses and call it something. In this case, we called the subquery table ‘sub.’
4. Test Again: Run a SELECT * within the larger query to determine if all syntax of the subquery is good to go.
5. Build Outer Query: Develop the SELECT * clause as you see fit to solve the problem at hand, leveraging the subquery appropriately.

### Subquery Formatting
A subquery can appear in several different places within a query. In the above example, we saw a subquery in the FROM clause. That's called an **inline** query. But subqueries can appear in many other places. Another place a subquery can appear is in a WHERE clause. When it does, that's called a **nested** subquery.

NOTE: Do not include an alias for your subquery when you write a subquery in a conditional statement. This is because the subquery is treated as an individual value (or set of values in the IN case) rather than as a table. Nested and Scalar subqueries often do not require aliases the way With and Inline subqueries do.

### Problem: Return orders that occurred in the same month as Parch and Posey's first ever order.

To solve this problem we need a query that looks like this:
```sql
select * 
from orders
where date_trunc('month', occurred_at) = /*month of first ever order order*/
```
However, there's no way to get the month of the first ever order without using a subquery.

To get the month of the first ever order we need this:
```sql
select date_trunc('month', min(occurred_at)) as min_month
from orders
```
When you put it together, it looks like this:
```sql
select * 
from orders
where date_trunc('month', occurred_at) = (select date_trunc('month', min(occurred_at)) as min_month
from orders)
order by occurred_at
```
Why do we have to use a subquery here rather than just inserting the min function into the WHERE clause? Because we can't use aggregations in a WHERE clause. Well, then why can't we use a HAVING clause? I have no idea, but I tried it and it various ways and it doesn't work.

### Problem: Return the average quantities of each type of paper sold in the same month identified in the previous problem.

```sql
SELECT AVG(standard_qty) avg_std, AVG(gloss_qty) avg_gls, AVG(poster_qty) avg_pst
FROM orders
WHERE DATE_TRUNC('month', occurred_at) = 
     (SELECT DATE_TRUNC('month', MIN(occurred_at)) FROM orders);
```
The FROM and WHERE clauses are identical to the ones in the previous problem. What's changed is the SELECT clause. We just need to get the average for each of the paper quantities.

### Problem: Return the total amount spent on all orders in the same month identified in the previous problem.

```sql
select sum(total_amt_usd)
from orders
where date_trunc('month', occurred_at) = (select date_trunc('month', min(occurred_at)) as min_month
from orders)
```
Again, the FROM and WHERE clauses are identical to the previous problem. What's changed is the SELECT clause. We just need to get the sum of the total amount of money spent.

### Dependencies: Simple versus Correlated Subqueries
**Simple Subquery**: The inner subquery is completely independent of the larger query.

**Correlated Subquery**: The inner subquery is dependent on the larger query. 

Correlated subqueries are used for row-by-row processing. Each subquery is executed once for every row of the outer query. 

With a normal nested subquery, the inner SELECT query runs first and executes once, returning values to be used by the main query. A correlated subquery, however, executes once for each candidate row considered by the outer query. In other words, the inner query is driven by the outer query. 

A correlated subquery is one way of reading every row in a table and comparing values in each row against related data.  It is used whenever a subquery must return a different result or set of results for each candidate row considered by the main query.

Here's the general form of a correlated subquery:
```sql
SELECT column1, column2, ....
FROM table1 outer
WHERE column1 operator
                    (SELECT column1, column2
                     FROM table2
                     WHERE expr1 = outer.expr2);
```

Simple subqueries are easier to read. However, some problems require that you use a correlated subquery. 

Other subqueries could be written either way: as a simple subquery or as a correlated subquery. The lesson provides an example using an employee database.

First, here's the simple subquery version:
```sql
WITH dept_average AS 
  (SELECT dept, AVG(salary) AS avg_dept_salary
   FROM employee
   GROUP BY employee.dept
  )
SELECT E.eid, E.ename, D.avg_dept_salary
FROM employee E
JOIN dept.average D
ON E.dept = D.dept
WHERE E.salary > D.avg_dept_salary
```
And here's the correlated subquery version:
```sql
SELECT employee_id, name
FROM employees_db emp
WHERE salary > (SELECT AVG(salary)
                FROM employees_db
                WHERE department = emp.department);
```

Here's another example. Imagine that you want to get the first and last name of each student, their GPA, and the university that they attend from a database. However, you only want students whose GPA is higher than the average GPA of all students at that particular university. In other words, if you're looking at a student from Ohio State University, you want to know that this student has a higher GPA than the average OSU student.

To do this, you'll need a subquery in which you calculate the average GPA
```sql
SELECT first_name, last_name, GPA, university
FROM student_db outer_db
WHERE GPA > (SELECT AVG(GPA) 
            FROM student_db 
            WHERE university = outer_db.university);
```

### Views
Assume you run a complex query to fetch data from multiple tables. Now, you’d like to query again on the top of the result set. And later, you’d like to query more on the same result set returned earlier. So, there arises a need to store the result set of the original query, so that you can re-query it multiple times. This necessity can be fulfilled with the help of views.

Views are virtual tables that are derived from the tables in the db.

The general form is:
```sql
CREATE VIEW <VIEW_NAME>
AS
SELECT …
FROM …
WHERE …
```
### Problem: Suppose you are managing sales representatives who are looking after the accounts in the Northeast region only. The details of such a subset of sales representatives can be fetched from two tables, and stored as a view:
```sql
create view v1
as
select S.id, S.name as Rep_Name, R.name as Region_Name
from sales_reps S
join region R
/*FYI to myself - I completely forgot that you can do this */
on S.region_id = R.id and R.name = 'Northeast';
```
### Problem: Provide the name for each region for every order, as well as the account name and the unit price they paid (total_amt_usd/total) for the order. Your final result should have 3 columns: region name, account name, and unit price. Store this as a view.
```sql
CREATE VIEW V2
AS
SELECT r.name region, a.name account, 
       o.total_amt_usd/(o.total + 0.01) unit_price
FROM region r
JOIN sales_reps s
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id;
```
Points to Remember

Can we update the base tables by updating a view?

Since views do not exist physically in the database, it is may or may not be possible to execute UPDATE operations on views. It depends on the SELECT query used in the view definition. Generally, if the SELECT statement contains either an AGGREGATE function, GROUPING, or JOIN, then the view may not update the underlying base tables.

Can we insert or delete a tuple in the base table by inserting or deleting a tuple in a view?

Again, it depends on the view definition. If a view is created from a single base table, then yes, you can insert/delete tuples by doing so in the view.

Can we alter the view definition?

Most of the databases allow you to alter a view. For example, Oracle and IBM DB2 allows us to alter views and provides CREATE OR REPLACE VIEW option to redefine a view.

### Problem: What is the top channel used by each account to market products?
First, I get all channels per account name with a count of the channel, like this:
```sql
select a.name as name, channel as channel, count(channel) as channel_count
from web_events we
join accounts a
on we.account_id = a.id
group by 1, 2
order by 1, 3
```
But what I need is not all of the channels for each account, but just the top channel - the channel with the largest count. So, I sort of want this max(count(channel)). You can't do that. You can't aggregate on an aggregation.

Do I need to isolate this part?
```sql
select count(channel) as channel_count from web_events
```
So that I can do this:
```sql
select a.name, we.channel, max(sub.channel_count)
```
It turns out, no. I actually want almost the entire query to be in the subquery, so that the outer query just grabs a couple of things from the subquery, and most importantly, applies max(sub.channel_count). It looks like this:
```sql
select sub.name, max(sub.channel_count)
from (
  select a.name as name, channel as channel, count(channel) as channel_count
  from web_events we
  join accounts a
  on we.account_id = a.id
  group by 1
  order by 1, 3
) as sub
group by 1

```
One of the things that tripped me up is that I wanted the channel name to be in the query. You can't do that without adding another subquery, because if you add sub.channel to the SELECT clause in the outer query, then you have to add it to the GROUP BY clause, which messes things up and just ends up giving you as a result the subquery again. I don't really get why that is, but that's what happened when I tried it.

Problem: How often was the same channel used?
So now we have the MAX usage number for a channel for each account. Now we can use this to filter the original table to find channels for each account that match the MAX amount for their account.

This is what it looks like:
```sql
/* In the end we want to end up with a table of id, name, the most frequently used channel, and the count of that channel */
SELECT t3.id, t3.name, t3.channel, t3.ct
/* This subquery provides a table with the id, name, all channels, and the count for each channel, aliased as ct */
FROM (SELECT a.id, a.name, we.channel, COUNT(*) ct
     FROM accounts a
     /* To get account names, we need to join the accounts table with the web_events table. The order doesn't matter. You can select from web_events and then join accounts or select from accounts and then join web_events. */
     JOIN web_events we
     On a.id = we.account_id
     /* To group by name and channel type, we need to GROUP BY right here. This tells the db how we want to split up the channel count. */
     GROUP BY a.id, a.name, we.channel) t3
/* Now we have to JOIN another subquery that provides a table of the id, name, and the MAX count as max_chan. This subquery doesn't provide the channel name.  */
JOIN (
  SELECT t1.id, t1.name, MAX(ct) max_chan
  /* The query above is created using the same subquery that we earlier aliased as t3. But we have to repeat it here and alias it as t1. */
  FROM (
    SELECT a.id, a.name, we.channel, COUNT(*) ct
    FROM accounts a
    JOIN web_events we
    ON a.id = we.account_id
    GROUP BY a.id, a.name, we.channel
    ) t1
  /* This time we just group by id and name */
  GROUP BY t1.id, t1.name
) t2
/* We join our two queries on the id key and also on the condition that max_chan from t2 is equal to ct from t3. That condition is what allows us to see the channel name and the max count.*/
ON t2.id = t3.id AND t2.max_chan = t3.ct
ORDER BY t3.id;
```
This is pretty long. I'm sure there's a way to reuse t3/t1, maybe with a with clause or a view.

One more time, but factoring out the t3/t1 subquery
```sql
SELECT t3.id, t3.name, t3.channel, t3.ct
FROM t3
JOIN (SELECT t1.id, t1.name, MAX(ct) max_chan
      FROM t1
      GROUP BY t1.id, t1.name) t2
ON t2.id = t3.id AND t2.max_chan = t3.ct
ORDER BY t3.id;
```
This makes it a little bit clearer to me. 

### Problems from section 4.17 and their solutions

1. Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.

Rephrase: There's one sales rep in each region who has the largest total sales in that region, beating all other sales reps in that region. Get the name of that person for each region.
```sql
/* First, get sales reps names and regions and total sales per sales rep. Order it by region and total sales (desc) to see who in each region has the best sales. */

/*
select sr.id as sr_id, sr.name as sr_name, r.name as reg_name, sum(o.total_amt_usd) as total_sales
from sales_reps sr
join region r
on sr.region_id = r.id
join accounts a
on a.sales_rep_id = sr.id
join orders o
on o.account_id = a.id
group by 1,2,3
order by reg_name, total_sales desc
*/

/* Next, get the max total sales per region */
/*
select sub.reg_name, max(sub.total_sales) as max_sales
from (select sr.id as sr_id, sr.name as sr_name, r.name as reg_name, sum(o.total_amt_usd) as total_sales
	from sales_reps sr
	join region r
	on sr.region_id = r.id
	join accounts a
	on a.sales_rep_id = sr.id
	join orders o
	on o.account_id = a.id
	group by 1,2,3
	order by reg_name, total_sales desc) as sub
group by 1
order by 1
*/

/* Finally, join the above to queries to get the sales rep name from the first query and the region and max total sales from the second query. I'm joining on the region name from each query, because that's the only thing they have in common, but maybe I should have used region id. */
select sub1.sr_name, sub2.reg_name, sub2.max_sales
from (
      select sr.id as sr_id, 
              sr.name as sr_name, 
              r.name as reg_name, 
              sum(o.total_amt_usd) as total_sales
      from sales_reps sr
      join region r
      on sr.region_id = r.id
      join accounts a
      on a.sales_rep_id = sr.id
      join orders o
      on o.account_id = a.id
      group by 1,2,3
      ) as sub1
join (
      select sub.reg_name, 
             max(sub.total_sales) as max_sales
      from (
            select sr.id as sr_id, 
                  sr.name as sr_name, 
                  r.name as reg_name, 
                  sum(o.total_amt_usd) as total_sales
            from sales_reps sr
            join region r
            on sr.region_id = r.id
            join accounts a
            on a.sales_rep_id = sr.id
            join orders o
            on o.account_id = a.id
            group by 1,2,3
            ) as sub
      group by 1
    ) as sub2
on sub1.reg_name = sub2.reg_name
and sub1.total_sales = sub2.max_sales

```

2. For the region with the largest (sum) of sales total_amt_usd, how many total (count) orders were placed?

Rephrase: How many orders have been placed in the top selling region? Sounds like they just want a number.
- Which is the top selling region?
- How many orders have been placed in that region?

You can see the top performing Northeast in the table resulting from this query:
```sql
select r.name as region_name, count(*) as total_orders, sum(total_amt_usd) as total_sales
from orders o
join accounts a
on o.account_id = a.id
join sales_reps sr
on a.sales_rep_id = sr.id
join region r
on sr.region_id = r.id
group by 1
```
But how do we return just the number of orders for the Northeast? The simple solution is to use ORDER BY and LIMIT to return just the Northeast from the query above. However, that's not in the spirit of practicing our subquery skills.

This was very difficult for me. I thought we could do something similar to what we did in problem 1 and join the above query with a second query shown below that returns the max(sub.total_sales):
```sql
select max(sub.total_sales) as max_sales
from (
  select r.name as region_name, 
         sum(total_amt_usd) as total_sales
  from orders o
  join accounts a
  on o.account_id = a.id
  join sales_reps sr
  on a.sales_rep_id = sr.id
  join region r
  on sr.region_id = r.id
  group by 1
) as sub
group by 1
```
The join would look like this:
```sql
select sub1.region_name, sub1.total_orders
from (
  select r.name as region_name, 
         count(*) as total_orders, 
         sum(total_amt_usd) as total_sales
  from orders o
  join accounts a
  on o.account_id = a.id
  join sales_reps sr
  on a.sales_rep_id = sr.id
  join region r
  on sr.region_id = r.id
  group by 1
  ) as sub1
join (
    select max(sub.total_sales) as max_sales
    from (
        select r.name as region_name,  
               sum(total_amt_usd) as total_sales
        from orders o
        join accounts a
        on o.account_id = a.id
        join sales_reps sr
        on a.sales_rep_id = sr.id
        join region r
        on sr.region_id = r.id
        group by 1
    ) as sub
) as sub2
on sub1.total_sales = sub2.max_sales
```
It works! The thing that threw me was that in the ON clause you need to specify that you only want to join on the condition that the total_sales from "sub1" is equal to the max_sales from "sub2" even though you're not displaying total or max sales. 

The suggested solution is different. That solution uses a HAVING clause:
```sql
SELECT r.name as region_name, COUNT(o.total) total_orders
FROM sales_reps sr
JOIN accounts a
ON a.sales_rep_id = sr.id
JOIN orders o
ON o.account_id = a.id
JOIN region r
ON r.id = sr.region_id
GROUP BY 1
HAVING SUM(o.total_amt_usd) = (
      SELECT MAX(total_amt)
      FROM (SELECT r.name region_name, 
                   SUM(o.total_amt_usd) total_amt
              FROM sales_reps s
              JOIN accounts a
              ON a.sales_rep_id = s.id
              JOIN orders o
              ON o.account_id = a.id
              JOIN region r
              ON r.id = s.region_id
              GROUP BY r.name) sub);
```
Here, we're getting the total_orders by region, but then we're using the HAVING clause to filter that down to just the region with the highest total sales. We need a subquery to do that.

3. How many accounts had more total purchases than the account name which has bought the most standard_qty paper throughout their lifetime as a customer?

Rephrase: How many accounts has total purchases that were greater than the account with the most standard paper purchased? 
- Which account purchased the most standard paper
- Which accounts purchased more paper (of all types) than the answer to the previous question

We can write a query to get account names and the sum of the total quantities of all types of paper purchased, grouped by account. When I was working on this, I also threw in the sum of standard paper bought. That way, I can check my work. That's the outer query.

Then, in the HAVING clause, we need to filter down to accounts that have bought more total paper of all types than the the quantity of standard paper bought by the account that bought the most standard paper out of all accounts. This is confusing. What we're ultimately looking for is a list of accounts, but what we're comparing here is two quantities. On the left-hand side of the comparison operator we need the sum quantity of all types of paper. On the right-hand side we need the quantity of standard paper purchased by the account that purchased the most standard paper by quantity. That requires a subquery. That subquery forms the right-hand side of the equality in the HAVING clause below. It took me a moment to realize that we can just select max(sub.total_standard). We don't have to worry about including account names. Account names are included in the sub-subquery (called "sub"), and in "sub" we group by those account names. So, when the MAX function does its work, it's getting us the right thing.
```sql
select a.name, 
       sum(o.total) as total_all_types, 
       sum(o.standard_qty) as total_standard
from accounts a
join orders o
on o.account_id = a.id
group by 1
having sum(o.total) > (select max(sub.total_standard) 
					   from (select a.name, sum(o.standard_qty) as total_standard 
							 from orders o
							 join accounts a
							 on o.account_id = a.id
							 group by 1
							) as sub
					  )
order by 3 desc
```

4. For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd, how many web_events did they have for each channel?

Rephrase: How many web events per channel did the customer who spent the most money over their customer lifetime have?

After a lot of messing around and trying out different things, I eventually figured out that I needed to use a subquery to get just the name of the company that spent the most on paper and use that subquery on the right-hand side of a HAVING clause with an equality operator. On the left-hand side is the name of the company. The outer query just need to get the events per channel per company.
```sql
/* web events per channel per company */
select 
  a.name as account_name,
  we.channel as channel,
  count(*) as count
from web_events we
join accounts a
on we.account_id = a.id
join orders o
on o.account_id = a.id
group by 1, 2
having a.name = (
	select 
		sub.account_name from (select a.name as account_name, 
		sum(o.total_amt_usd) as total_spent
  from accounts a
	join orders o
	on o.account_id = a.id
	group by 1
	order by 2 desc
	limit 1) as sub
);
```

5. What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?
```sql

```

6. What is the lifetime average amount spent in terms of total_amt_usd, including only the companies that spent more per order, on average, than the average of all orders?
```sql

```