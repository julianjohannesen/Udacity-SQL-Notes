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
/* I had an extra join here at first and it messes everything up */
-- join orders o
-- on o.account_id = a.id
group by 1, 2
having a.name = (
	select 
		sub.account_name 
    from (
      select 
        a.name as account_name, 
		    sum(o.total_amt_usd) as total_spent
      from accounts a
	  join orders o
	  on o.account_id = a.id
	  group by 1
	  order by 2 desc
	  limit 1) as sub
);
```
Except that this is not the answer given in the lesson. The answer given in the lesson is a bit different.
```sql
SELECT 
  a.name, 
  w.channel, 
  COUNT(*)
FROM accounts a
JOIN web_events w
ON a.id = w.account_id 
AND a.id =  (
  SELECT id
  FROM (
    SELECT 
      a.id, 
      a.name, 
      SUM(o.total_amt_usd) tot_spent
    FROM orders o
    JOIN accounts a
    ON a.id = o.account_id
    GROUP BY a.id, a.name
    ORDER BY 3 DESC
    LIMIT 1) inner_table)
GROUP BY 1, 2
ORDER BY 3 DESC;
```
Let's annotate that to see if I can figure out what they did.
```sql
/* Begin by getting the customer name, channels, and count of web events for each channel */
SELECT 
  a.name, 
  w.channel, 
  COUNT(*)
FROM accounts a
JOIN web_events w
/* The accounts and web_events tables have to be joined on a.id and w.account_id */
ON a.id = w.account_id 
/* And also on a.id and ... */
AND a.id =  (
  /* ...the account id ... */
  SELECT id
  /* ...pulled from the inner_table. That inner_table gets...  */
  FROM (
    /* ... account id and name and total spent */
    SELECT 
      a.id, 
      a.name, 
      SUM(o.total_amt_usd) tot_spent
    FROM orders o
    JOIN accounts a
    ON a.id = o.account_id
    /* grouped by account id and name. This ensures that the spending is broken out by account */
    GROUP BY a.id, a.name
    /* ordered by tot_spent descending */
    ORDER BY 3 DESC
    /* and get just the top spender */
    LIMIT 1) inner_table)
/* The outer query is grouped by account name and web channel */
GROUP BY 1, 2
ORDER BY 3 DESC;
```

5. What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?

Rephrase: Get the average amount spent by the top 10 accounts in terms of lifetime spending.

I know I'll need a subquery for the top 10 accounts in terms of total spending, so here it is:
```sql
select a.name as account_name, sum(o.total_amt_usd) as total_spending
from accounts a
join orders o
on o.account_id = a.id
group by 1
order by 2 desc
limit 10
```
Then the outer query would just be the select statement and the subquery would go in the FROM clause:
```sql
select avg(sub.total_spending)
from (
	select 
		a.name as account_name, 
		sum(o.total_amt_usd) as total_spending
	from accounts a
	join orders o
	on o.account_id = a.id
	group by 1
	order by 2 desc
	limit 10
) as sub;
```

6. What is the lifetime average amount spent in terms of total_amt_usd, including only the companies that spent more per order, on average, than the average of all orders?

Rephrase: On average, what did the customers who spent more than the average spending of all customers spend?
- What was the average spending among all customers?
- What was the average spending of customers who spent more than that?

Start with the subquery about the average spending of all customers
```sql
select avg(o.total_amt_usd)
from orders o
```
Now use that subquery in an outer query that gets all of the accounts that spent more than the average and what that average is.
```sql
SELECT o.account_id, AVG(o.total_amt_usd)
FROM orders o
GROUP BY 1
HAVING AVG(o.total_amt_usd) > 
  /* average spending per customer over lifetime */
  (
    SELECT AVG(o.total_amt_usd) avg_all
    FROM orders o
  );
