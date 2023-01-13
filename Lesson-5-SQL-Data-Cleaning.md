## Lesson 5: SQL Data Cleaning

**Data Cleaning** is massaging or manipulating data to make to more suitable for analysis.

By definition, data cleaning is the task of cleaning up raw data to make it usable and ready for analysis. Almost always, your data will not be ready for you to run an analysis.

- Your data could all be lumped together in a single column, and you need to parse it to extract useful information.
- Your data could all default to string data types, and you need to cast each column appropriately to run computations.
- Your data could have un-standardized units of currency, and you need to normalize the column to ensure you are comparing equally across records.

**Normalization**: Standardizing or “cleaning up a column” by transforming it in some way to make it ready for analysis. A few normalization techniques are below:

- Adjusting a column that includes multiple currencies to one common currency
- Adjusting the varied distribution of a column value by transforming it into a z-score
- Converting all price into a common metric (e.g., price per ounce)

### Key Steps in Data Cleaning

1. What data do you need?: Review what data you need to run an analysis and solve the problem at hand.
2. What data do you have?: Take stock of not only the information you have in your dataset today but what data types those fields are. Do these align with your data needs?
3. How will you clean your data?: Build a game plan of how you’ll convert the data you currently have to the data you need. What types of actions and data cleaning techniques will you have to apply? Do you have the skills you need to go from the current to future state?
4. How will you analyze your data?: Now, it’s game time! How do you run an effective analysis? Build an approach for analysis, as well. And visualize your plan to solve the problem. Finally, remember to question “so what?” at the end of your results, which will help drive recommendations for your organization.

### Methods for Data Cleaning

The following set of methods cover three types of data cleaning techniques: 
- parsing information, 
- returning where information lives, and 
- changing the data type of the information.

Here are the methods:
- Left: Extracts a number of characters from a string starting from the left
- Right: Extracts a number of characters from a string starting from the right
- Substr: Extracts a substring from a string (starting at any position)
- Position: Returns the position of the first occurrence of a substring in a string, e.g. POSITION("$" IN student_information) as salary_starting_position
- Strpos: Returns the position of a substring within a string
- Concat: Adds two or more expressions together, e.g. CONCAT(month, '-', day, '-', year) AS date
- Cast: Converts a value of any type into a specific, different data type, e.g. CAST(salary AS int)
- Coalesce: Returns the first non-null value in a list

### Common Methods

#### Use Case: When data in a single column holds multiple pieces of information. 

Methods:
- LEFT(string, number_of_characters)
- RIGHT(string, number_of_characters)
- SUBSTR(string, start, number_of_characters)
- POSITION(substring IN string)
- STRPOS(string, substring)

#### Use Case: When two or more columns serve as a unique identifier

Methods:
- Concat(string1, string2, string3, ...)

#### Use Case: Converting data into specific data types

Methods:
- Cast(expression AS datatype)

#### Use Case: If there are multiple columns that have a combination of null and non-null values and the user needs to extract the first non-null value, you can use the coalesce function.

Methods:
- Coalesce(value1, value2, value3, ...)

### Table of Functions

This is even better: https://www.postgresql.org/docs/8.1/functions-string.html

