create database music_data;
USE music_data;

/*	Question Set 1  */

/* Q1: Who is the senior most employee based on job title? */

SELECT title, last_name, first_name 
FROM employee
ORDER BY levels DESC
LIMIT 1;

/* Q2: Which countries have the most Invoices? */

SELECT COUNT(*) AS c, billing_country 
FROM invoice
GROUP BY billing_country
ORDER BY c DESC;


/* Q3: What are top 3 values of total invoice? */

SELECT total 
FROM invoice
ORDER BY total DESC
LIMIT 1;




SELECT billing_country,
       COUNT(customer_id) as no_of_invoices
       FROM invoice
       GROUP BY  billing_country
       ORDER BY no_of_invoices DESC;
       
       SELECT total FROM invoice
       ORDER BY total desc
       LIMIT 3;

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

SELECT billing_city, sum(total) as revenue_generated
 FROM invoice
 GROUP BY billing_city
 ORDER BY revenue_generated DESC
 LIMIT 1;
 
/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

SELECT c.first_name, c.customer_id, sum(i.total) AS revenue
 FROM customer c join invoice i ON c.customer_id = i.customer_id
 GROUP BY c.first_name, c.customer_id
 ORDER BY revenue DESC
 LIMIT 1;
 
 /* Question Set 2 */
 
/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

SELECT DISTINCT c.first_name, c.last_name, c.email
FROM customer c 
Join invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
WHERE track_id IN(
                  SELECT track_id 
                  FROM track t
                  JOIN genre g ON t.genre_id = g.genre_id
                  WHERE g.name LIKE 'rock')
ORDER BY c.email;
 
/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */


 
 SELECT a.name, COUNT(track_id) as total_track_count
 FROM artist a 
 JOIN album2 al ON a.artist_id = al.artist_id
 JOIN track t ON al.album_id = t.album_id
WHERE t.genre_id IN
	 (SELECT g.genre_id 
	 FROM genre g 
	 WHERE g.name='rock')
GROUP BY a.name
ORDER BY total_track_count DESC
LIMIT 10;

/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

SELECT t.name, 
       t.milliseconds as length_of_track
FROM track t
WHERE t.milliseconds > (SELECT AVG(milliseconds) FROM track)
ORDER BY length_of_track DESC;

/* Question Set 3 */

/* Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

/* Steps to Solve: First, find which artist has earned the most according to the InvoiceLines. Now use this artist to find 
which customer spent the most on this artist. For this query, you will need to use the Invoice, InvoiceLine, Track, Customer, 
Album, and Artist tables. Note, this one is tricky because the Total spent in the Invoice table might not be on a single product, 
so you need to use the InvoiceLine table to find out how many of each product was purchased, and then multiply this by the price
for each artist. */

WITH best_selling_artist AS (
                             SELECT a.artist_id, a.name AS artist_name, SUM( il.unit_price * il.quantity)
                             FROM artist a 
                             JOIN album2 al ON a.artist_id = al.artist_id
			                 JOIN track t ON al.album_id = t.album_id
                             JOIN invoice_line il ON t.track_id = il.track_id
                             GROUP BY 1,2
                             ORDER BY 3 DESC
                             LIMIT 1)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price * il.quantity)AS money_spent
                              FROM customer c 
                             JOIN invoice i ON c.customer_id = i.customer_id
			                 JOIN invoice_line il ON i.invoice_id = il.invoice_id
                             JOIN track t ON il.track_id = t.track_id
                             JOIN album2 al ON t.album_id = al.album_id
                             JOIN best_selling_artist bsa ON al.artist_id = bsa.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

/* Steps to Solve:  There are two parts in question- first most popular music genre and second need data at country level. */

WITH Popular_genre AS(
       SELECT c.country, 
	   g.genre_id, 
       g.name, 
       COUNT(il.quantity) as purchases,
       ROW_NUMBER() OVER(PARTITION BY c.country ORDER BY COUNT(il.quantity) DESC) AS ROW_NO 
       FROM customer c 
						JOIN invoice i ON c.customer_id = i.customer_id
					    JOIN invoice_line il ON i.invoice_id = il.invoice_id
					    JOIN track t ON il.track_id = t.track_id
					    JOIN genre g ON t.genre_id = g.genre_id
					   GROUP BY 1, 2 ,3
                       ORDER BY 1 ASC, 4 DESC)
	SELECT * FROM popular_genre WHERE ROW_NO <= 1;
    
    
   /* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

/* Steps to Solve:  Similar to the above question. There are two parts in question- 
first find the most spent on music for each country and second filter the data for respective customers. */

WITH RECURSIVE 
	country_with_customer AS(
             SELECT c.customer_id, c.first_name, c.last_name, i.billing_country,SUM(i.total) AS total_Spending
             FROM customer c 
             JOIN invoice i ON c.customer_id = i.customer_id
             GROUP BY c.customer_id, c.first_name, c.last_name, i.billing_country
             ORDER BY total_Spending DESC
	
        country_max_spending AS(
		SELECT billing_country,MAX(total_spending) AS max_spending
		FROM customter_with_country
		GROUP BY billing_country)

SELECT cc.billing_country, cc.total_spending, cc.first_name, cc.last_name, cc.customer_id
FROM customter_with_country cc
JOIN country_max_spending ms
ON cc.billing_country = ms.billing_country
WHERE cc.total_spending = ms.max_spending
ORDER BY 1;
	
     
					    



                             