```
Now average the spending by just those accounts.
```sql
-- Get average spending of the average spending of a subset of accounts 
SELECT AVG(avg_amt)
/* Get account ids and average spending per account id, but filtering down to just those account ids HAVING average spending greater than the overall average spending by all accounts */
FROM (
  SELECT 
    o.account_id, 
    AVG(o.total_amt_usd) avg_amt
  FROM orders o
  -- We want average spending per account
  GROUP BY 1
  -- We want to filter down to...
  HAVING 
    -- Average spending greater than...
    AVG(o.total_amt_usd) > (
      /* Overall, average spending, i.e. sum of all spending divided by the total number of accounts */
      SELECT 
        AVG(o.total_amt_usd) avg_all
      FROM orders o
    )
) sub;
```

### Subquery Tradeoffs

Most queries can be solved in a wide variety of ways, so, when writing a query, it's important to consider:
- Readability: How easy is it for someone else to understand
- Performance: How quickly is it executed
    - Example: Correlated subqueries (which are interdependent on outer query) are often slower than "with" subqueries (which create a temporary view)
- What the DB is actually doing: 
- DRYness: Where you might need to use a subquery multiple times

See Chapter 8 of the MySQL Reference Manual for more information on optimization: https://dev.mysql.com/doc/refman/8.0/en/optimization.html

(Sure. I'll get on that right away. Let me just run an read all of the books written about SQL instead of you explaining it to me. /endcomplaint)

### Subquery Strategy

1. Do I really a subquery or might a join or aggregation suffice?
2. If a subquery is necessary, what's the best placement: "with", nested, inline, or scalar?

### With Subqueries

When should you use it:
- When you want to create a version of a table to be used in the larger query (e.g. aggregated daily prices to an average price table)

Advantages:
- Scoped
- Easy to read

Here's an example:
```sql
WITH average_price as
( 
  SELECT 
    brand_id, 
    AVG(product_price) as brand_avg_price
  FROM 
    product_records
  /* Why is there no group by statement here? Should we see GROUP BY brand_id? */
),
SELECT 
  a.brand_id, 
  a.total_brand_sales, 
  b.brand_avg_price
FROM brand_table a
JOIN average_price b
ON b.brand_id = a.brand_id
ORDER BY a.total_brand_sales desc;
```

**CTE** stands for Common Table Expression. A Common Table Expression in SQL allows you to define a temporary result, such as a table, to then be referenced in a later part of the query.

Problem: Get average events per channel per day.

Solution with nested query:
```sql
SELECT 
  channel, 
  AVG(events) AS average_events
FROM (
  SELECT 
    DATE_TRUNC('day',occurred_at) AS day,
    channel, 
    COUNT(*) as events
  FROM web_events 
  GROUP BY 1,2
) sub
GROUP BY channel
ORDER BY 2 DESC;
```
Solution with WITH clause:
```sql
WITH events AS (
  SELECT 
    DATE_TRUNC('day',occurred_at) AS day, 
    channel,
    /* In the outer query, we use events to get avg(events) */ 
    COUNT(*) as events
  FROM web_events 
  GROUP BY 1,2
)
SELECT 
  channel, 
  AVG(events) AS average_events
/* Notice that the CTE "events" has the same name as the column "events" and it doesn't seem to matter. */
/* Also, you don't refer in the SELECT statement to events.events, because there aren't any other tables. Just "events" is enough. */
/* Also notice that you aren't JOINing your subquery with web_events. You're just using the subquery as the FROM table*/
FROM events
GROUP BY channel
ORDER BY 2 DESC;
```

It's also possible to create multiple tables with WITH:
```sql
WITH table1 AS (
          SELECT *
          FROM web_events),

     table2 AS (
          SELECT *
          FROM accounts)


SELECT *
FROM table1
JOIN table2
ON table1.account_id = table2.id;
```

### WITH Problems

1. Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.

Rephrase: Who in each region got the most sales for all time?
  - Each region has a sales rep who performed better than other sales reps in terms of total sales in that region
  - In each region
    - A sales rep performed better 
      - than other reps
        - In that region

```sql
WITH 
  t1 AS (
    /* Get total sales by reps by region */
    SELECT 
      s.name rep_name, 
      r.name region_name, 
      SUM(o.total_amt_usd) total_amt
    FROM sales_reps s
    JOIN accounts a
    ON a.sales_rep_id = s.id
    JOIN orders o
    ON o.account_id = a.id
    JOIN region r
    ON r.id = s.region_id
    GROUP BY 1,2
    ORDER BY 3 DESC), 
  t2 AS (
    /* Get max sales by region */
    SELECT 
      region_name, 
      MAX(total_amt) total_amt
    FROM t1
    GROUP BY 1)
/* Get rep, region, and total sales */
SELECT t1.rep_name, t1.region_name, t1.total_amt
FROM t1
JOIN t2
/* Join the two tables only when the region matches and */
ON t1.region_name = t2.region_name 
  /* the total sales is equal to the max sales (which will only be true for one sales rep in each region */
  AND t1.total_amt = t2.total_amt;

```
2. For the region with the largest sales total_amt_usd, how many total orders were placed?

My solution is slightly different from the suggested solution. I'm only joining on the total sales equaling the max total sales. I think this might create a problem when 2 or more regions are tied for total or max total sales. I'm basically using the ON clause as though it was a HAVING clause. It's a bit simpler to read, because the outer query is very straightforward.
```sql
with 
  t1 as (
    -- Get the total sales and total orders by region
    select 
      r.name region_name, 
      sum(o.total_amt_usd) total_amt,
      count(o.id) as order_count
    from region r
    join sales_reps sr
    on sr.region_id = r.id
    join accounts a
    on a.sales_rep_id = sr.id
    join orders o
    on o.account_id = a.id
    group by 1
  ),
  t2 as ( 
    -- Get the highest total sales figure
    select max(total_amt) max_total
    from t1
  )