| Function | Description                                                             | Syntax                                  | Returns                                                                                                                                    | Example                                    |
|----------|-------------------------------------------------------------------------|-----------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------|
| left     | Extracts a number of characters from a string starting from the left    | left(string, num_characters)            | A new string starting at the first character and continuing to num_characters to the left, inclusive                                       |                                            |
| right    | Extracts a number of characters from a string starting from the right   | right(string, num_characters)           | A new string starting at the last character and continuing to num_characters to the right, inclusive                                       |                                            |
| substr   | Extracts a substring from a string (starting at any position)           | substr(string, start, num_characters)   | A new string starting from start and continuing to num_characters, inclusive.                                                              |                                            |
| position | Returns the position of the first occurrence of a substring in a string | position(substring IN string)           | A new string if substring is found or 0, unless the value is NULL, in which case NULL.                                                     | POSITION("$" IN student_info) AS salary    |
| strpos   | Returns the position of a substring within a string                     | strpos(string, substring)             | A new string if substring is found or 0, unless the value is NULL, in which case NULL.                                                     |                                            |
| concat   | Adds two or more expressions together                                   | concat(string1, string2, ...)           | A new string. NULL values are ignored, unless using \|\| operator in which case anything concatenated with a NULL value will return NULL.  | CONCAT(month, '-', day, '-', year) AS date |
| cast     | Converts a value of any type into a specific, different data type       | cast(expression AS datatype)            | An expression of the new type. If the expression cannot be converted to the target type, PostgreSQL will raise an error.                   | CAST(salary AS int)                        |
| coalesce | Returns the first non-null value in a list                              | coalesce(expression1, expression2, ...) | The first argument that is not null. If all arguments are null, returns null.                                                              | COALESCE(hourly_wage * 40 * 52, salary, commission * sales) AS annual_income                                           | 

### LEFT and RIGHT Quiz

1. In the accounts table, there is a column holding the website for each company. The last three digits specify what type of web address they are using. A list of extensions (and pricing) is provided here. Pull these extensions and provide how many of each website type exist in the accounts table.
```sql
with 
    t1 as (
        select
  	        right(website, 3) as domain
        from accounts
    )
select 
	distinct domain,
	count(domain) as count
from t1
group by 1
```

2. There is much debate about how much the name (or even the first letter of a company name) matters. Use the accounts table to pull the first letter of each company name to see the distribution of company names that begin with each letter (or number).

```sql
with t1 as (
  	select 
        left(name, 1) as initial 
	from accounts
  )
select 
	initial,
    count(*) as count
from t1
group by 1
order by 1
```

3. Use the accounts table and a CASE statement to create two groups: one group of company names that start with a number and the second group of those company names that start with a letter. What proportion of company names start with a letter?

```sql
SELECT SUM(num) nums, SUM(letter) letters
FROM (
        SELECT 
            name, 
            CASE 
                WHEN LEFT(UPPER(name), 1) IN ('0','1','2','3','4','5','6','7','8','9') 
                THEN 1 
                ELSE 0 
            END AS num, 
            CASE 
                WHEN LEFT(UPPER(name), 1) IN ('0','1','2','3','4','5','6','7','8','9') 
                THEN 0 
                ELSE 1 
            END AS letter
        FROM accounts
) t1;
```

4. Consider vowels as a, e, i, o, and u. What proportion of company names start with a vowel, and what percent start with anything else?

```sql
select
    sum(vowel) as vowels,
    sum(other) as others
from (
    select 
        case
            when left(name, 1) in ('A','E','I','O','U', 'a', 'e', 'i', 'o', 'u')
            then 1
            else 0
        end as vowel,
        case
            when left(name, 1) in ('A','E','I','O','U', 'a', 'e', 'i', 'o', 'u')
            then 0
            else 1
        end as other
    from accounts
    ) t1
```

### BONUS CONCEPT
This is an advanced example:
```sql
WITH table AS(
SELECT  student_information,
        value,
        ROW _NUMBER() OVER(PARTITION BY student_information ORDER BY (SELECT NULL)) AS row_number
FROM    student_db
        CROSS APPLY STRING_SPLIT(student_information, ',') AS back_values
)
SELECT  student_information,
        [1] AS STUDENT_ID,
        [2] AS GENDER,
        [3] AS CITY,
        [4] AS GPA,
        [5] AS SALARY
FROM    table
PIVOT(
        MAX(VALUE)
        FOR row_number IN([1],[2],[3],[4],[5])
) AS PVT
```
What this query does is create a pivot table from the student_db table. It uses some concepts that haven't been covered yet.

### Quiz: CONCAT, LEFT, RIGHT, and SUBSTR

