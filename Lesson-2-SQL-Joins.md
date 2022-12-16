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
You can give aliases both to a table name and to a column name from within a particular table. The general form looks like this:
```sql
SELECT t1.column1 aliasname, t2.column2 aliasname2
FROM tablename AS t1
JOIN tablename2 AS t2
```
Here, we’re giving the short alias “t1” to “tablename” and the short alias “t2” to “tablename2”. Those aliases are then used in the SELECT clause to rename “t1.column1” to “aliasname” and “t2.column2” as “aliasname2”.

If you have two tables that use the same name for a column and you want to display both those columns, then you must use and alias for at least one of the column names.
```sql
SELECT o.*, a.*
FROM orders o
JOIN accounts a
ON o.account_id = a.id
```
Here, we’re getting all columns from both orders and accounts, starting FROM orders, which we alias as “o” and JOINing accounts, which we alias as “a”, and joining those two tables ON orders.account_id and accounts.id.


