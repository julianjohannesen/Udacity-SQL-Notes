## Lesson 7: SQL Advanced Joins and Performance Tuning

### Join Types and the Full Outer Join

For all of these, the table on the left side of the diagram is Table A and the one on the right is Table B.

#### Inner Join

This is the most common and also the default join type.
```sql
SELECT column_name(s)
FROM Table_A
INNER JOIN Table_B ON Table_A.column_name = Table_B.column_name;
```

![Inner Join](/assets/inner-join.png)

#### Left Join General Form

When you want include unmatched records from the left table.
```sql
SELECT column_name(s)
FROM Table_A
LEFT JOIN Table_B ON Table_A.column_name = Table_B.column_name;
```

![Left Join](/assets/left-join.png)

#### Right Join General Form

When you want to include unmatched records from the right table.
```sql
SELECT column_name(s)
FROM Table_A
RIGHT JOIN Table_B ON Table_A.column_name = Table_B.column_name;
```

![Right Join](/assets/right-join.png)

#### Full Outer Join

When you want to include unmatched records from both tables.
```sql
SELECT column_name(s)
FROM Table_A
FULL OUTER JOIN Table_B ON Table_A.column_name = Table_B.column_name;
```

![Full Outer](/assets/full-outer-join.png)

FULL JOIN is commonly used in conjunction with aggregations to understand the amount of overlap between two tables.

#### Full Outer Join If Null

Find only the unmatched rows in your tables.
```sql
SELECT column_name(s)
FROM Table_A
FULL OUTER JOIN Table_B ON Table_A.column_name = Table_B.column_name;
WHERE Table_A.column_name IS NULL OR Table_B.column_name IS NULL
```

![Full outer join with nulls only](/assets/full-outer-join-if-null.png)

#### Problems for Full Outer Join

Say you're an analyst at Parch & Posey and you want to see:

- Each account who has a sales rep and each sales rep that has an account (all of the columns in these returned rows will be full)
- But also each account that does not have a sales rep and each sales rep that does not have an account (some of the columns in these returned rows will be empty)

```sql
select
    a.*,
    sr.*
from accounts a
full outer join sales_reps sr
on a.sales_rep_id = sr.id
```

### Joins with Inequalities

First, lets find all of the orders that occurred during the first month that there were orders. We can do this with a subquery in the WHERE clause. 

```sql
select *
from orders
where date_trunc('month', occurred_at) = (
    -- Use a subquery and MIN() to get the earliest date of any order
    select date_trunc('month' min(occurred_at)) from orders
)
order by occurred_at;
```

Then, let's add the left join from web_events to orders to get all of the web_events that occurred before there any orders. We join them on account_id and also on the date inequality. Then we just need to disambiguate the id and occurred_at references in the SELECT, WHERE and ORDER BY clauses. 

```sql
select 
    -- We can narrow down what we want and add the table prefix to disambiguate
	o.id as order_id,
    o.occurred_at as order_date,
	we.*
from orders o
-- Left join to include any null entries in web_events
left join web_events we
-- We join on account_id
on we.account_id = o.account_id
-- ...and also on events. Here's the inequality. We want events that occurred before any orders were made. 
-- Note that the join will be processed before the WHERE clause
and we.occurred_at < o.occurred_at
where date_trunc('month', o.occurred_at) = (
    select date_trunc('month', min(occurred_at)) from orders
)
order by o.occurred_at, we.occurred_at;
```

NOTE: The join clause is evaluated before the where clause -- filtering in the join clause will eliminate rows before they are joined, while filtering in the WHERE clause will leave those rows in and produce some nulls.

#### Joins and Inequalities Problem

Write a query that left joins the accounts table and the sales_reps tables on each sale rep's ID number and joins it using the < comparison operator on accounts.primary_poc and sales_reps.name.

The query results should be a table with three columns: the account name (e.g. Johnson Controls), the primary contact name (e.g. Cammy Sosnowski), and the sales representative's name (e.g. Samuel Racine).

```sql
select
    a.name account_name,
    a.primary_poc,
    sr.name sales_rep_name
from accounts a
left join sales_reps sr
on sr.id = a.sales_rep_id
    -- Using an inequality on a string value. The effect is that the poc's name comes before the rep's name alphabetically
    and a.primary_poc < sr.name 
```

