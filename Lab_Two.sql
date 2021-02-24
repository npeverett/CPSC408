-- (1)
select max(Total) from Invoice;

-- (2)
select Total from Invoice
order by Total desc
limit 1;

-- (3)
select MediaType.Name, Count(*)
from Track, MediaType
where Track.MediaTypeId = MediaType.MediaTypeId
group by MediaType.Name

-- (4)
order by COUNT(*) desc;

-- (5)
select MediaType.Name, Count(*)
from Track, MediaType
where Track.MediaTypeId = MediaType.MediaTypeId
group by MediaType.Name
having COUNT(*) > 200
order by COUNT(*) desc;

-- (6)
select COUNT(*) A_Artist_Track_Count, COUNT(DISTINCT Artist.Name) A_Artists
from Track, Artist
where Artist.ArtistId = Track.AlbumId
and Artist.Name like 'a%';

-- (7)
-- Earliest B-Day in 40s, Latest in 70s
select FirstName||" "||LastName Name, BirthDate,
       CASE WHEN BirthDate BETWEEN '1940-01-01' AND '1950-01-01' THEN '1940s'
            WHEN BirthDate BETWEEN '1950-01-01' AND '1960-01-01' THEN '1950s'
            WHEN BirthDate BETWEEN '1960-01-01' AND '1970-01-01' THEN '1960s'
            WHEN BirthDate BETWEEN '1970-01-01' AND '1980-01-01' THEN '1970s'
       END Birth_Decade
from Employee;

