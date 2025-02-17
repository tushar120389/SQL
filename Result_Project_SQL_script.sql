/* Task 1: Identifying the Top Branch by Sales Growth Rate (6 Marks)
Walmart wants to identify which branch has exhibited the highest sales growth over 
time. 
Analyze the total sales for each branch and compare the growth rate across months to 
find the top performer.*/

WITH monthly_sales AS (
    -- Calculate the total sales for each branch per month
    SELECT 
        Branch,
        month(Date) AS month,  -- Extract month
        SUM(Total) AS total_sales
    FROM walmartsales_dataset
    GROUP BY Branch, month
),
monthly_growth AS (
    -- Calculate the growth rate for each branch month-over-month
    SELECT 
        Branch,
        month,
        total_sales,
        LAG(total_sales) OVER (PARTITION BY Branch ORDER BY month) AS previous_month_sales,
        (total_sales - LAG(total_sales) OVER (PARTITION BY Branch ORDER BY month)) / 
        LAG(total_sales) OVER (PARTITION BY Branch ORDER BY month) * 100 AS growth_rate
    FROM monthly_sales
)
-- Select the branch with the highest average growth rate across all months
SELECT 
    Branch,
    AVG(growth_rate) AS avg_growth_rate
FROM monthly_growth
GROUP BY Branch
ORDER BY avg_growth_rate DESC



/*Task 2: Finding the Most Profitable Product Line for Each Branch (6 Marks)
Walmart needs to determine which product line contributes the highest profit to 
each branch.
The profit margin should be calculated based on the difference between the 
gross income and cost of goods sold.*/

-- we find gross_income column in dataset as profit margin as it is the difference 
-- between Total(income) and cogs

SELECT Product_line,Branch, SUM(gross_income) as Highest_Profit,
RANK() OVER (PARTITION BY Product_line ORDER BY SUM(gross_income) desc) as rnk
FROM walmartsales_dataset
GROUP BY Product_line, Branch 
ORDER BY rnk
LIMIT 6;


/*Task 3: Analyzing Customer Segmentation Based on Spending (6 Marks)
Walmart wants to segment customers based on their average spending behavior. 
Classify customers into three tiers: High, Medium, and Low spenders based on 
their total purchase amounts.*/
        

SELECT SUM(Total) as Total_Purchase_Amount,Customer_ID,
CASE 
WHEN SUM(Total)>23000 THEN 'High_Spender'
WHEN SUM(Total)>21000 THEN 'Medium_Spender'
ELSE 'Low_Spender'
END AS Spender_Level
FROM walmartsales_dataset
GROUP BY Customer_ID
ORDER BY SUM(Total) desc


/*Task 4: Detecting Anomalies in Sales Transactions (6 Marks)
Walmart suspects that some transactions have unusually high or low sales compared to 
the average for the product line. Identify these anomalies.*/

WITH ProductLineStats AS (
    -- Calculate the mean for each ProductLine
    SELECT 
        Product_line,
        AVG(Total) AS avg_total
    FROM 
        walmartsales_dataset
    GROUP BY 
        Product_line
)

-- Select transactions where the Total is outside the range
SELECT 
    w.Product_line,
    w.Total,
    p.avg_total,
    CASE 
        WHEN w.Total > p.avg_total*1.80 THEN 'High Anomaly'
        WHEN w.Total < p.avg_total*0.20 THEN 'Low Anomaly'
        ELSE 'Normal'
    END AS Anomaly_Status
FROM 
    walmartsales_dataset w
JOIN 
    ProductLineStats p 
    ON w.Product_line = p.Product_line


/*Task 5: Most Popular Payment Method by City (6 Marks)
Walmart needs to determine the most popular payment method in each city to 
tailor marketing strategies.*/

SELECT count(Payment),Payment as Popular_Payment_Method, City 
FROM walmartsales_dataset
GROUP BY city, payment
ORDER BY count(payment) desc,Payment,City
LIMIT 3;


/*Task 6: Monthly Sales Distribution by Gender (6 Marks)
Walmart wants to understand the sales distribution between male and female 
customers on a monthly basis.*/

SELECT Gender,count(Gender),month(Date) 
FROM walmartsales_dataset
GROUP BY Gender, month(Date)
ORDER BY month(Date)


/* Task 7: Best Product Line by Customer Type (6 Marks)
Walmart wants to know which product lines are preferred by 
different customer types(Member vs. Normal).*/

SELECT Product_line,Customer_type,Count(Customer_type)
FROM walmartsales_dataset
GROUP BY Product_line,Customer_type
ORDER BY Product_line


/* Task 8: Identifying Repeat Customers (6 Marks)
Walmart needs to identify customers who made repeat purchases within a specific time
frame (e.g., within 30 days).*/

SELECT count( distinct Date) as Days_Interval,
count(Invoice_ID) as Repeat_Purchase_Count ,
Customer_ID
FROM walmartsales_dataset
GROUP BY Customer_ID
ORDER BY count(distinct Date) asc -- identifying repeat purchases in less no. of days


/* Task 9: Finding Top 5 Customers by Sales Volume (6 Marks)
Walmart wants to reward its top 5 customers who have generated the most sales 
Revenue.*/
      
SELECT SUM(Total) as Total_Sales_Revenue,Customer_ID
FROM walmartsales_dataset
GROUP BY Customer_ID
ORDER BY SUM(Total) desc
LIMIT 5;


/* Task 10: Analyzing Sales Trends by Day of the Week (6 Marks)
Walmart wants to analyze the sales patterns to determine which day of the week
brings the highest sales.*/

SELECT SUM(Total) as Sales,dayname(Date) as Day 
FROM walmartsales_dataset
GROUP BY dayname(Date)
ORDER BY SUM(Total) desc
