## Lesson 7: SQL Advanced Joins and Performance Tuning

### Full Outer Join

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

```
![Right Join](/assets/right-join.png)

#### Inner Join

