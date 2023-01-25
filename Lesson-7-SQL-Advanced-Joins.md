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

