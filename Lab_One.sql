-- (1)
SELECT FirstName,LastName,Email FROM Employee;

-- (2)
SELECT * FROM Artist;

-- (3)
SELECT * FROM Employee WHERE Title LIKE '%Manager%';

-- (4)
SELECT min(Total), max(Total) FROM Invoice;

-- (5)
SELECT BillingAddress,BillingCity,BillingPostalCode,Total
FROM Invoice WHERE BillingCountry='Germany';

-- (6)
SELECT BillingAddress,BillingCity,BillingPostalCode,Total
FROM Invoice WHERE Total < 25 AND Total > 15;

-- (7)
SELECT DISTINCT BillingCountry FROM Invoice;

-- (8)
SELECT FirstName, LastName, CustomerId, Country
FROM Customer WHERE Country != 'USA';

-- (9)
SELECT * FROM Customer WHERE Country = 'Brazil';

-- (10)
SELECT Track.Name, IL.Quantity, IL.UnitPrice FROM Track
JOIN InvoiceLine IL on Track.TrackId = IL.TrackId
ORDER BY Track.Name ASC
