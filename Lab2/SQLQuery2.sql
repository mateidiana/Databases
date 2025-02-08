--2
--1.Sort all films by their award count in decreasing order
SELECT Films.Name, COUNT(Awards.AwardId) as AwardCount
FROM Films
LEFT JOIN Awards ON Films.FilmId = Awards.FilmId
GROUP BY Films.FilmId, Films.Name
ORDER BY COUNT (Awards.AwardId) DESC;


SELECT Films.Name, COUNT(Awards.AwardId) as AwardCount
FROM Films
INNER JOIN Awards ON Films.FilmId = Awards.FilmId
GROUP BY Films.FilmId, Films.Name
ORDER BY COUNT (Awards.AwardId) DESC;


--2.Show for all films their soundtrack composer and number of tracks in each respective soundtrack
SELECT Films.Name, Soundtrack.Composer, COUNT(Tracks.TrackId) as SongCount
FROM Films
LEFT JOIN Soundtrack ON Films.FilmId = Soundtrack.FilmId
LEFT JOIN Tracks ON Soundtrack.FilmId = Tracks.SoundId
GROUP BY Films.FilmId, Films.Name, Soundtrack.Composer;


--3.Select the best rated film with an average score higher than 2
SELECT TOP 1 Films.Name, AVG(Review.Score) as BestRated
FROM Films
JOIN Review ON Films.FilmId = Review.FilmId
GROUP BY Films.FilmId,Films.Name
HAVING AVG(Review.Score) > 2
ORDER BY AVG(Review.Score) DESC;


--4.Select all information about the actors older than Saoirse Ronan that are not Scarlett Johansson or Nathalie Portman
SELECT * FROM Actors WHERE Actors.Age > 
(SELECT Actors.Age FROM Actors WHERE Actors.Name = 'Saoirse' AND Actors.Surname = 'Ronan')
AND Actors.Surname NOT IN ('Johansson', 'Portman') 
AND Actors.Name NOT IN ('Scarlett', 'Nathalie')


--5.Select the Filmmakers that worked on both Lady Bird and Little Women
SELECT Filmmakers.Name, Filmmakers.Surname 
FROM Filmmakers
JOIN DirectedBy ON Filmmakers.MakerId = DirectedBy.MakerId
JOIN Films ON Films.FilmId = DirectedBy.FilmId
WHERE Films.Name = 'Lady Bird'  
INTERSECT
SELECT Filmmakers.Name, Filmmakers.Surname 
FROM Filmmakers
JOIN DirectedBy ON Filmmakers.MakerId = DirectedBy.MakerId
JOIN Films ON Films.FilmId = DirectedBy.FilmId
WHERE Films.Name = 'Little Women'


--6 Show all actors that starred in a film that received the award golden globe for best actor/actress
SELECT Films.Name, Actors.Name, Actors.Surname
FROM Films
JOIN StarrsIn ON Films.FilmId = StarrsIn.FilmId
JOIN Actors ON Actors.ActorId= StarrsIn.ActorId
JOIN Awards ON Films.FilmId = Awards.FilmId
WHERE Awards.AwardId IN 
(Select Awards.AwardId 
FROM Awards 
WHERE Awards.Name = 'Golden Globe for Best Actor' OR Awards.Name = 'Golden Globe for Best Actress')


--7 Show the screenwriters that worked on Dune and the ones that worked on Chicago
SELECT Screenwriters.Name, Screenwriters.Surname
FROM Screenwriters
JOIN WrittenBy ON Screenwriters.WriterId = WrittenBy.WriterId
JOIN Films ON Films.FilmId = WrittenBy.FilmId
WHERE Films.Name = 'Dune'  
UNION
SELECT Screenwriters.Name, Screenwriters.Surname
FROM Screenwriters
JOIN WrittenBy ON Screenwriters.WriterId = WrittenBy.WriterId
JOIN Films ON Films.FilmId = WrittenBy.FilmId
WHERE Films.Name = 'Chicago'


--8 Show all films except the ones written by Taika Waititi
SELECT Films.Name
FROM Films
EXCEPT
SELECT Films.Name
FROM Films
JOIN WrittenBy ON Films.FilmId = WrittenBy.FilmId
JOIN Screenwriters ON WrittenBy.WriterId = Screenwriters.WriterId
WHERE Screenwriters.Name = 'Taika' AND Screenwriters.Surname = 'Waititi'


--9 Show the reviewer that left the most reviews
SELECT Reviewers.Username, COUNT(Review.FilmId) AS MaxReviews
FROM Reviewers
JOIN Review ON Review.ReviewerId=Reviewers.ReviewerId
JOIN Films ON Review.FilmId=Films.FilmId
GROUP BY Reviewers.Username

HAVING COUNT(Review.FilmId) = (
    SELECT MAX(ReviewCount) 
    FROM (
        SELECT COUNT(Review.FilmId) AS ReviewCount
        FROM Reviewers
        JOIN Review ON Review.ReviewerId = Reviewers.ReviewerId
        JOIN Films ON Review.FilmId = Films.FilmId
        GROUP BY Reviewers.Username
    ) AS Subquery
);


--10 Select all reviewers that reviewed every film in the 'Musical' genre and at least one film longer than 90 minutes
SELECT DISTINCT Reviewers.Username
FROM Reviewers
JOIN Review ON Reviewers.ReviewerId = Review.ReviewerId
JOIN Films ON Review.FilmId = Films.FilmId
JOIN GenreBelonging ON GenreBelonging.FilmID = Films.FilmId
JOIN Genres ON GenreBelonging.GenreID = Genres.GenreID
WHERE Genres.Name = 'Musical'

AND Review.FilmId = ALL (
    SELECT FilmId 
    FROM Films 
    WHERE GenreBelonging.FilmID=Films.FilmId AND GenreBelonging.GenreID=Genres.GenreID AND Genres.Name='Musical'
)

AND Reviewers.ReviewerId = ANY (
    SELECT ReviewerId
    FROM Review
    WHERE Review.FilmId = Films.FilmId AND Films.Duration > 90
);