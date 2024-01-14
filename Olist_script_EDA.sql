/*
INTRODUCTION

	- This dataset is provided by Olist, the largest department store in Brazilian marketplaces. Olist connects small businesses to channels.
		Those merchants are able to sell their products through the Olist Store and ship them directly to the customers using Olist logistics partners.
	- This is real data, and it has been anonymized and sampled from the original dataset.
    - This dataset provides information of 100k orders from 2017-2018 including price, payment, freight performance, customer location, product attributes, and vendors.

******************************
SECTION 1: SALES ANALYSES
******************************

1.1) Quarterly order trends of product sales

	- We would like to see the quarterly trending product order totals to get an overall picture of sales history
    
OUTPUT
	- We see steady growth of orders all the way until Q2 of 2018, where sales begin to decrease.
		We may want to investigate this sales trend reversal to identify potential causes.
	- This signifies great business health, but we will need to perform further analyses to identify
		specific causes of the positive and negative trends we see here.
*/

SELECT
		YEAR(purchase_datetime) AS year,
		QUARTER(purchase_datetime) AS quarter,
		COUNT(DISTINCT order_id) AS orders
FROM orders
WHERE purchase_datetime BETWEEN '2017-01-01' AND '2018-09-30'
GROUP BY 1, 2
ORDER BY year ASC;

	year	quarter		orders
	2017	1			5262
	2017	2			9349
	2017	3			12642
	2017	4			17848
	2018	1			21208
	2018	2			19979
	2018	3			12820
;

/* 
1.2) Monthly order trends

	- Can we break out the total order trends by month, and view the previous month totals and value differences as well?
    
OUTPUT
	- We are able to see more granular data in the order trends per month. A few key points of interest might be
		the signficant decrease of 2400 orders in December of 2017, then the steady decrease in sales throughout 2018.
        We need to determine if that decrease happened as a result of seasonality or perhaps something related to operations.
*/

CREATE TEMPORARY TABLE monthly_orders
SELECT
			YEAR(purchase_datetime) AS year,
			MONTH(purchase_datetime) AS month,
			COUNT(order_items.order_id) AS total_orders
	FROM orders
		JOIN order_items
			ON orders.order_id = order_items.order_id
	WHERE purchase_datetime BETWEEN '2017-01-01' AND '2018-08-30'
	GROUP BY 1,2
	ORDER BY 1;


CREATE TEMPORARY TABLE monthly_prev_orders
SELECT
		year,
		month,
		total_orders,
		LAG(total_orders) OVER(ORDER BY year) as prev_month_orders
FROM monthly_orders;

SELECT
		year,
        month,
        total_orders,
        prev_month_orders,
        total_orders - prev_month_orders AS orders_change
FROM monthly_prev_orders;
        
	year	month	total_orders	prev_month_orders	orders_change
	2017	1		955		
	2017	2		1951			955					996
	2017	3		3000			1951				1049
	2017	4		2684			3000				-316
	2017	5		4136			2684				1452
	2017	6		3583			4136				-553
	2017	7		4519			3583				936
	2017	8		4910			4519				391
	2017	9		4831			4910				-79
	2017	10		5322			4831				491
	2017	11		8665			5322				3343
	2017	12		6308			8665				-2357
	2018	1		8208			6308				1900
	2018	2		7672			8208				-536
	2018	3		8217			7672				545
	2018	4		7975			8217				-242
	2018	5		7925			7975				-50
	2018	6		7078			7925				-847
	2018	7		7092			7078				14
	2018	8		7248			7092				156

;

/*
1.3) Product shipping time trends

	- Did the average number of estimated shipping days go down over time?
		This will give us a baseline measurement of our shipping department forecasting
        and how we expect to increase our shipping performance over time.
        
OUTPUT
	- Average estimate delivery days shows consistent decrease over each quarter.
    - This is a great sign that our shipping department expects increased performance over time,
		but we'll need to evaluate whether those goals were actually met.
*/

SELECT
		YEAR(purchase_datetime) AS year,
		QUARTER(purchase_datetime) AS quarter,
		ROUND(AVG(DATEDIFF(estimated_delivery_date, purchase_datetime)),1) AS avg_estimated_delivery_days
FROM orders
WHERE purchase_datetime BETWEEN '2017-01-01' AND '2018-09-30'
GROUP BY 1, 2
ORDER BY year ASC;

	year	quarter		avg_estimated_delivery_days
	2017	1			30.2
	2017	2			25.7
	2017	3			23.7
	2017	4			24.9
	2018	1			24.9
	2018	2			25.3
	2018	3			18.0
