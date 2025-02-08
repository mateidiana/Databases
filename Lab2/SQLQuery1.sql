--1

CREATE TABLE Genres1
(GenreID INT NOT NULL,
Name VARCHAR(50) NOT NULL,
PRIMARY KEY (GenreID))

CREATE TABLE GenreBelonging1
(GenreID INT NOT NULL,
 FilmID INT NOT NULL,
PRIMARY KEY (GenreID,FilmID),
CONSTRAINT FK_GenreBelonging_Genres FOREIGN KEY (GenreID) REFERENCES Genres,
CONSTRAINT FK_GenreBelonging_Films FOREIGN KEY (FilmID) REFERENCES Films)


INSERT INTO Genres(GenreID,Name) 
VALUES (1,'Historical Fiction')

INSERT INTO Genres(GenreID,Name)
VALUES (2, 'Musical')

INSERT INTO Genres(GenreID,Name)
VALUES (3, 'Psychological Thriller')

INSERT INTO GenreBelonging(GenreID,FilmID)
VALUES (1,6)

INSERT INTO GenreBelonging(GenreID,FilmID)
VALUES (1,4)

INSERT INTO GenreBelonging(GenreID,FilmID)
VALUES (2,3)

--INSERT INTO GenreBelonging(GenreID,FilmID)
--VALUES (2,35)

DELETE GenreBelonging
FROM GenreBelonging
JOIN Genres ON Genres.GenreID = GenreBelonging.GenreID
JOIN Films ON Films.FilmId = GenreBelonging.FilmID
WHERE Genres.Name = 'Musical' AND Films.Name = 'Chicago'

UPDATE GenreBelonging
SET GenreBelonging.GenreID = (SELECT GenreID FROM Genres WHERE Name ='Musical')
FROM GenreBelonging
JOIN Genres ON Genres.GenreID = GenreBelonging.GenreID
JOIN Films ON Films.FilmId = GenreBelonging.FilmID
WHERE Genres.Name = 'Historical Fiction' AND Films.Name LIKE 'J%'

DELETE FROM Awards
WHERE Awards.DateAwarded IS NOT NULL

DELETE StarrsIn
FROM StarrsIn
JOIN Actors ON Actors.ActorId = StarrsIn.ActorId
JOIN Films ON Films.FilmId = StarrsIn.FilmId
WHERE Actors.Age BETWEEN 30 AND 50

UPDATE Awards
SET Awards.Name = 'Oscar Best Original Score'
WHERE Awards.FilmId IN (1,3)