-- Get the total sales by region
select 
  region_name,
  order_count
from t1
join t2
-- Filter to the one region that has the highest total sales
on t1.total_amt = t2.max_total
```

This is the suggested solution below. 
```sql
WITH t1 AS (
   SELECT r.name region_name, SUM(o.total_amt_usd) total_amt
   FROM sales_reps s
   JOIN accounts a
   ON a.sales_rep_id = s.id
   JOIN orders o
   ON o.account_id = a.id
   JOIN region r
   ON r.id = s.region_id
   GROUP BY r.name), 
t2 AS (
   SELECT MAX(total_amt)
   FROM t1)
SELECT r.name, COUNT(o.total) total_orders
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
JOIN region r
ON r.id = s.region_id
GROUP BY r.name
HAVING SUM(o.total_amt_usd) = (SELECT * FROM t2);
```
In this solution, t1 only gets region name and total sales. It doesn't get a count of orders. T2 is identical to my t2. Then, in the outer query, this solution gets the region name and the count of orders. That means we have to go through the sequence of joins again, but we never join tables t1 or t2. Instead, we get total orders by region name and then use a HAVING clause to tell the query to filter down sum(total_amt_usd) = (select * from t2). This is interesting, because the outer query is no dependent on t1 directly at any point, only on t2 in the HAVING clause.

3. How many accounts had more total purchases than the account name which has bought the most standard_qty paper throughout their lifetime as a customer?

Rephrase: In the end we just want a number - the number of accounts that meet a certain condition. The condition is having total purchases of any type of paper (in terms I think of quantity, not spending) greater than another account. That other account is the account that has bought the most standard paper over its lifetime. So, the way I read it is that we'll have to compare how much (of any type of paper) was purchased by a bunch of accounts to how much (just standard paper) was purchased by this other account, and filter out the ones that bought less. At least two people have told me that I'm misreading this and that the comparison should be between total quantities.

```sql
with 
  t1 as (
    select
      a.id a_id,
      a.name account_name,
      sum(o.standard_qty) total_qty_standard,
      sum(o.standard_qty) + sum(o.gloss_qty) + sum(o.poster_qty) as total_qty_all
    from accounts a
    join orders o
    on o.account_id = a.id
    group by 1,2
  ),
  t2 as (
    select max(total_qty_standard) max_total
    from t1
  )
-- What they want is a number here, but I'm going to list out the accounts and the quantities of paper. It would be easy to just do a count of the names.
select
  account_name,
  total_qty_all
from t1
join t2
on t1.total_qty_all > t2.max_total
```
Once again, the suggested answer is a bit different. In my solution, I create two subqueries and JOIN them in the outer query with an ON clause that contains the condition. Event though it provides the correct answer, I think mine is probably wrong, but it's very readable to me, which is why I like it. 

Anyway, the suggested solution uses t1 to get the account with the greatest purchase quantity of standard paper, along with that figure and also the figure for total purchases. It uses t2 to get the account names of the accounts HAVING sum(o.total) > (select total from t1). Then in the outer query, it gets the count of those accounts to give the answer.

```sql
WITH 
  t1 AS (
	-- this query gets the one account with the greatest quantity of standard paper purchased, and also the total paper it purchased
    SELECT 
      a.name account_name, 
      SUM(o.standard_qty) total_std, 
      SUM(o.total) total -- woops, forgot this existed
    FROM accounts a
    JOIN orders o
    ON o.account_id = a.id
    GROUP BY 1
    -- get rid of the whole max() part
    ORDER BY 2 DESC
    LIMIT 1
  ), 
  t2 AS (
	-- this query gets accounts for which total quantity of all paper types purchased is greater than t1.total_std
    SELECT a.name
    FROM orders o
    JOIN accounts a
    ON a.id = o.account_id
    GROUP BY 1
    HAVING SUM(o.total) > (SELECT total_std FROM t1)
  )
-- Finally, the outer query gets a count of accounts in t2
SELECT COUNT(*)
FROM t2;
```

**PLEASE NOTE**: The suggested solution compares total quantites of all types of paper, thus inn the course materials the HAVING clause uses "total" instead of "total_std". This results in an answer of 3. I interpreted the question to be asking us to compare total quantity to only standard quantity. The correct answer in that case is 6.

4. For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd, how many web_events did they have for each channel?
```sql
WITH t1 AS (
   -- Get the id and name for the top spending account
   SELECT 
    a.id, 
    a.name, 
    SUM(o.total_amt_usd) tot_spent
   FROM orders o
   JOIN accounts a
   ON a.id = o.account_id
   GROUP BY 1, 2
   ORDER BY 3 DESC
   LIMIT 1
   )
