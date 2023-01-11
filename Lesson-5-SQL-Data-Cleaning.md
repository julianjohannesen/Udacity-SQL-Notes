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
- Position: Returns the position of the first occurrence of a substring in a string
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

#### Use Case: When two or more columns serve as a unique identifier

Methods:
- Concat(string1, string2, string3, ...)

#### Use Case: Converting data into specific data types

Methods:
- Cast(expression AS datatype)

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
) AS PVT)
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


