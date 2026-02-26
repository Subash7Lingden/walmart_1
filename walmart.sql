--Q1. What are the different payment methods, and how many transactions and items were sold with each method?
SELECT 
	payment_method,
	COUNT(*) as number_of_payment,
	SUM(quantity) as total_item_sold
FROM walmart
GROUP BY 1


--Q2. Question: Which category received the highest average rating in each branch?

SELECT 
	*
FROM
(	SELECT
		branch,
		category,
		AVG(rating) as averge_rating,
		RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) as rn
	FROM walmart
	GROUP BY 1,2
	ORDER BY 1, 3 DESC
) 
WHERE rn= 1


--Q3 What is the busiest day of the week for each branch based on transaction volume?
SELECT 
	*
FROM
	(SELECT 
		branch,
		TO_CHAR(TO_DATE(date, 'DD/MM/yy'), 'day') as day_name,
		COUNT(*) as number_of_transaction,
		RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rn
	FROM walmart
	GROUP BY 1,2
)
WHERE RN = 1
--ORDER BY 1, 3 DESC


--Q4 Calculate the total quantity of items sold per payment method, list the payment method and total quantity.
SELECT 
	payment_method,
	SUM(quantity) as total_item_sold
FROM walmart
GROUP BY 1

--Q5 Determine the average, minimum, and maximum rating of category for each city.
-- list the city, average_rating, min_raitn, max_rating

SELECT 
	city,
	category,
	MIN(rating),
	MAX(rating),
	AVG(rating)
FROM walmart
GROUP BY 1,2

-- Q6 Calculate the total profit for each category by considering the total_profit as (unit_price * quantity * profit_margin)
-- list the category and total profit ordered from highest to lowest profit.
SELECT
	category,
	SUM(total) as total_revenue,
	SUM(total * profit_margin) as total_profit
FROM walmart
GROUP BY 1
ORDER BY 2 DESC


--Q7 Determine the most common payment method for each branch.
-- dispaly the branch and prefered payment_method
SELECT 
	*
FROM
(	SELECT 
		branch,
		payment_method,
		COUNT(*) as total_transaction,
		RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rn
	FROM walmart
	GROUP BY 1,2
)
WHERE RN =1


-- Q8 Categorise sales into 'Morning', 'Afternoon' and 'Evening'
-- Find out each of the shifts and  the number of invoices.
SELECT 
	branch,
	CASE 
		WHEN EXTRACT(HOUR FROM(time::time)) < 12 THEN 'Morning' -- (time::time ) Cconverting time text form into time format
		WHEN EXTRACT(HOUR FROM(time::time)) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END as shif_time,
	COUNT(*) as number_of_invoice
FROM walmart
GROUP BY 1, 2
ORDER BY 1,3 DESC


--Q9 Identify 5 branches with the highest decrease ratio in revenue
-- compare to last year (current year 2023 last year 2023)
-- Revenue decrease ratio = (last year revenu - current year revenue)/ last year revenue *100

SELECT *,
	EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) as formated_date  
FROM walmart

WITH revenue_2022
AS
(	SELECT 
		branch,
		SUM(total) revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022
	GROUP BY 1
),
revenue_2023 
AS
(
	SELECT 
		branch,
		SUM(total) revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
	GROUP BY 1
)

SELECT
	ls.branch,
	ls.revenue as last_year_revenue,
	cs.revenue as current_year_revenue,
	ROUND(
		(ls.revenue - cs.revenue)::numeric/ls.revenue::numeric *100,
		2) as revenue_decrease_ratio
FROM revenue_2022 as ls
JOIN revenue_2023 as cs
ON ls.branch = cs.branch
WHERE ls.revenue > cs.revenue
ORDER BY 4 DESC
LIMIT 5









