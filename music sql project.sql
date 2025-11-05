--Q1. who is the senior most employee based job title

SELECT title, last_name, first_name 
FROM employee
ORDER BY levels DESC
LIMIT 1


--Q2. which countries have the most invoices


select * from invoice

select billing_country , count(*) as c
from invoice
group by billing_country
order by c desc

--Q3. what are top 3 values of total invoice

select total , customer_id , billing_country
from invoice
order by total desc
limit 3


--Q4. which city has the best customers ? 
--we  would like to throw a promotional music festival in the city 
--we made the most query that returns one city that has the highest sum of return both city name & sum of all invoices totals?

select * from invoice

select billing_city ,sum(total) as total_spent
from invoice
group by billing_city
order by total_spent desc
limit 1

--Q5. who is the best customer ? 
--the customer who has money will be declared the best customer. 
--write a query the person who has spent the most money? 

select * from customer
select * from invoice

select customer.customer_id , first_name , last_name , sum(total) as number_of_spent
from customer
join invoice on customer.customer_id = invoice. invoice_id
group by customer.customer_id 
order by number_of_spent desc


--Q6. Write query to return the email, first name, last name , & genre of all rock music listeners . 
--return your list ordered alphabetically by email starting A

select * from customer

select distinct first_name, last_name , email, genre.name as Name 
from customer
join invoice on  invoice.customer_id= customer.customer_id 
join invoice_line on invoice_line.invoice_id=invoice.invoice_id 
join track on track.track_id = invoice_line.track_id
join genre on genre.genre_id = track.genre_id
	where genre.name like 'Rock'
	order by email asc

--Q7. Let's invite the artists who have written the most rock music in our dataset. 
--write a query that returns the Artist Name and total track count of the top 10 rock bands.

select * from artist
select * from track

select artist.artist_id , artist.name , count(artist.artist_id) as total_track
from track 
join album on album.album_id = track.album_id
join artist on artist.artist_id = album.artist_id
join genre on genre.genre_id = track.genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by total_track desc 
limit 10

--Q8. Return all track names that have song letter the average song length longer than the average song length.
--return the name and milliseconds for each track . 
--order by the song length with longest songs listed first.

select * from track

select name,milliseconds
from track
where milliseconds > (
	select avg(milliseconds) as avg_track_length
	from track )
order by milliseconds desc;


--Q9. Find how much amount spent by each customer on artists?
--write a query to return customer name, artist name and total spent

select * from customer
select * from invoice
select * from artist
select * from album

select customer.customer_id , customer.first_name , 
customer.last_name , billing_country, artist.name as artist_name, 
sum(total) as total_spent 
from customer
join invoice on customer.customer_id = invoice.invoice_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
join track on invoice_line.invoice_id = track.track_id
join album on track.album_id = album.album_id
join artist on album.album_id = artist.artist_id
group by customer.customer_id , customer.first_name , 
customer.last_name , billing_country ,artist.name
order by total_spent desc

--Q10. We want to find out the most popular music genre for each country.
--we determine the most popular genre as the genre with highest amount of purchases. 
--write a query that returns each country along with the top genre. 
--for countries where the maximum number of purchases is shared return all genres.

select * from genre                                  
select * from invoice
select * from customer 

with popular_genre as 
(
	select count(invoice_line.quantity) as purchase ,
		customer.country ,
		genre.name,
		genre.genre_id,
		row_number() over(partition by customer.country order by count(invoice_line.quantity)desc)as RowNo
		from invoice_line
	join invoice on invoice.invoice_id = invoice_line.invoice_id
	join customer on customer.customer_id = invoice_line.invoice_id
	join track on track.track_id= invoice_line.track_id
	join genre on genre.genre_id = track.genre_id
	group by 2,3,4
	order by 2 asc , 1 desc 
)
select * from popular_genre where RowNo <= 1


--Q11. Write a query that determines the customer that has on music for each country.
--write a query that returns that with top customer and how much they spent. 
--for company the top amount spent is shared , provide all customers with amount. 

select * from customer
select * from invoice


with customer_with_country as (
	select customer.customer_id,first_name ,last_name , billing_country , sum(total) as total_spending,
	row_number() over(partition by billing_country order by sum(total)desc) as RowNo
	from invoice 
	join customer on customer.customer_id = invoice.customer_id
	group by 1,2,3,4
	order by 4 asc , 5 desc
)
select * from customer_with_country where RowNo <= 1
