-- (1) -----------------------------------------
CREATE TABLE Player(
    pID int NOT NULL,
    name varchar(100),
    teamName varchar(100),
    PRIMARY KEY (pID)
);

-- (2) -----------------------------------------
ALTER TABLE Player
ADD age int;

-- (3) -----------------------------------------
INSERT INTO Player
VALUES (1,'Player 1','Team A', 21),
        (2,'Player 2', 'Team A', NULL),
        (3,'Player 3', 'Team B', 28),
        (4,'Player 4', 'Team B', NULL);

-- (4) -----------------------------------------
DELETE FROM Player WHERE pID == 2;

-- (5) -----------------------------------------
UPDATE Player
SET age = 25
WHERE age IS NULL;

-- (6) -----------------------------------------
SELECT COUNT(age) as Tuples, round(avg(age),2) as AverageAge FROM Player;

-- (7) -----------------------------------------
DROP TABLE Player;

-- (8) -----------------------------------------
SELECT avg(Total) as BrazilTotal FROM Invoice
WHERE Invoice.BillingCountry = 'Brazil';

-- (9) -----------------------------------------
SELECT round(avg(Total),2) Average, BillingCity FROM Invoice
WHERE Invoice.BillingCountry = 'Brazil'
GROUP BY BillingCity;

-- (10) -----------------------------------------
SELECT Album.Title FROM Album
JOIN Track on Album.AlbumId = Track.AlbumId
GROUP BY Album.Title
HAVING Count(Track.TrackID) > 20;

-- (11) -----------------------------------------
SELECT Count(InvoiceDate) Invoices_2010 FROM Invoice
WHERE strftime('%Y',Invoice.InvoiceDate)='2010';

-- (12) -----------------------------------------
SELECT BillingCountry Country,
       Count(DISTINCT BillingCity) NumCities FROM Invoice
GROUP BY BillingCountry;

-- (13) -----------------------------------------
SELECT Album.Title Album, Track.Name Track, MediaType.Name Type FROM Track
JOIN Album on Track.AlbumId = Album.AlbumId
JOIN MediaType on Track.MediaTypeId = MediaType.MediaTypeID;

-- (14) -----------------------------------------
SELECT Count(InvoiceId) as Jane_Peacock_Sales FROM Invoice
JOIN Customer on Invoice.CustomerId = Customer.CustomerId
WHERE Customer.SupportRepId = (SELECT EmployeeId FROM Employee WHERE LastName = 'Peacock');

-- (15) Extra Credit -----------------------------------------
-- STDEV(X) = SQRT( VAR(X) )
-- VAR(X) = E(X^2) - E(X)^2 , where E(X) is expected value
SELECT round(sqrt(avg(Total*Total) - avg(Total)*avg(Total)),2) as StdDev_Calculated,
       round(stdev(Total),2) as StdDev_True,BillingCountry FROM Invoice
GROUP BY BillingCountry;
