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

First, lets find all of the orders that occurred during the first month that there were orders. We can do this with a subquery in the WHERE clause. Then, let's add the left join from web_events to orders to get all of the web_events that occurred before there any orders. We join them on account_id and also on the date inequality. Then we just need to disambiguate the occurred_at references in the WHERE clause (because web_events also has an occurred_at column). 

```sql
select *
from orders o
left join web_events we
on we.account_id = o.account_id
-- Here's the inequality. We want events that happened before any orders
and we.occurred_at < o.occurred_at
where date_trunc('month', o.occurred_at) = (
    select date_trunc('month' min(orders.occurred_at)) from orders
)
order by occurred_at;
```

