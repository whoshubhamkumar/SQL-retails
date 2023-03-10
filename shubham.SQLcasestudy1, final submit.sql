------------------------------------CREATING DATABASE AND CHECKING TABLES FOR VIEWING ITS DATA----------------------------------
create database case1

select * from [dbo].[prod_cat_info]
select * from [dbo].[Customer]
select * from [dbo].[Transactions]


--------------------------------------------DATA PREPERATION AND UNDERSTANDING-----------------------------------------------------


--Q1 What is the total number of rows in each of the 3 tables in the database?

SELECT COUNT(*) FROM customer
SELECT COUNT(*) FROM prod_cat_info
SELECT COUNT(*) FROM Transactions


--Q2 What is the total number of transactions that have a return?

SELECT COUNT (TRANSACTION_ID) AS COUNT_TRANSACTION_RETURN
FROM TRANSACTIONS
WHERE QTY < 0


--Q3 As you would have noticed, the dates provided across the datasets are not in a correct format. As first steps, pls convert the date variables into valid date formats before proceeding ahead.

select tran_date, convert (varchar(10), tran_date,102) as proper_date_format
from  Transactions


--Q4 What is the time range of the transaction data available for analysis? Show the output in number of days, months and years simultaneously in different columns.

select min(tran_date) from [dbo].[Transactions]
select max(tran_date) from [dbo].[Transactions]
-- the time range range of transaction data is known by the above given statements--


select datediff(day,
    (select min(tran_date) from Transactions),
    (select max(tran_date) from Transactions))

select datediff(month,
    (select min(tran_date) from Transactions),
    (select max(tran_date) from Transactions))

select datediff(year,
    (select min(tran_date) from Transactions),
    (select max(tran_date) from Transactions))


--Q5 Which product category does the sub-category ?DIY? belong to?

select prod_cat, prod_subcat
from prod_cat_info 
where prod_subcat like 'DIY'




------------------------------------------------------------DATA ANALYSIS--------------------------------------------------

--Q1 Which channel is most frequently used for transactions?

select top 1 store_type, COUNT(cust_id) as max_orders
from Transactions
group by Store_type
order by COUNT(cust_id) desc


--Q2 What is the count of Male and Female customers in the database?

select COUNT(gender) as Total , Gender  from Customer
where Gender in ('M','F')
group by Gender


--Q3 From which city do we have the maximum number of customers and how many?

select Top 1 COUNT(customer_id) as Total_customers, city_code from Customer
group by city_code
order by COUNT(customer_id) desc


--Q4 How many sub-categories are there under the Books category?

select prod_cat, count(prod_cat) as Total_subcategory
from prod_cat_info
where prod_cat = 'Books'
group by prod_cat


--Q5 What is the maximum quantity of products ever ordered?

select sum(QTY) as max_products_ordered from Transactions


--Q6 What is the net total revenue generated in categories Electronics and Books?

select sum(total_amt) as Total_revenue 
from Transactions
where prod_cat_code in (3,5)


--Q7 How many customers have >10 transactions with us, excluding returns?

select cust_id, Count(cust_id) as Count_of_Transactions
from Transactions
where Qty >= 0
group by cust_id
having count(cust_id) > 10


--Q8 What is the combined revenue earned from the ?Electronics? & ?Clothing? categories, from ?Flagship stores??

select sum(total_amt) [net revenue] from Transactions t
inner join prod_cat_info p on t.prod_cat_code =p.prod_cat_code
where prod_cat in ('electronics', 'clothing') and Store_type='flagship store'


--Q9 What is the total revenue generated from ?Male? customers in ?Electronics? category? Output should display total revenue by prod sub-cat.

select  prod_subcat_code,SUM(total_amt) [total revenue]
from [Transactions] t 
left join [Customer] c on t.cust_id = c.customer_Id
left join [prod_cat_info] pc on t.prod_cat_code = pc.prod_cat_code 
where t.[prod_cat_code]= '3' and Gender = 'M'
group by prod_subcat_code, prod_subcat, t.prod_cat_code


--Q10 What is percentage of sales and returns by product sub category; display only top 5 sub categories in terms of sales?

select top 5 Round(SUM(cast(total_amt as float)),2) as total_sales, 
P.prod_subcat 
from Transactions as T
INNER JOIN prod_cat_info as P
ON T.prod_subcat_code = P.prod_sub_cat_code
where T.Qty > 0
group by P.prod_subcat
order by total_sales desc


--Q11 For all customers aged between 25 to 35 years find what is the net total revenue generated by these consumers in last 30 days of transactions from max transaction date available in the data?

select sum(t.total_amt) as Net_total_revenue
from (select  t.*, max(t.tran_date) over () as max_tran_date
      from Transactions t
    ) t join Customer c on t.cust_id = c.customer_Id
where t.tran_date >= dateadd(day, -30, t.max_tran_date) and 
      t.tran_date >= dateadd(year, 25, c.DOB) and
      t.tran_date < dateadd(year, 31, c.DOB)


--Q12 Which product category has seen the max value of returns in the last 3 months of transactions?

select TOP 1 prod_cat, sum(-Qty) from Transactions T
inner join prod_cat_info ps on T.prod_cat_code= ps.prod_cat_code and 
T.prod_subcat_code = ps.prod_sub_cat_code
where total_amt< 0 and 
convert(date, tran_date, 103) between Dateadd(month,-3,(select max(convert(date,tran_date,103)) from Transactions)) 
and (select max(convert (date,tran_date,103)) from Transactions)
group by prod_cat
order by 2 Desc


--Q13 Which store-type sells the maximum products; by value of sales amount and by quantity sold?

select top 1 sum(total_amt) [total sales amount], store_type
from Transactions
group by Store_type
order by sum(total_amt) desc

select top 1 sum(qty) [maximum quantity of products], Store_type
from Transactions
group by Store_type
order by sum(qty) desc


--Q14 What are the categories for which average revenue is above the overall average?


SELECT PROD_CAT, AVG(TOTAL_AMT) 
FROM Transactions
INNER JOIN prod_cat_info ON prod_sub_cat_code=prod_sub_cat_code AND prod_sub_cat_code=PROD_SUBCAT_CODE
GROUP BY PROD_CAT
HAVING AVG(TOTAL_AMT)> (SELECT AVG(TOTAL_AMT) FROM Transactions) 


--Q15 Find the average and total revenue by each subcategory for the categories which are among top 5 categories in terms of quantity sold.

select P.prod_subcat as Product_SubCategory, 
avg(total_amt) as Average_Revenue,
sum(total_amt) as Total_Revenue
from Transactions as T
inner join prod_Cat_info as P on T.prod_cat_code = P.prod_cat_code and T.prod_subcat_code = P.prod_sub_cat_code
group by P.prod_subcat

select top 5 P.prod_cat, sum(Qty) as Quantities_sold from
prod_cat_info as P
inner join Transactions as T on P.prod_cat_code = T.prod_cat_code and P.prod_sub_cat_code = T.prod_subcat_code
group by P.prod_cat
order by sum(Qty) desc


------------------------------------------------------------------END------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------