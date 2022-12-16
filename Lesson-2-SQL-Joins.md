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

## Left and Right Joins

An inner join will only return records that appear in both tables (or all of the tables) that you're working with. It will not return records that appear in one table, but not the other(s). But sometimes you want to be able to display records in your results that only appear in one of the tables you're working with. That's where LEFT and RIGHT joins come in.

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
Here, again, we're selecting the id and name columns from the accounts table and the total column from the orders table. We're starting with the orders table (which we alias to o), and then RIGHT JOIN the accounts table (which we alias to a). We join these tables ON the order table's account_id column (a foreign key in orders) and the accounts table's id column (the primary key in accounts). Now the results that we get back from the query have changed. We can now see account ids that 

### What makes the orders table the left table in a Venn diagram of the two tables?
The orders table is the left hand part of the diagram because it is the table that appears in the FROM clause. The orders table contains the foreign key.

