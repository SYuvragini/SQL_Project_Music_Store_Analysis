create database music_data;
USE music_data;
SELECT billing_country,
	   COUNT(customer_id) as no_of_invoices
       FROM invoice
       GROUP BY  billing_country
       ORDER BY no_of_invoices DESC;
       
       SELECT total FROM invoice
       ORDER BY total desc
       LIMIT 3;
       
SELECT billing_city, sum(total) as revenue_generated
 FROM invoice
 GROUP BY billing_city
 ORDER BY revenue_generated DESC
 LIMIT 1;
 
 SELECT c.first_name, c.customer_id, sum(i.total) AS revenue
 FROM customer c join invoice i ON c.customer_id = i.customer_id
 GROUP BY c.first_name, c.customer_id
 ORDER BY revenue DESC;
 
 -----MODERATE------
 
 SELECT DISTINCT c.first_name, c.last_name, c.email
 FROM customer c join invoice i ON c.customer_id = i.customer_id
				JOIN invoice_line il ON i.invoice_id = il.invoice_id
WHERE track_id IN(
                  SELECT track_id 
                  FROM track t
                  JOIN genre g ON t.genre_id = g.genre_id
                  WHERE g.name LIKE 'rock')
ORDER BY c.email;
 
 USE music_data;
 SELECT artist_id,title FROM album2
 GROUP BY artist_id;
 
 SELECT a.name, COUNT(track_id) as total_track_count
 FROM artist a JOIN album2 al ON a.artist_id = al.artist_id
			   JOIN track t ON al.album_id = t.album_id
WHERE t.genre_id IN (SELECT g.genre_id FROM genre g WHERE g.name='rock')
GROUP BY a.name
ORDER BY total_track_count DESC
LIMIT 10;

SELECT t.name, 
       t.milliseconds as length_of_track
FROM track t
WHERE t.milliseconds > (SELECT AVG(milliseconds) FROM track)
ORDER BY length_of_track DESC;

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

USE music_data;
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
    
    
    WITH RECURSIVE country_with_cutomer AS(
    SELECT c.customer_id, c.first_name, c.last_name, i.billing_country,SUM(i.total) AS total_Spending
    FROM customer c JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY 1,2,3,4
    ORDER BY 5 DESC
	
    UNION ALL
      SELECT i.billing_country, max(total_spending) AS max_Spending
    FROM country_with_cutomer cc WHERE cc.total_Spending = max_Spending)
   
   SELECT * FROM country_with_cutomer;
     
					    



                             