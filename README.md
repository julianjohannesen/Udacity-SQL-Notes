# Udacity-SQL-Notes

The following are some quick notes taken while watching and reading Udacity's SQL course.

# SQL Notes for Udacity's SQL Course

## Lesson 1: Introduction to SQL

### Some Quick Vocabulary
- Structured Query Language (SQL) – Structured Query Language is a language that allows us to access information in a database. A typical query might look like this: 
```sql
SELECT account_id, standard_qty, gloss_qty FROM orders WHERE (standard_qty = 0 OR gloss_qty = 0) AND occurred_at = ‘2016-1-01’;
  ```
- NoSQL – NoSQL stands for Not Only SQL. NoSQL databases are a different type of database sometimes used to store web data. An example of a NoSQL database is MongoDB.
- Entity Relationship Diagram (ERD) – A diagrammatic representation of tables and their relationships to one another. Each box shows the name of the table and has two columns below. The first column shows whether a particular field listed to the right is a primary key (PK) or a Foreign Key (FK); the second shows a list of the attributes in the table. Each attribute has a corresponding column in the actual table. The key point here is that the ERD shows us relationships between tables. The “crows feet” arrows show us how the tables connect to one another by connecting primary keys to foreign keys. The three little prongs show that the foreign key can appear in many rows in a table. In other words, the foreign key is not unique in table.
- Primary Key (PK) – Every table has a primary key. The primary key is a unique value for each row. Now two rows can have the same primary key. The primary key is often the first column in a table.
- Foreign Key (FK) – A foreign key is a column in one table that is the primary key in a different table.
- Postgres - A popular open-source database with a very complete library of analytical functions. This is the database used in the course.

### Why is SQL important?
1.	Easy to understand
2.	Can access data directly
3.	Can audit data
4.	Can replicate data
5.	Can analyze multiple tables at once
6.	Can do complex analysis

### Why do businesses like DBs? 
1.	Data integrity is ensured
2.	Data can be accessed quickly
3.	Data is easily shared

### Key points about DBs:
1.	Data in DBs is stored in tables that can be thought of just like Excel spreadsheets
2.	All the data in the same column must match tin terms of data type.
3.	Consistent column types are one of the main reasons working DBs is fast

### What are some examples of SQL DBs?
1.	MySQL
2.	Access
3.	Oracle
4.	MS SQL Server
5.	Postgres

### What is a statement in SQL?
A statement in SQL is a command that allows you to perform a certain function.  Examples include:
 - CREATE TABLE is a statement that creates a new table in a database.
 - DROP TABLE is a statement that removes a table in a database.
 - SELECT allows you to read data and display it. This is called a query.

### SELECT * FROM orders;
This statement is composed of clauses. Clauses always appear in the same order. Some clauses are required and others are optional. The SELECT clause tells the database which columns you want to read from the database. The * is called a wildcard. There are various types of wildcards. This one represents “all columns.” The FROM clause tells the database which table to you want to select columns from. Both SELECT and FROM are mandatory clauses in any SELECT statement. You can write statements in lower case, but traditionally, SQL commands are written all uppercase. So, “select * from orders;” works just fine, but “SELECT * FROM orders;” is more conventional. Sometimes you’ll be required to end a statement in a semicolon, but it depends on the environment. It’s a good habit to include the semicolon at the end.

### The LIMIT Clause
The LIMIT clause limits the number of rows returned from a query. For example:

```sql
SELECT *
FROM orders
LIMIT 10
```

### The ORDER BY clause
The ORDER BY clause allows you specify which column you want to use as the basis for your query results ordering and whether you would like your query results to be put in ascending order (that’s the default) or DESCending order. For example:
```sql
SELECT *
FROM orders
ORDER BY occurred_at DESC
LIMIT 10
```
Just like in Excel, you can order by multiple columns. Just list the columns you want to use as a comma separated list. For example:
```sql
SELECT *
FROM orders
ORDER BY occurred_at DESC, total_amt_usd
LIMIT 10
```
Notice that we specified that “occurred_at” should be descending order, but total_amt_usd should be in the default ascending order.