Remember that there are 351 accounts and every account has a primary point of contact. There are only 50 sales reps, which means that each sales rep will have many accounts assigned to them. 

You can see how many accounts are assigned to each sales rep with:

```sql
select sr.name rep_name, count(*) accounts_assigned
from sales_reps sr
-- It so happens that every account has a rep and every rep has at least 1 account
join accounts a 
	/* 
    For each row in the sales rep table, there are
    x corresponding rows in the accounts table. That is,
    x rows that have that sales rep's id in 'sales_rep_id'.
    For example, for Akilah Drinkard x = 3. She has 3 accounts.
    */
	on a.sales_rep_id = sr.id
group by 1
order by 1
```

Back to the problem. What is a our filting condition? In this case, our filtering condition appears in the ON clause. It's the requirement that in addtion to joining only records that match on sales rep id, we also only match records for which the point of contact's name appears earlier in the alphabet than the sales rep's name.

Because we're doing a left join in the solution query and because we're not doing any filtering on accounts, we'll see all 351 accounts. However, we may not see all 50 sales reps. Some sales reps may be filtered out by our filting condtions. And, in fact, that is the case. If we had done a right join, rather than a left join, we would see that there are sales reps who do not have any accounts that meet the filtering conditions we imposed. Akila Drinkard, for example, has 3 accounts, but she doesn't have any accounts that meet our filtering conditions. All of her points of contact have names that appear later in the alphabet than her name.

### Self Joins

A "self join" is a join between a table and itself.

One of the most common use cases for self JOINs is in cases where two events occurred, one after another.

Using inequalities in conjunction with self JOINs is common.

#### Problem: Find the accounts that have ever made multiple orders within a 30 day period. Also show all of the occassions on which this occurred. Use a left join of the orders table to itself so that we can also see occassions on which an order does not have a matching order within 30 days. Show order id, account id, and occurred at for both tables o1 and o2.

```sql
SELECT o1.id AS o1_id,
       o1.account_id AS o1_account_id,
       o1.occurred_at AS o1_occurred_at,
       o2.id AS o2_id,
       o2.account_id AS o2_account_id,
       o2.occurred_at AS o2_occurred_at
FROM   orders o1
LEFT JOIN orders o2
ON     o1.account_id = o2.account_id
-- The second order occurred later than the first order
AND    o2.occurred_at > o1.occurred_at
-- But also occurred earlier than 28 days after the first order
AND    o2.occurred_at <= o1.occurred_at + INTERVAL '28 days'
ORDER BY o1.account_id, o1.occurred_at
```

There are only 2,550 orders out of the total 6,912 orders that were ordered by the same account within 30 days of an earlier order. But we see all of the orders, due to the left join from orders o1 to orders o2. The orders that do not have a matching subsequent order within 30 days really stand out if you re-order by o1_id, because you'll see nulls in the o2 id, o2 account id, and o2 occurred at columns.

#### Problem: You could turn this into a slightly different challenge: How many accounts have ever placed more than one order for paper in the same 30 day period?

```sql
SELECT COUNT(DISTINCT o1_account_id)
FROM (
	SELECT o1.account_id AS o1_account_id
	FROM orders o1
	JOIN orders o2
	ON   o1.account_id = o2.account_id
	AND  o2.occurred_at > o1.occurred_at
	AND  o2.occurred_at <= o1.occurred_at + INTERVAL '28 days'
) AS sub
```

We get a count of distinct occurrences of o1_account_id and put the previous solution into a derived table in the FROM clause. In the derived table, we don't need to select anything other than the o1_account_id. But we do need that one, because we're counting distinct instances of it in the outer query.

#### Problem: Find all of the web events that occurred after, but not more than 1 day after, another web event. Add a column for the channel variable in both instances of the table in your query.

```sql
select
    we1.channel as we1_channel,
    we1.occurred_at as earlier,
    we2.channel as we2_channel,
    we2.occurred_at as later
from web_events we1
left join web_events we2
on we1.account_id = we2.account_id
and we1.occurred_at < we2.occurred_at
and we2.occurred_at < we1.occurred_at + interval '24 hours'
```

### Unions

The UNION operator is used to combine the result sets of 2 or more SELECT statements. It removes duplicate rows between the various SELECT statements.

#### Use Cases

