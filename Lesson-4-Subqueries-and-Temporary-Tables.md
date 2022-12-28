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