### The WHERE Clause
The WHERE clause goes between FROM and ORDER BY. WHERE allows you narrow your search to results where one column has a particular value or range of values. For example:
```sql
SELECT *
FROM orders
WHERE account_id >= 1000 and account_id <= 1041 and standard_qty > 150
ORDER BY occurred_at
LIMIT 1000;
```
Here, you’ll get results only for the records with account_id in the range greater than or equal to 1,000 and less than or equal to 1041 and with standard_qty greater than 150. You can use a combination of mathematical and logical operators to create complex WHERE clauses. The example above uses columns that have numerical values, but you could also use columns with text values. For example,
```sql
SELECT name, website, primary_poc
FROM accounts
WHERE name = 'Exxon Mobil';
```

### Derived Columns
A derived column is a column you create by using mathematical operations on already existing columns. For example:
```sql
SELECT id, (standard_amt_usd/total_amt_usd)*100 AS std_percent, total_amt_usd
FROM orders
LIMIT 10;
```
Here, we select the “id” column and a second derived column that we create by dividing standard_amt_usd by total_amt_usd and multiplying that by 100. We use the AS clause to name this new derived column “std_percent.” Then we add a third column – “total_amt_usd”.

### Logical Operators
Logical operators allow you to create longer more complex statements. Here’s a summary of the logical operators:
- LIKE - This allows you to perform operations similar to using WHERE and =, but for cases when you might not know exactly what you are looking for.
- IN - This allows you to perform operations similar to using WHERE and =, but for more than one condition.
- NOT - This is used with IN and LIKE to select all of the rows NOT LIKE or NOT IN a certain condition.
- AND & BETWEEN - These allow you to combine operations where all combined conditions must be true.
- OR - This allows you to combine operations where at least one of the combined conditions must be true.

### LIKE Example
```sql
SELECT *
FROM accounts
WHERE website LIKE '%google%';
```
Here we’re selecting all columns from the “accounts” table where the “website” column is like the word “google,” but preceded by 0 or more characters of any type and/or followed by 0 or more characters of any type.  Not that LIKE is always used in the WHERE clause.

### IN Example
 The IN operator is useful for working with both numeric and text columns. This operator allows you to use an =, but for more than one item of that particular column. We can check one, two, or many column values for which we want to pull data, but all within the same query.
```sql
SELECT *
FROM orders
WHERE account_id IN (1001,1021);
```
Here’s we’re selecting all columns from the “orders” table but only where the “account_id” is in the group 1001 or 1021. 

### NOT Example
You can add the NOT operator before IN or LIKE to get the inverse of the results those queries would otherwise produce. For example:
```sql
SELECT sales_rep_id, 
       name
FROM accounts
WHERE sales_rep_id NOT IN (321500,321570)
ORDER BY sales_rep_id;
```
Here, we’re getting the “sales_rep_id” and “name” columns from the “accounts” table, but only where the “sales_rep_id” is not in the group 321500 or 321570. 
Here’s another example:
```sql
 SELECT *
FROM accounts
WHERE website NOT LIKE '%com%';
```
Here, we’re getting all of the columns from the “accounts” table, but only where the “website” column does not contain a value with the string “com” within it.

### AND, BETWEEN, and OR Examples
```sql
SELECT *
FROM orders
WHERE occurred_at >= '2016-04-01' AND occurred_at <= '2016-10-01'
ORDER BY occurred_at
```
Here, we select all columns from the “orders” table, but only where the “occurred_at” column contains values greater than or equal to ‘2016-04-01’ and less than or equal to ‘2016-10-01’. Not that you must repeat the “occurred_at” column name for each arithmetic operator. The results are then ordered by “occurred_at”.
The BETWEEN operator works similarly to AND, but look like this:
```sql
SELECT *
FROM orders
WHERE occurred_at BETWEEN '2016-04-01' AND '2016-10-01'
ORDER BY occurred_at
```
Whereas the AND operator makes a statement more exclusive of some records, the OR operator makes a statement more inclusive.
```sql
SELECT *
FROM orders
WHERE standard_qty = 0 OR gloss_qty = 0 OR poster_qty = 0
```
Here, we are selecting all columns from the “orders” table, but only where the “standard_qty” is 0, or where the “gloss_qty” is 0, or where the “poster_qty” is 0. 

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