1. Suppose the company wants to assess the performance of all the sales representatives. Each sales representative is assigned to work in a particular region. To make it easier to understand for the HR team, display the concatenated sales_reps.id, ‘_’ (underscore), and region.name as EMP_ID_REGION for each sales representative.

```sql
select concat(sr.id, '_', r.name) as EMP_ID_REGION
from region r
join sales_reps sr
on sr.region_id = r.id
```

2. From the accounts table, display the name of the client, the coordinate as concatenated (latitude, longitude), email id of the primary point of contact as <first letter of the primary_poc><last letter of the primary_poc>@<extracted name and domain from the website>.

```sql
select 
    a.name as account_name, 
    concat(lat, long) as coordinate, 
    concat(
            left(primary_poc, 1), 
            right(primary_poc, 1), 
            '@', 
            -- surprised this worked!
            substr(website, (position('.' in website)+1))
            ) as poc_email_id
from accounts a
```

3. From the web_events table, display the concatenated value of account_id, '_' , channel, '_', count of web events of the particular channel.

```sql
with t1 as (
    select 
        account_id, 
        channel, 
        count(*) as channel_count
    from web_events
    group by 1,2
)
select
    concat(account_id, '_', channel, '_', channel_count) as account_channel_count
from t1
```
### Using CAST 

Take a column formatted like this "01/31/2014 08:00:00 AM +0000" and return a properly formatted DATE.

```sql
select 
	date,
	cast(
      	concat(
      		substr(date, 7, 4),
      		'-',
      		substr(date, 1, 2),
      		'-',
      		substr(date, 4, 2)--,
            -- I tried to add in the time, but it doesn't seem to work
      		--'T',
      		--substr(date, 12, 9)
    		) 
     	AS DATE)
from sf_crime_data
```

### POSITION and STRPOS

1. Use the accounts table to create first and last name columns that hold the first and last names for the primary_poc.

```SQL
select 
	substr(primary_poc, 1, (position(' ' in primary_poc)-1)) as first,
    substr(primary_poc, (position(' ' in primary_poc)+1)) as last
from accounts a
```

2. Now see if you can do the same thing for every rep name in the sales_reps table. Again provide first and last name columns.

```sql
select 
	substr(name, 1, (position(' ' in name)-1)) as first,
    substr(name, (position(' ' in name)+1)) as last
from sales_reps sr
```

The suggested solutions are a little different. Both use LENGTH, which we have not covered:
```sql
SELECT 
    LEFT(primary_poc, STRPOS(primary_poc, ' ') -1 ) first_name, 
    RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) last_name
FROM accounts;


SELECT 
    LEFT(name, STRPOS(name, ' ') -1 ) first_name, 
    RIGHT(name, LENGTH(name) - STRPOS(name, ' ')) last_name
FROM sales_reps;
```
### Problems for CONCAT and STRPOS

1. Each company in the accounts table wants to create an email address for each primary_poc. The email address should be the first name of the primary_poc . last name primary_poc @ company name .com.

```sql
select
	primary_poc,
    -- could do this quickly with REPLACE()
    -- replace(name, ' ', '.')
	concat(
      	left(primary_poc, (strpos(primary_poc, ' ')-1)),
      	'.',
      	substr(primary_poc, (strpos(primary_poc, ' ')+1)), 
        '@', 
        replace(name, ' ', ''), 
        '.com'
      ) as email
from accounts
```

2. You may have noticed that in the previous solution some of the company names include spaces, which will certainly not work in an email address. See if you can create an email address that will work by removing all of the spaces in the account name, but otherwise, your solution should be just as in question 1. Some helpful documentation is here.

See answer to 1 above.

3. We would also like to create an initial password, which they will change after their first log in. The first password will be the first letter of the primary_poc's first name (lowercase), then the last letter of their first name (lowercase), the first letter of their last name (lowercase), the last letter of their last name (lowercase), the number of letters in their first name, the number of letters in their last name, and then the name of the company they are working with, all capitalized with no spaces.

