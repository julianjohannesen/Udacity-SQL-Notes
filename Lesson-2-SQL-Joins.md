## Lesson 2: SQL Joins

### Why are different sorts of data stored in different tables?
1.	Some sorts of data are updated more frequently than other sorts and it’s more efficient and safer to store them separately
2.	Storing data in separate tables allows you to access the data much more quickly, because each table contains only a portion of the total available data

### What is database normalization?
When you normalize a database, you have four goals:
1.	Arranging data into logical groupings such that each group describes a small part of the whole.
2.	Minimizing the amount of duplicate data stored in a database.
3.	Organizing the data such that when you modify it, you make the change in only one place.
4.	Building a database in which you can access and manipulate the data quickly and efficiently without compromising the integrity of the data in storage.

### Three questions about normalization:
1.	Are the tables storing logical groupings of data?
2.	Can I make changes in a single location, rather than in many tables for the same information?
3.	Can I access and manipulate data quickly and efficiently?

### Inner Joins
Joins allow us to pull data from more than one table at a time.
```sql
SELECT orders.*,
       accounts.*
FROM orders 
JOIN accounts
ON orders.account_id = accounts.id;
```
Here, we SELECT every column from both the orders table and the accounts table. We need to use the dot notation to specify from which table we’re getting a particular column. In this case, we’re using a wildcard to get all columns. (We could have skipped listing both tables and just used the wildcard, in this case) We’ll get those columns FROM the orders table, JOINed with the accounts table. We’ll join these two tables ON two particular columns: the account_id column from orders and the id column from accounts. 

You can join more than two tables like this:
```sql
SELECT *
FROM web_events
JOIN accounts
ON web_events.account_id = accounts.id
JOIN orders
ON accounts.id = orders.account_id
```
Here, we SELECT all columns from all tables, starting FROM the web_events table and JOINing the accounts table ON web_events.account_id and accounts.id. Then we JOIN the orders table ON accounts.id and orders.account_id. Note that we connect web_events to accounts and then connect accounts to orders.

### Aliases
You can give aliases both to a table name and to a column name from within a particular table. You an use an optional AS clause between the name and the alias if you want to. The general form looks like this:
```sql
SELECT t1.column1 aliasname, t2.column2 aliasname2
FROM tablename AS t1
JOIN tablename2 AS t2
```
Here, we’re giving the short alias “t1” to “tablename” and the short alias “t2” to “tablename2”. Those aliases are then used in the SELECT clause to rename “t1.column1” to “aliasname” and “t2.column2” as “aliasname2”.

If you have two tables that use the same name for a column and you want to display both those columns, then you must use an alias for at least one of the column names.
```sql
SELECT o.*, a.*
FROM orders o
JOIN accounts a
ON o.account_id = a.id
```
Here, we’re getting all columns from both orders and accounts, starting FROM orders, which we alias as “o” and JOINing accounts, which we alias as “a”, and joining those two tables ON orders.account_id and accounts.id.

Other examples from the problems in section 11.

Problem: Provide a table for all the for all web_events associated with account name of Walmart. There should be three columns. Be sure to include the primary_poc, time of the event, and the channel for each event. Additionally, you might choose to add a fourth column to assure only Walmart events were chosen.
```sql
SELECT a.primary_poc, w.occurred_at, w.channel, a.name
FROM web_events w
JOIN accounts a
ON w.account_id = a.id
WHERE a.name = 'Walmart';
```
Problem: Provide a table that provides the region for each sales_rep along with their associated accounts. Your final table should include three columns: the region name, the sales rep name, and the account name. Sort the accounts alphabetically (A-Z) according to account name.
```sql
SELECT r.name region, s.name rep, a.name account
FROM sales_reps s
JOIN region r
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
ORDER BY a.name;
```
Problem: Provide the name for each region for every order, as well as the account name and the unit price they paid (total_amt_usd/total) for the order. Your final table should have 3 columns: region name, account name, and unit price. A few accounts have 0 for total, so I divided by (total + 0.01) to assure not dividing by zero.