;

/*
1.4) Actual shipping time

	- Did we actually hit our shipping time goals better over time?
    
OUTPUT
	- Yes, we beat our estimate shipping time consistently by 1-2 weeks.
    - Now we may want to look at ways to reduce shipping costs, without sacrificing performance.
*/

SELECT
		YEAR(purchase_datetime) AS year,
		QUARTER(purchase_datetime) AS quarter,
		ROUND(AVG(DATEDIFF(estimated_delivery_date, delivered_customer_datetime)),1) AS avg_days_exceeded_goal
FROM orders
WHERE purchase_datetime BETWEEN '2017-01-01' AND '2018-09-30'
GROUP BY 1, 2
ORDER BY year ASC;

	year	quarter		avg_days_exceeded_goal
	2017	1			16.9
	2017	2			13.1
	2017	3			12.3
	2017	4			10.7
	2018	1			9.2
	2018	2			14.6
	2018	3			9.8
;

/*
1.5) Product order details

	- What is the total revenue and freight value for each product? Can we display this data next to individual product details?

OUTPUT
	- This is an abbreviated view of the output. This view allows us to compare individual product details next to
		the aggregated values for price and freight value.
*/

SELECT
		order_id,
		product_id,
		price,
		freight_value,
		COUNT(*) OVER(PARTITION BY product_id) AS total_product_purchased,
		SUM(price) OVER(PARTITION BY product_id) AS total_product_rev,
		SUM(freight_value) OVER(PARTITION BY product_id) AS total_product_freight_value
FROM order_items
ORDER BY 5 DESC
LIMIT 5;

	order_id	product_id	price	freight_value	total_product_purchased		total_product_rev	total_product_freight_value
	bc0d5d1faf	aca2eb7d00	69.90	12.43			527							37608.90			7211.86
	be00589ef6	aca2eb7d00	69.90	13.08			527							37608.90			7211.86
	bfd2cf5a99	aca2eb7d00	75.00	13.08			527							37608.90			7211.86
	c0834ece62	aca2eb7d00	69.90	12.43			527							37608.90			7211.86
	c0834ece62	aca2eb7d00	69.90	12.43			527							37608.90			7211.86
;

/*
******************************
SECTION 2: CUSTOMER/SALES ANALYSES
******************************
	- There are a total of 27 states and 4,119 cities in which the customers reside
    
2.1) Sales by geography

	- What are the top 10 states and cities of customers with the most product sales?

OUTPUT
	- This gives us a nice overview of sales distributed by states and cities

*/

SELECT COUNT(DISTINCT(city)) FROM customers;
SELECT COUNT(DISTINCT(state)) FROM customers;

SELECT
		state,
		COUNT(order_id) AS total_orders,
		ROW_NUMBER() OVER(ORDER BY COUNT(order_id) DESC) as rnk
FROM orders
	JOIN customers
		ON orders.customer_id = customers.customer_id
GROUP BY 1
ORDER BY total_orders DESC
LIMIT 10;

	state	total_orders	rnk
	SP		41746			1
	RJ		12852			2
	MG		11635			3
	RS		5466			4
	PR		5045			5
	SC		3637			6
	BA		3380			7
	DF		2140			8
	ES		2033			9
	GO		2020			10

SELECT
		city,
		COUNT(order_id) AS total_orders,
		ROW_NUMBER() OVER(ORDER BY COUNT(order_id) DESC) as rnk
FROM orders
	LEFT JOIN customers
		ON orders.customer_id = customers.customer_id
GROUP BY 1
ORDER BY total_orders DESC
LIMIT 10;

	city			total_orders	rnk
	sao paulo		15540			1
	rio de janeiro	6882			2
	belo horizonte	2773			3
	brasilia		2131			4
	curitiba		1521			5
	campinas		1444			6
	porto alegre	1379			7
	salvador		1245			8
	guarulhos		1189			9
	sao bernardo	938				10
;

/*
2.2) Comparitive revenues of states and cities

	- We want to see the total revenue of each city compared to the revenue of each state in which they are located.
		Also rank the cities in order of highest revenue.

OUTPUT
	- This allows us to see the top performing cities in each state, and to compare the total revenue of the city within each state.
    - We may want to focus our resources to the top performing cities and potentially specific products that sell best in each city.
*/

