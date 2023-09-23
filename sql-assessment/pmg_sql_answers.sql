/* 
Author: Wen Tao Lin
This is the SQL file for PMG's SQL Assessment.
Bonus Question is completed at the bottom
*/

-- Q1: Write a query to get the sum of impressions by day
SELECT date, sum(impressions) as total_impressions
FROM marketing_data
GROUP BY date
ORDER BY date;

-- Q2: Write a query to get the top three revenue-generating states in order of best to worst. 
-- How much revenue did the third best state generate?
-- A2: The best state, Ohio, generated a revenue of $37,577, assuming the revenue is in the unit of USD.
SELECT state, sum(revenue) as total_revenue
FROM website_revenue
GROUP BY state
ORDER BY total_revenue DESC;

-- Q3: Write a query that shows total cost, impressions, clicks, and revenue of each campaign. 
-- Make sure to include the campaign name in the output.
SELECT name, total_cost, total_impressions, total_clicks, total_revenue
FROM
	(SELECT name, round(sum(cost), 2) as total_cost, sum(impressions) as total_impressions, sum(clicks) as total_clicks
	FROM campaign_info JOIN marketing_data on id = campaign_id
    GROUP BY name) as marketing
    JOIN
    (SELECT name, sum(revenue) as total_revenue
	FROM campaign_info JOIN website_revenue on id = campaign_id
    GROUP BY name) as website
    USING (name)
ORDER BY name;

-- Q4: Write a query to get the number of conversions of Campaign5 by state.
-- Which state generated the most conversions for this campaign?
-- A4: Based on the query output, Georgia (GA) generated the most number conversions for Campaign5, with a total of 672 conversions
SELECT geo, sum(conversions) as total_num_conversions
FROM campaign_info JOIN marketing_data on id = campaign_id
WHERE name = 'Campaign5' 
GROUP BY geo
ORDER BY total_num_conversions DESC;

-- Q5: In your opinion, which campaign was the most efficient, and why?
-- A5: I believe Campaign3 was the most efficient because it generated the most profits ($48175.87) as well as the highest conversion rate (0.3068)
-- which is over $3000 more than the 2nd highest profit but almost equivalent to the 2nd highest conversion rate.

-- comparing total profit (idea from Q3)
SELECT name, (total_revenue - total_cost) as total_profit
FROM
	(SELECT name, round(sum(cost), 2) as total_cost, sum(impressions) as total_impressions, sum(clicks) as total_clicks
	FROM campaign_info JOIN marketing_data on id = campaign_id
    GROUP BY name) as marketing
    JOIN
    (SELECT name, sum(revenue) as total_revenue
	FROM campaign_info JOIN website_revenue on id = campaign_id
    GROUP BY name) as website
    USING (name)
ORDER BY total_profit DESC;

-- comparing total number of conversions (idea from Q4)
SELECT name, (sum(conversions) / sum(clicks)) as conversion_rate
FROM campaign_info JOIN marketing_data on id = campaign_id
GROUP BY name
ORDER BY conversion_rate DESC;

-- Q6: Write a query that showcases the best day of the week (e.g., Sunday, Monday, Tuesday, etc.) to run ads.
/* The query below calculate the conversion rate and the total profit for each day of the week based on the given day.
It allows the decision-maker to decide which day of the week is the best to run ads since a good outcome would
require a mixture of high conversion rate as well as high profit. In the example dataset given, Friday has the highest conversion rate
but it also has the lowest total profit (~37k less than highest). Meanwhile, Monday has the largest profit, yet the 3rd lowest conversion rate.
So the best day of the week to run ads depends on what the decision-maker values more between these two statistics. 

However, in the case of our given data, I think the conversion rate should be weighted more than the total profit due to the small sample size.
A small sample size could cause an inbalance in the distribution of the day of the week. And this inbalance will significantly affect the total profit.
On the other hand, the conversion rate is not affected as much because it is a ratio.
*/

SELECT day_of_week, (total_conversions / total_clicks) as conversion_rate, (total_revenue - total_cost) as total_profit
FROM
	(SELECT 
		CASE
			WHEN DAYOFWEEK(date) = 1 THEN 'Sunday'
			WHEN DAYOFWEEK(date) = 2 THEN 'Monday'
			WHEN DAYOFWEEK(date) = 3 THEN 'Tuesday'
			WHEN DAYOFWEEK(date) = 4 THEN 'Wednesday'
			WHEN DAYOFWEEK(date) = 5 THEN 'Thursday'
			WHEN DAYOFWEEK(date) = 6 THEN 'Friday'
			WHEN DAYOFWEEK(date) = 7 THEN 'Saturday'
		END AS day_of_week,
        round(sum(cost), 2) as total_cost, sum(clicks) as total_clicks, sum(conversions) as total_conversions
	FROM marketing_data
    GROUP BY day_of_week) as marketing
    JOIN
    (SELECT 
		CASE
			WHEN DAYOFWEEK(date) = 1 THEN 'Sunday'
			WHEN DAYOFWEEK(date) = 2 THEN 'Monday'
			WHEN DAYOFWEEK(date) = 3 THEN 'Tuesday'
			WHEN DAYOFWEEK(date) = 4 THEN 'Wednesday'
			WHEN DAYOFWEEK(date) = 5 THEN 'Thursday'
			WHEN DAYOFWEEK(date) = 6 THEN 'Friday'
			WHEN DAYOFWEEK(date) = 7 THEN 'Saturday'
		END AS day_of_week,
        sum(revenue) as total_revenue
	FROM website_revenue
    GROUP BY day_of_week) as website
    using(day_of_week)
    ORDER by conversion_rate DESC;
