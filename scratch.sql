/* Total orders in region with best total sales problem */
select sub1.region_name, sub1.total_orders
from (
  select r.name as region_name, 
         count(*) as total_orders, 
         sum(total_amt_usd) as total_sales
  from orders o
  join accounts a
  on o.account_id = a.id
  join sales_reps sr
  on a.sales_rep_id = sr.id
  join region r
  on sr.region_id = r.id
  group by 1
  ) as sub1
join (
    select max(sub.total_sales) as max_sales
    from (
        select r.name as region_name,  
               sum(total_amt_usd) as total_sales
        from orders o
        join accounts a
        on o.account_id = a.id
        join sales_reps sr
        on a.sales_rep_id = sr.id
        join region r
        on sr.region_id = r.id
        group by 1
    ) as sub
) as sub2
on sub1.total_sales = sub2.max_sales


/* Sales rep problem */
select sub1.sr_name, sub2.reg_name, sub2.max_sales
from (
    select sr.id as sr_id, 
           sr.name as sr_name, 
           r.name as reg_name, 
           sum(o.total_amt_usd) as total_sales
    from sales_reps sr
    join region r
    on sr.region_id = r.id
    join accounts a
    on a.sales_rep_id = sr.id
    join orders o
    on o.account_id = a.id
    group by 1,2,3
    ) as sub1
join (
    select sub.reg_name, 
           max(sub.total_sales) as max_sales
	from (
        select sr.id as sr_id, 
               sr.name as sr_name, 
               r.name as reg_name, 
               sum(o.total_amt_usd) as total_sales
        from sales_reps sr
        join region r
        on sr.region_id = r.id
        join accounts a
        on a.sales_rep_id = sr.id
        join orders o
        on o.account_id = a.id
        group by 1,2,3
        ) as sub
	group by 1
    ) as sub2
on sub1.reg_name = sub2.reg_name 
and sub1.total_sales = sub2.max_sales

/* for problem 3 */
select a.name, 
       sum(o.total) as total_all_types, 
       sum(o.standard_qty) as total_standard
from accounts a
join orders o
on o.account_id = a.id
group by 1
having sum(o.total) > (
                       select max(sub.total_standard)
                       from (
                             select sum(o.standard_qty) as total_standard
                             from orders o
                       ) as sub
                      )
order by 3 desc

-- for problem 4 in 4.17 - 

-- Geta the amount of money spent by the company that spent the most on paper
select max(total_spent)
from (
	select a.name as account_name, 
	   	   sum(o.total_amt_usd) as total_spent
	from accounts a
	join orders o
	on o.account_id = a.id
	group by 1
	) as sub

-- Get the account, channels, and count per channel of events 
select a.name as account_name,
	we.channel as channel,
	count(*)
from accounts a
join web_events we
on we.account_id = a.id
group by 1, 2