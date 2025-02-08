
-- UB 1--------------------------------------------------------------------

create or alter function ValidateAwardName(@name varchar(100))
returns bit
as
	begin
		declare @result as bit
		if @name = ''
			set @result = 0
		else 
			set @result = 1
		return @result
	end
go

create or alter function ValidateAwardDate(@date date)
returns bit
as
	begin
		declare @result as bit
		if @date > GETDATE()
			set @result = 0
		else 
			set @result = 1
		return @result
	end
go

create or alter function ValidateFilm(@filmID int)
returns bit
as
	begin
		declare @result as bit
		if exists (select 1 from Films where FilmId = @filmID)
			set @result = 1
		else 
			set @result = 0
		return @result
	end
go

create or alter procedure InsertDataAwards(
	@name varchar(100),
	@filmID int,
	@date date)
as
	begin
		declare @maxId int;
		if dbo.ValidateAwardName(@name) = 0
			begin
				print 'Validation error: @name has an invalid value'
				return
			end
		if dbo.ValidateFilm(@filmID) = 0
			begin
				print 'Validation error: @filmID has an invalid value'
				return
			end
		if dbo.ValidateAwardDate(@date) = 0
			begin
				print 'Validation error: @date has an invalid value'
				return
			end

		select @maxId =MAX(AwardId) from Awards;
		insert into Awards (AwardId, Name, DateAwarded, FilmId)
		values (@maxId+1,@name,@date,@filmID)

		print 'Data successfully inserted'
	end
go




select *
from Films

select * 
from Awards

print dbo.ValidateAwardName('')
print dbo.ValidateFilm(1)
print dbo.ValidateAwardDate('2020-02-07')
exec InsertDataAwards 'Golden Globe', 1, '2020-02-07'


-- UB 2--------------------------------------------------------------------

ALTER TABLE Films
ADD average_rating FLOAT;

UPDATE Films
SET average_rating = (
    SELECT AVG(Review.Score) 
    FROM Review 
    WHERE Review.FilmId = Films.FilmId
);


CREATE OR ALTER VIEW BestAwarded 
AS
WITH AwardCount AS(
SELECT Films.Name, Films.Date, COUNT(Awards.AwardId) as AwardCount
FROM Films
LEFT JOIN Awards ON Films.FilmId = Awards.FilmId
GROUP BY Films.FilmId, Films.Name, Films.Date
)
SELECT Name,Date, AwardCount FROM AwardCount WHERE AwardCount>0;

SELECT * FROM BestAwarded


go
CREATE OR ALTER FUNCTION GetAverageRatingByYear()
RETURNS TABLE
AS
RETURN
    SELECT 
        DISTINCT(YEAR(Date)) AS release_year,
        AVG(average_rating) OVER (PARTITION BY YEAR(DATE)) AS avg_rating_by_year
    FROM 
        Films;


SELECT * 
FROM dbo.GetAverageRatingByYear()


SELECT TOP 1
    ba.Name,
    ba.AwardCount
FROM
    BestAwarded as ba
JOIN GetAverageRatingByYear() garby ON YEAR(ba.Date) = garby.release_year
ORDER BY
	garby.avg_rating_by_year DESC
go


SELECT * FROM Films


-- UB 3--------------------------------------------------------------------

create table LogTable1 (
	ID int primary key identity(1, 1),
	ExecDateTime datetime,
	StatementType varchar(1),
	TableName varchar(100),
	AffectedTupleCount int
)
go

create trigger On_Film_Insert
	on Films
	after insert
as
begin
	set nocount on

	declare @AffectedTupleCount as int
	select @AffectedTupleCount = count(*) from inserted

	insert into LogTable (ExecDateTime, StatementType, TableName, AffectedTupleCount)
	select GETDATE(), 'I', 'Films', @AffectedTupleCount
end
go

create trigger On_Film_Delete
	on Films
	after delete
as
begin
	set nocount on

	declare @AffectedTupleCount as int
	select @AffectedTupleCount = count(*) from deleted

	insert into LogTable (ExecDateTime, StatementType, TableName, AffectedTupleCount)
	select GETDATE(), 'D', 'Films', @AffectedTupleCount
end
go

create trigger On_Film_Update
	on Films
	after update
as
begin
	set nocount on

	declare @AffectedTupleCount as int
	select @AffectedTupleCount = COUNT(*) 
		from deleted d
		join inserted i on d.FilmId = i.FilmId
		where 
			d.Name != i.Name or 
			d.Date != i.Date or 
			d.Duration != i.Duration

	insert into LogTable (ExecDateTime, StatementType, TableName, AffectedTupleCount)
	select GETDATE(), 'U', 'Films', @AffectedTupleCount
end
go

select * from Films
select * from LogTable

insert into Films (FilmId, Name, Duration, Date)
values (7, 'How to train your dragon', 110,'2014-09-07'),
	   (8, 'The Hidden World',120,'2019-12-12')

delete from Films
where FilmId = 28 or FilmId = 27

update Films
set Duration = 99
where FilmId > 7

drop table LogTable
go


-- UB 4--------------------------------------------------------------------

select * from Films


ALTER TABLE Films
ADD rating_category NVARCHAR(30);



DECLARE @film_id INT;
DECLARE @title VARCHAR(50);
DECLARE @duration INT;
DECLARE @release_date Date;
DECLARE @average_rating FLOAT;
DECLARE @rating_category NVARCHAR(30);


DECLARE film_cursor CURSOR FOR
SELECT FilmId, Name, Duration, Date, average_rating
FROM Films
WHERE Date <GETDATE();

OPEN film_cursor;

FETCH NEXT FROM film_cursor INTO @film_id, @title, @duration, @release_date, @average_rating;

WHILE @@FETCH_STATUS = 0
BEGIN
    
    IF @average_rating IS NULL
    BEGIN
        PRINT 'Film with NULL rating: ' + @title;
    END
    ELSE
    BEGIN
        
        IF @average_rating >= 5.0
            SET @rating_category = 'Excellent';
        ELSE IF @average_rating >= 4.0
            SET @rating_category = 'Good';
        ELSE IF @average_rating >= 3.0
            SET @rating_category = 'Average';
        ELSE
            SET @rating_category = 'Poor';

        
        UPDATE Films
        SET rating_category = @rating_category
        WHERE FilmId = @film_id;
    END

    
    FETCH NEXT FROM film_cursor INTO @film_id, @title, @duration, @release_date, @average_rating;
END;


CLOSE film_cursor;
DEALLOCATE film_cursor;






