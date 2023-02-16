# Query Examples

1. Find the first 10 web events ever to occur and return the dates that those events occurred and the names of the customers that were involved. Order by order date ascending.

```sql
select a.name, we.occurred_at
from web_events we
join accounts a
on we.account_id = a.id
order by 2
limit 10
```

Answer:
name | occurred_at
-----|-------------
DISH Network	| 12/4/2013 4:18
American Family Insurance Group	| 12/4/2013 4:44
American Family Insurance Group	| 12/4/2013 8:27
DISH Network	| 12/4/2013 18:22
Citigroup	| 12/5/2013 20:17
Citigroup	| 12/5/2013 21:22
Altria Group	| 12/6/2013 2:03
Guardian Life Ins. Co. of America	| 12/6/2013 7:52
Altria Group	| 12/6/2013 11:48
United States Steel	| 12/6/2013 12:31

2. Who were the top 10 customers in terms of web events in 2016?

```sql
select a.name, count(we.occurred_at)
from web_events we
join accounts a
on we.account_id = a.id
where occurred_at between '2015-12-31 23:59:59' and '2017-01-01 00:00:00'
group by 1
order by 2 desc
limit 10
```

Answer:
name | count
-----|-------
Performance Food Group	|38
Merck	|35
Philip Morris International	|34
Colgate-Palmolive	|34
Charter Communications	|33
Lowe's	|33
Cigna	|33
Texas Instruments	|32
American Express	|32
Coca-Cola	|32

3. 