```sql
select
	primary_poc,
	concat(
		-- first letter of the primary_poc's first name (lowercase),
		lower(left(primary_poc, 1)),
		-- then the last letter of their first name (lowercase), 
		substr(primary_poc, strpos(primary_poc, ' ')-1, 1),
		-- the first letter of their last name (lowercase),
		lower(substr(primary_poc, strpos(primary_poc, ' ')+1, 1)),
		-- the last letter of their last name (lowercase), 
		right(primary_poc, 1),
		-- the number of letters in their first name, 
		length(substr(primary_poc, 1, strpos(primary_poc, ' ')-1)),
		-- the number of letters in their last name, 
		length(substr(primary_poc, strpos(primary_poc, ' ')+1)),
		-- and then the name of the company they are working with, all capitalized with no spaces
		replace(upper(name), ' ', '')
	) as temp_password
from accounts
```

### Dealing with NULL values

The three methods below are the most common ways to deal with null values in SQL:

1. Coalesce: Allows you to return the first non-null value across a set of columns in a slick, single command. This is a good approach only if a single column’s value needs to be extracted whilst the rest are null.

2. Drop records: Sometimes, if there are null values in records at all, analysts can decide to drop the row entirely. This is not favorable, as it removes data. Data is precious. Think about the reason those values are null. Does it make sense to use COALESCE, drop records, and conduct an imputation.

3. Imputation: Outside of the COALESCE use case, you may want to impute missing values. If so, think about the problem you are trying to solve, and impute accordingly. Perhaps you’d like to be conversative so you take the MIN of that column or the 25th percentile value. Classic imputation values are often the median or mean value of the column.

### COALESCE problems

1. Use COALESCE to fill in the accounts.id column with the account.id for the NULL value for the table created by this query:

```sql
SELECT *
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;
```

Solution:
```sql
SELECT 
    -- you don't need 2 a.id arguments here
    -- you only need 1. i think using 2 here
    -- just makes it more confusing
    COALESCE(a.id, a.id) filled_id, 
    a.name, 
    a.website, 
    a.lat, 
    a.long, 
    a.primary_poc, 
    a.sales_rep_id, 
    o.*
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;
```

2. Use COALESCE to fill in the orders.account_id column with the account.id for the NULL value for the table created by the query in question 1.

```sql
select 
    a.*
    coalesce(o.account_id, a.id) as filled_account_id
    -- other orders columns go here
from accounts a
left join orders o
on a.id = o.account_id
where o.total is null;
```

3. Still referring to the table creatred by the query in question 1, fill in the order table's columns with either data from the order, if it exists, or with a 0.

```sql
SELECT 
    COALESCE(a.id, a.id) filled_id, 
    -- other accounts columns go here
    COALESCE(o.account_id, a.id) account_id, 
    o.occurred_at, 
    COALESCE(o.standard_qty, 0) standard_qty, 
    COALESCE(o.gloss_qty,0) gloss_qty, 
    COALESCE(o.poster_qty,0) poster_qty, 
    COALESCE(o.total,0) total, 
    COALESCE(o.standard_amt_usd,0) standard_amt_usd, 
    COALESCE(o.gloss_amt_usd,0) gloss_amt_usd, 
    COALESCE(o.poster_amt_usd,0) poster_amt_usd, 
    COALESCE(o.total_amt_usd,0) total_amt_usd
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;
```

### Lesson Overview
In this lesson you learned to :

- Clean and re-structure messy data.
- Convert columns to different data types.
- Manipulate NULLs with some handy tricks.

Data Cleaning Steps

1. Review the problem statement.
2. What data do you have? What data do you need?
3. How will you adjust existing data or create new columns?
4. Leverage cleaning techniques to manipulate data.
5. Leverage analysis techniques to determine the solution.

**Normalization**: Standardizing or “cleaning up a column” by transforming it in some way to make it ready for analysis. A few normalization techniques are below:

- Adjusting a column that includes multiple currencies to one common currency
- Adjusting the varied distribution of a column value by transforming it into a z-score
- Converting all price into a common metric (e.g., price per ounce)

