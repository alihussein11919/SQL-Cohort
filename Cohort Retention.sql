use cohort;
--541,909 rows total
--135,080 rows have customer_id null
--406,829 rows have customer_id

with online_retail as(
select 
	*
from 
	dbo.[Online Retail]
where
	CustomerID is not null
	)
,
--397,884 rows where qunaity and unitprice > 0 
quantity_unit_p as(
select
	*
from
	online_retail
where
	Quantity > 0 and UnitPrice > 0)

,
--duplicate check with row_number
dup_check as (
select 
	*,
	ROW_NUMBER() OVER(partition by InvoiceNO, stockcode, quantity order by invoicedate) as duplicate_flag
from	
	quantity_unit_p
)

--392,669 unique rows
--5,215 duplicate rows
--pass the final cleaned data into a local temp table (with one # only)
select 
	*
into
	#on_retail_main
from
	dup_check
where
	duplicate_flag = 1;



--clean data to work with
select
	*
from
	#on_retail_main;

--time based cohort 
--1 signup date/ first activity date + cohort date
-- revenue
--2 activity dates
--3 activity date index
--4 cohort size

--cohort date
select
CustomerID,
min(InvoiceDate) first_purchase_date,

DATEFROMPARTS(
	year(min(InvoiceDate)),
	month(min(InvoiceDate)),
	1
)  as cohort_date

into
	#cohort
from	
	#on_retail_main
group by
	CustomerID

select 
	*
from
	#cohort



--cohort index (number of months that have passed since the customer's first activity)
select *,
(year_diff * 12 + month_diff + 1) as cohort_index
into
	#cohort_retention
from
	(
select
	*,
	(invoice_year - cohort_year) year_diff,
	(invoice_month - cohort_month) month_diff
from
	(
select
	o.*,
	c.cohort_date,
	year(o.InvoiceDate) invoice_year,
	month(o.InvoiceDate) invoice_month,
	year(c.cohort_date) cohort_year,
	month(c.cohort_date) cohort_month
from
	#cohort c
join
	#on_retail_main o
on c.CustomerID = o.CustomerID
) as subquery
) as sub_2



select 
	*
from
	#cohort_retention


---pivot date to see cohort table
select 
	*
into
	#cohort_pivot
from
	(
select distinct 
	CustomerID,
	cohort_date,
	cohort_index
from
	#cohort_retention
) tt

pivot(count(customerID)

for cohort_index in 
		(
		[1],
		[2],
		[3],
		[4],
		[5],
		[6],
		[7],
		[8],
		[9],
		[10],
		[11],
		[12],
		[13])
)as pivot_table
order by cohort_date


select
	*
from
	#cohort_pivot
order by
	cohort_date


select
	
	([1] / [1] * 100 * 1.0) as [1],
	1.0 * [2] / [1] * 100 as [2],
	1.0 * [3] / [1] * 100  as [3],
	1.0 *[4] / [1] * 100  as [4],
	1.0 *[5] / [1] * 100  as [5],
	1.0 *[6] / [1] * 100  as [6],
	1.0 *[7] / [1] * 100  as [7],
	1.0 *[8] / [1] * 100  as [8],
	1.0 *[9] / [1] * 100  as [9],
	1.0 *[10] / [1] * 100  as [10],
	1.0 *[11] / [1] * 100  as [11],
	1.0 *[12] / [1] * 100  as [12],
	1.0 *[13] / [1] * 100  as [13]
from
	#cohort_pivot
order by
	cohort_date 