```sql
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

### Left and Right Joins

An inner join will only return records that appear in both tables (or all of the tables) that you're working with. It will not return records that appear in one table, but not the other(s). But sometimes you want to be able to display records in your results that only appear in one of the tables you're working with. That's where LEFT and RIGHT joins come in. Note that these joins are sometimes referred to as the LEFT OUTER JOIN and RIGHT OUTER JOIN. 

Here's an example:
```sql
SELECT a.id, a.name, o.total
FROM orders o
LEFT JOIN accounts a
ON o.account_id = a.id
```
Here, we're selecting the id and name columns from the accounts table and the total column from the orders table. We're starting with the orders table (which we alias to o), and then LEFT JOIN the accounts table (which we alias to a). We join these tables ON the order table's account_id column (a foreign key in orders) and the accounts table's id column (the primary key in accounts). In this particular case, the inner join and the left join produce the exact same results.

However, the results will be different if we use a RIGHT JOIN, like this:
```sql
SELECT a.id, a.name, o.total
FROM orders o
RIGHT JOIN accounts a
ON o.account_id = a.id
```
Here, again, we're selecting the id and name columns from the accounts table and the total column from the orders table. We're starting with the orders table (which we alias to o), and then RIGHT JOIN the accounts table (which we alias to a). We join these tables ON the order table's account_id column (a foreign key in orders) and the accounts table's id column (the primary key in accounts). Now the results that we get back from the query have changed. If you evaluate the query in the classroom's IDE and then scroll all the way to the bottom of the results, you will now see one account id, 1731, and name, Goldman Sachs Group, that does not have a corresponding total. 

### What makes the orders table the left table in a Venn diagram of the two tables?
The orders table is the left hand part of the diagram because it is the table that appears in the FROM clause. You can switch things around and use accounts in the FROM clause, and in that case, accounts will now be the left hand part of the diagram and orders will be the right hand part. 

In the Udacity course, the course designers generally use LEFT JOINs and do not use RIGHT JOINs. They just arrange the FROM clause as needed. So, in the example above, instead of using a RIGHT JOIN in order to be able see Goldman Sachs Group in our query results, you would use a LEFT JOIN and just put accounts in the FROM clause and orders in the JOIN clause.

### Outer Joins
An OUTER JOIN, also called a FULL OUTER JOIN, is a join that will return rows from the inner join result, and also rows from either of the tables being joined. This join is used rarely.

### Joins and Filtering
You can sometimes accomplish the same thing by either putting logic in the ON clause or by using a WHERE clause. Logic in the ON clause reduces the rows before combining the tables, whereas logic in the WHERE clause occurs after the join occurs. Put another way, when the database executes a query, it executes the join and everything in the ON clause first. Think of this as building the new result set. That result set is then filtered using the WHERE clause. So, these two statements produce the same results, but in different ways:
```sql
SELECT orders.*, accounts.*
FROM orders
LEFT JOIN accounts
ON orders.account_id = accounts.id 
WHERE accounts.sales_rep_id = 321500
```
Here, we SELECT all columns from both the orders and accounts tables. We start FROM the orders table and LEFT JOIN the accounts table ON the orders table's account_id (a foregin key in orders) and the accounts table's id (the primary key in accounts). We then filter for results WHERE the accounts table's sales_rep_id is 321500. The results show all of Tamara Tuma's accounts and sales.

Here's another way to get the same results by putting the logic in the ON clause:
```sql
SELECT orders.*, accounts.*
FROM orders
LEFT JOIN accounts
ON orders.account_id = accounts.id 
AND accounts.sales_rep_id = 321500
```
Here, we're selecting the same columns from the same tables as above, but instead of filtering the joined tables with a WHERE clause, we're adding another clause to the ON clause, specifying that we want only the join that has orders.acount_id = accounts.id AND accounts.sales_rep_id = 321500.

### Sample problems from section 19

Problem 1. Provide a table that provides the region for each sales_rep along with their associated accounts. This time only for the Midwest region. Your final table should include three columns: the region name, the sales rep name, and the account name. Sort the accounts alphabetically (A-Z) according to the account name.
```sql
select r.name as rname, sr.name as srname, a.name as aname
from region r
join sales_reps sr
on sr.region_id = r.id
and r.name = 'Midwest'
join accounts a
on a.sales_rep_id = sr.id
```

Problem 2. Provide a table that provides the region for each sales_rep along with their associated accounts. This time only for accounts where the sales rep has a first name starting with S and in the Midwest region. Your final table should include three columns: the region name, the sales rep name, and the account name. Sort the accounts alphabetically (A-Z) according to the account name.
```sql
select r.name as rname, sr.name as srname, a.name as aname
from region r
join sales_reps sr
on sr.region_id = r.id
and r.name = 'Midwest'
join accounts a
on a.sales_rep_id = sr.id
and sr.name like 'S%'
order by a.name
```

Problem 3. Provide a table that provides the region for each sales_rep along with their associated accounts. This time only for accounts where the sales rep has a last name starting with K and in the Midwest region. Your final table should include three columns: the region name, the sales rep name, and the account name. Sort the accounts alphabetically (A-Z) according to the account name.
```sql
select r.name as rname, sr.name as srname, a.name as aname
from region r
join sales_reps sr
on sr.region_id = r.id
and r.name = 'Midwest'
join accounts a
on a.sales_rep_id = sr.id
and sr.name like '% K%'
order by a.name
```

Problem 4. Provide the name for each region for every order, as well as the account name and the unit price they paid (total_amt_usd/total) for the order. However, you should only provide the results if the standard order quantity exceeds 100. Your final table should have 3 columns: region name, account name, and unit price. In order to avoid a division by zero error, adding .01 to the denominator here is helpful total_amt_usd/(total+0.01).
```sql
select r.name, a.name, o.total_amt_usd/(o.total + 0.01) as unit_price
from region r
join sales_reps sr
on sr.region_id = r.id
join accounts a
on a.sales_rep_id = sr.id
join orders o
on o.account_id = a.id 
and o.standard_qty > 100
```

Problem 5. Provide the name for each region for every order, as well as the account name and the unit price they paid (total_amt_usd/total) for the order. However, you should only provide the results if the standard order quantity exceeds 100 and the poster order quantity exceeds 50. Your final table should have 3 columns: region name, account name, and unit price. Sort for the smallest unit price first. In order to avoid a division by zero error, adding .01 to the denominator here is helpful (total_amt_usd/(total+0.01).
```sql
select r.name as rname, a.name as aname, o.total_amt_usd/(o.total + 0.01) as unit_price
from region r
join sales_reps sr
on sr.region_id = r.id
join accounts a
on a.sales_rep_id = sr.id
join orders o
on o.account_id = a.id
and o.standard_qty > 100
and poster_qty > 50
```

Problem 6. Provide the name for each region for every order, as well as the account name and the unit price they paid (total_amt_usd/total) for the order. However, you should only provide the results if the standard order quantity exceeds 100 and the poster order quantity exceeds 50. Your final table should have 3 columns: region name, account name, and unit price. Sort for the largest unit price first. In order to avoid a division by zero error, adding .01 to the denominator here is helpful (total_amt_usd/(total+0.01).
```sql
select r.name as rname, a.name as aname, o.total_amt_usd/(o.total + 0.01) as unit_price
from region r
join sales_reps sr
on sr.region_id = r.id
join accounts a
on a.sales_rep_id = sr.id
join orders o
on o.account_id = a.id
and o.standard_qty > 100
and poster_qty > 50
order by unit_price desc
```

Problem 7. What are the different channels used by account id 1001? Your final table should have only 2 columns: account name and the different channels. You can try SELECT DISTINCT to narrow down the results to only the unique values.
```sql
select distinct we.channel, a.name
from web_events we
join accounts a
on we.account_id = a.id
and a.id = '1001'
```

Problem 8. Find all the orders that occurred in 2015. Your final table should have 4 columns: occurred_at, account name, order total, and order total_amt_usd.
```sql
select o.occurred_at, a.name, o.total, o.total_amt_usd
from accounts a
join orders o
on o.account_id = a.id
where o.occurred_at between '01-01-2015' and '01-01-2016'
order by o.occurred_at desc
```