**When a user wants to pull together distinct values of specified columns that are spread across multiple tables.** 

For example, a chef wants to pull together the ingredients and respective aisle across three separate meals that are maintained within different tables.

Or, say you want to determine all reasons students are late. Currently, student information is maintained in one table, but each late reason is maintained within tables corresponding to the grade the student is in. The table with the students' information needs to be appended with the late reasons. It requires no aggregation or filter, but all duplicates need to be removed. So the final use case is the one where the UNION operator makes the most sense.

#### Details of UNION

Each SELECT statement within the UNION must have the same number of fields in the result sets with similar data types.

- There must be the same number of expressions in both SELECT statements.
- The corresponding expressions must have the same data type in the SELECT statements. For example, Expression1 must be the same data type in both the first and second SELECT statement.
- The columns do NOT need to have the same names, but they usually do.
- UNION only appends DISTINCT rows. Duplicates are removed. UNION ALL appends all rows. You'll usually use UNION ALL.

Here's an example.

Run this first, to create a view:
```sql
CREATE VIEW web_events_2
AS (SELECT * FROM web_events)
```

Now run this:
```sql
SELECT *
FROM web_events
UNION
SELECT *
FROM web_events_2
```

You should see all 9,073 rows that the two tables have in common.

Another example, this time using UNION ALL, and reusing the view we created above:

```sql
SELECT *
FROM web_events
WHERE channel = 'facebook'
UNION ALL
SELECT *
FROM web_events_2
```

You should see 10,040 rows with the first thousand or so rows showing only "facebook" results from web_events_1 and the remaining rows showing all results from web_events_2.

You can use a UNION inside a subquery like this:

```sql
SELECT channel,
       COUNT(*) AS sessions
FROM (
      SELECT *
      FROM web_events
      UNION ALL
      SELECT *
      FROM web_events_2
     ) web_events
GROUP BY 1
ORDER BY 2 DESC
```
Or you can put it in a common table expression (CTE) like this:

```sql
WITH web_events AS (
      SELECT *
      FROM web_events
      UNION ALL
      SELECT *
      FROM web_events_2
     )
SELECT channel,
       COUNT(*) AS sessions
FROM  web_events
GROUP BY 1
ORDER BY 2 DESC
```

You should see a table of channels and the count of each channel, but with twice the counts that you would see wihout the UNION ALL.

### Performance Tuning

One way to make a query run faster is to reduce the number of calculations that need to be performed. Some of the high-level things that will affect the number of calculations a given query will make include:

- Table size
- Joins
- Aggregations

Query runtime is also dependent on some things that you can’t really control related to the database itself:

- Other users running queries concurrently on the database
- Database software and optimization (e.g., Postgres is optimized differently than Redshift)

#### Tip 1: Reduce table size

Try to run your queries on only a subset of your data. This called "exploratory analysis." Many query editors do this automatically. 

Aggregations: When aggregations appear in the main query, they can really sloq down your query. However, you can create a subset of your data by creating a subquery. The subquery will run first. Then you aggregate on that subquery.

For example:

```sql
SELECT account_id,
        -- Aggregations are expensive!
       SUM(poster_qty) AS sum_poster_qty
       -- So, create a subquery and limit the result rows
       -- The subquery runs first, before the aggregation in the outer query
FROM   (SELECT * FROM orders LIMIT 100) sub
-- The filter will run on the subquery results before the aggregation
WHERE  occurred_at >= '2016-01-01'
AND    occurred_at < '2016-07-01'
GROUP BY 1
-- Note that using LIMIT here will not help you, because the aggregation
-- will happen before the limit is applied to any results. LIMIT does help
-- When you're just selecting and displaying columns.
```

#### Tip 2: Reduce the complexity of tables before JOINing them

Reduce the complexity of tables by:
- reducing size of tables or subqueries before joining them
- performing aggregations on smaller tables first, before joining them. 

For example:

```sql
SELECT 
    a.name,
    sub.web_events
-- Use derived table to count web_events rather than joining web_events and accounts and then doing the count
FROM (
    SELECT 
        account_id,
        COUNT(*) AS web_events
    FROM web_events
    GROUP BY 1
    ) AS sub
JOIN accounts a 
ON a.id = sub.account_id
ORDER BY 2 DESC
```