SELECT
		state,
		city,
		total_rev_city,
		SUM(total_rev_city) OVER(PARTITION BY state) AS total_rev_state,
		RANK() OVER(PARTITION BY state ORDER BY total_rev_city DESC) AS city_rev_ranking
FROM (
	SELECT
			state,
			city,
			ROUND(SUM(price),0) AS total_rev_city
	FROM customers
		JOIN orders
			ON customers.customer_id = orders.customer_id
		JOIN order_items
			ON orders.order_id = order_items.order_id
	GROUP BY 1, 2
	LIMIT 10) AS state_city_rev;
    
	state	city				total_rev_city	total_rev_state		city_rev_ranking
	MG		uberaba				28688			35850				1
	MG		para de minas		7162			35850				2
	RJ		campos dos goy		34660			34660				1
	SP		santos				98777			240111				1
	SP		piracicaba			52308			240111				2
	SP		praia grande		39158			240111				3
	SP		atibaia				20913			240111				4
	SP		varzea paulista		10780			240111				5
	SP		jandira				8260			240111				6
	SP		santa fe do sul		3995			240111				7
;

/*
******************************
SECTION 3: PRODUCT ANALYSES
******************************

3.1) Product categories

	- There are 72 total product categories
    - What are top 10 product categories with the most orders?  
    
OUTPUT
	- The highest performing category, bed_bath_table, significantly outperforms the others.
	- We see a steady decline in performance from #2 until #10. This is a good sign as our 
        sales are distributed well across multiple product categories.
	- We may want to break
        this analysis out further by state & city in order to focus resources in the right areas.
*/

SELECT COUNT(DISTINCT category_name) FROM products;

SELECT
		category_name,
        COUNT(order_id) AS total_orders
FROM order_items
	JOIN products
		ON order_items.product_id = products.product_id
GROUP BY 1
ORDER BY total_orders DESC
LIMIT 10;

	category_name			total_orders
	bed_bath_table			11037
	health_beauty			9627
	sports_leisure			8635
	furniture_decor			8315
	computers_accessories	7812
	housewares				6956
	watches_gifts			5977
	telephony				4540
	garden_tools			4343
	auto					4222
;

/*
3.2) Product categories by state
	- What are the top 3 selling categories in each state?

OUTPUT
	- This data gives us direction as to which product categories to invest more resources
		within each state, thus increasing our overall sales.
*/

SELECT * FROM (
	SELECT
			state,
			category_name,
			total_orders,
			DENSE_RANK() OVER(PARTITION BY state ORDER BY total_orders DESC) AS category_rank
	FROM (
			SELECT
					state,
					category_name,
					COUNT(order_items.order_id) AS total_orders
			FROM order_items
				JOIN products
					ON order_items.product_id = products.product_id
				JOIN orders
					ON order_items.order_id = orders.order_id
				JOIN customers
					ON orders.customer_id = customers.customer_id
			GROUP BY 1, 2) AS state_categories) AS state_categories_2
WHERE category_rank BETWEEN 1 AND 3
LIMIT 10;

	state	category_name			total_orders	category_rank
	AC		furniture_decor			12				1
	AC		computers_accesories	9				2
	AC		sports_leisure			9				2
	AC		health_beauty			7				3
	AL		health_beauty			62				1
	AL		computers_accessories	41				2
	AL		watches_gifts			36				3
	AM		health_beauty			20				1
	AM		computers_accessories	17				2
	AM		telephony				15				3




/* 
3.3) Seasonality of product categories

	- Do certain product categories sell differently within each season?
    - Below are the relative seasons in Brazil
		- Summer: Dec to Feb
		- Fall: Mar to May
		- Winter: Jun to Aug
		- Spring: Sept to Nov
        
OUTPUT
	- Surpisingly not much seasonality for top categories. Perhaps individual products would have seasonality,
		which would require a more granular analyses.
*/

SELECT
		category_name,
		COUNT(DISTINCT CASE WHEN MONTH(purchase_datetime) IN (12,1,2) THEN order_items.order_id ELSE NULL END) AS orders_summer,
		COUNT(DISTINCT CASE WHEN MONTH(purchase_datetime) IN (3,4,5) THEN order_items.order_id ELSE NULL END) AS orders_fall,
		COUNT(DISTINCT CASE WHEN MONTH(purchase_datetime) IN (6,7,8) THEN order_items.order_id ELSE NULL END) AS orders_winter,
		COUNT(DISTINCT CASE WHEN MONTH(purchase_datetime) IN (9,10,11) THEN order_items.order_id ELSE NULL END) AS orders_spring