-- Get the name, channels, and event count for all accounts
SELECT 
  a.name, 
  w.channel, 
  COUNT(*)
FROM accounts a
JOIN web_events w
-- I was so close! Join on id and to filter down also join on id from t1
ON a.id = w.account_id AND a.id =  (SELECT id FROM t1)
GROUP BY 1, 2
ORDER BY 3 DESC;
```
5. What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?

I think the course materials had the wrong answer for this one. Their answer just returns a single average. Mine returns the top 10.
```sql
with 
  t1 as (
    select
      a.name account_name,
      sum(o.total_amt_usd) total_spent
    from accounts a
    join orders o
    on o.account_id = a.id
    group by 1
)
select 
  account_name, 
  avg(total_spent)
from t1
group by 1
order by 2 desc
limit 10
```
6. What is the lifetime average amount spent in terms of total_amt_usd, including only the companies that spent more per order, on average, than the average of all orders.

Rephase: What was the average amount spend by companies that spent more per order than the average spending on an order overall
  - Need average cost of orders

```sql
WITH 
  t1 AS (
    -- Get the average spending per order, overall
    SELECT 
      AVG(total_amt_usd) avg_all
    FROM orders),
  t2 AS (
    -- Get the average spending per order, grouped by account
    SELECT 
      account_id, 
      AVG(total_amt_usd) avg_amt
    FROM orders
    GROUP BY 1
    -- only include accounts for which their average spending per order is greater than overall spending per order
    HAVING AVG(total_amt_usd) > (SELECT * FROM t1))
-- Get the average of the averages but only for the accounts that passed the condition in t2
SELECT AVG(avg_amt)
FROM t2;
```

### Nested Subqueries

A nested subquery is a subquery placed in the WHERE clause of another query. They're useful when a user wants to filter output using a condition met from another table.

Here's an example:
```sql
SELECT *
FROM students
WHERE student_id
IN (
    SELECT DISTINCT student_id
    FROM gpa_table
    WHERE gpa>3.5
   );
```

### Inline Subqueries

An inline subquery is a subquery placed in the FROM clause of another query. They're useful when a user needs a pseduo table to aggregate or manipulate an existing table within a larger query. They're similar to WITH clauses, but not as helpful for readability.

Here's an example:
```sql
SELECT 
  dept_name,
  max_gpa
FROM 
  department_db x,
  (
    SELECT 
      dept_id
      MAX(gpa) as max_gpa
    FROM students
    GROUP BY dept_id
  ) y
WHERE x.dept_id = y.dept_id
ORDER BY 1;
```

### Scalar Subqueries

A scalar subquery is placed in the SELECT clause of another query. They're useful when you want to return on column and one row from a query. They're performant and also useful when the data set is small. If a scalar subquery does not find a match, it returns NULL. If a scalar subquery finds multiple matches, it returns an error.

Here's an example:
```sql
SELECT 
  (SELECT MAX(salary) FROM employees_db) AS top_salary,
  employee_name
FROM employees_db;
```

### Conclusion

Subquery Facts to Know:
- Commonly used as a filter/aggregation tool
- Commonly used to create a “temporary” view that can be queried off
- Commonly used to increase readability
- Can stand independently

### Lesson 4 Key Terms

- Correlated - Subquery	The inner subquery is dependent on the larger query.
- CTE	- Common Table Expression in SQL allows you to define a temporary result, such as a table, to then be referenced in a later part of the query.
- Inline	- This subquery is used in the same fashion as the WITH use case above. However, instead of the temporary table sitting on top of the larger query, it’s embedded within the from clause.
- Joins Dependencies - Cannot stand independently.
Joins Output	A joint view of multiple tables stitched together using a common “key”.
- Joins Use Case	- Fully stitch tables together and have full flexibility on what to “select” and “filter from”.
- Nested	This subquery is used when you’d like the temporary table to act as a filter within the larger query, which implies that it often sits within the where clause.
- Scalar	- This subquery is used when you’d like to generate a scalar value to be used as a benchmark of some sort.
- Simple Subquery	The inner subquery is completely independent of the larger query.
- SQL Views	- Virtual tables that are derived from one or more base tables. The term virtual means that the views do not exist physically in a database, instead, they reside in the memory (not database), just like the result of any query is stored in the memory.
- Subquery	- A SQL query where one SQL query is nested within another query
- Subquery Dependencies	- Stand independently and be run as complete queries themselves.
- Subquery Output	- Either a scalar (a single value) or rows that have met a condition.
- Subquery Use Case	- Calculate a scalar value to use in a later part of the query (e.g., average price as a filter).
- With	- This subquery is used when you’d like to “pseudo-create” a table from an existing table and visually scope the temporary table at the top of the larger query