FROM products
	JOIN order_items
		ON products.product_id = order_items.product_id
	JOIN orders
		ON orders.order_id = order_items.order_id
WHERE category_name IN ('bed_bath_table', 'health_beauty', 'sports_leisure', 'furniture_decor', 'computers_accessories')
GROUP BY 1;

	category_name			orders_summer	orders_fall		orders_winter	orders_spring
	bed_bath_table			1945			2674			3015			1725
	computers_accessories	1765			2052			1916			942
	furniture_decor			1491			2034			1768			1140
	health_beauty			1829			2567			3136			1263
	sports_leisure			1812			2290			2197			1415
;


/*
******************************
SECTION 4: MARKETING FUNNEL ANALYSES
******************************

4.1) Marketing Qualified Leads (MQL)

	- An MQL is a particular vendor that has requested to sell their product on the Olist Store.
    - There are 8k Marketing Qualified Leads (MQLs) that requested contact between Jun. 1st 2017 and Jun 1st 2018.
	- What's the distribution of MQLs according to source origin?
    
OUTPUT
	- Great news that vendors reach out most through organic search! This suggests that the Olist Store platform has great brand recognition
	- The fact that Social is third highest also suggests good brand recognition. This is a great channel to scale up since it's low cost.
	- The Unknown category is quite large and we would want to investigate these particular lead sources.
*/

SELECT
		origin,
		COUNT(mql_id) AS number_leads
FROM mql
GROUP BY 1
ORDER BY 2 DESC;
	
	origin				number_leads
	organic_search		2296
	paid_search			1586
	social				1350
	unknown				1159
	direct_traffic		499
	email				493
	referral			284
	other				150
	display				118
	other_publicities	65
;

/*

4.2) Closed deals

	- MQLs turn into closed deals when the vendor signs a contract with the Olist Store.
    - MQLs are categorized by three main characteristics: 1) business segment, 2) lead type, 3) business type
    
    - What are the top 15 most common vendor types that turn into closed deals?
    
OUTPUT
	
	- We see that resellers are by far more likely to sign up than manufacturers
	- The business segments seems fairly spread out, and no significant leaders
     - Here we can adjust our sourcing model and focus our resources on attracting the vendors that will most likely close.
*/

SELECT
		business_segment,
		lead_type,
		business_type,
		COUNT(seller_id) AS number_closed_deals
FROM closed_deals
GROUP BY 1,2,3
ORDER BY 4 DESC
LIMIT 15;

	business_segment				lead_type			business_type		number_closed_deals
	car_accessories					online_medium		reseller			32
	health_beauty					online_medium		reseller			31
	audio_video_electronics			online_medium		reseller			28
	home_decor						online_medium		manufacturer		27
	household_utilities				online_medium		reseller			19
	home_decor						online_medium		reseller			17
	construction_tools_house		online_medium		reseller			17
	health_beauty					online_big			reseller			13
	computers						online_medium		reseller			13
	car_accessories					online_big			reseller			13
	construction_tools_house		online_big			reseller			12
	car_accessories					offline				reseller			11
	home_decor						online_big			reseller			10
	audio_video_electronics			online_big			reseller			10
	sports_leisure					online_medium		reseller			10
;


/*

4.3) Lead source vs. closed deals

	- Which lead sources have the highest conversion rate of becoming closed deals?
    
OUTPUT
	- The highest conversion rate at 11% + is organic search, paid search and direct traffic.
		Since organic and paid search also have the highest lead volume, we certainly want
        to focus our marketing resources on those channels.
	- Social media has glaringly lower conversion rate at 5.5%. Although social media produces
		a large amount of leads, they convert about half as likely as organic and paid search.
*/

SELECT
		origin,
		COUNT(mql.mql_id) AS number_leads,
		COUNT(closed_deals.mql_id) AS closed_deals,
		COUNT(closed_deals.mql_id) / COUNT(mql.mql_id) AS conv_rate
FROM mql 
	LEFT JOIN closed_deals
		ON closed_deals.mql_id = mql.mql_id
GROUP BY 1
ORDER BY 2 DESC;

	origin				number_leads	closed_deals	conv_rate
	organic_search		2296			271				0.1180
	paid_search			1586			195				0.1230
	social				1350			75				0.0556
	unknown				1159			193				0.1665
	direct_traffic		499				56				0.1122
	email				493				15				0.0304
	referral			284				24				0.0845
	other				150				4				0.0267
	display				118				6				0.0508
	other_publicities	65				3				0.0462
;
