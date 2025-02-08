CREATE TABLE Flughafen (
    id INT PRIMARY KEY,
    name VARCHAR(50),
    ort VARCHAR(50)
);

CREATE TABLE Fluggesellschaft(
	id INT PRIMARY KEY,
	name VARCHAR(50)
);

CREATE TABLE Flug (
    code INT PRIMARY KEY,
	fluggesellschaft INT,
	FOREIGN KEY (fluggesellschaft) REFERENCES Fluggesellschaft(id),
    destination INT,
    FOREIGN KEY (destination) REFERENCES Flughafen(id),
	origin INT,
    FOREIGN KEY (origin) REFERENCES Flughafen(id),
	depttime TIME,
	arrtime TIME
);

CREATE TABLE Passagier(
	cnp INT PRIMARY KEY,
	vorname VARCHAR(50),
	name VARCHAR(50),
	gebdatum DATE
);

CREATE TABLE Buchungen(
	id INT PRIMARY KEY,
	passcnp INT,
	FOREIGN KEY (passcnp) REFERENCES Passagier(cnp),
	flug INT,
	FOREIGN KEY (flug) REFERENCES Flug(code)
);

CREATE TABLE Gepacksstuck(
	id INT PRIMARY KEY,
	gewicht INT,
	typ VARCHAR(50),
	buchung INT,
	FOREIGN KEY (buchung) REFERENCES Buchungen(id)
);


SELECT * FROM Passagier
SELECT * FROM Flughafen
SELECT * FROM Fluggesellschaft
SELECT * FROM Flug
SELECT * FROM Buchungen
SELECT * FROM Gepacksstuck

INSERT INTO Passagier VALUES(1,'Maria','Georgescu','2001-10-10')
INSERT INTO Passagier VALUES(2,'Victor','Grigorescu','2000-11-11')
INSERT INTO Passagier VALUES(3,'Otilia','Pascalopol','1999-12-12')
INSERT INTO Passagier VALUES(4,'Anamaria','Pascalopol','1999-12-12')

INSERT INTO Flughafen VALUES(1,'Berlin International Airport','Berlin')
INSERT INTO Flughafen VALUES(2,'Paris International Airport','Paris')
INSERT INTO Flughafen VALUES(3,'Oslo International Airport','Oslo')

INSERT INTO Fluggesellschaft VALUES(1,'WizzAir')
INSERT INTO Fluggesellschaft VALUES(2,'RyanAir')

INSERT INTO Flug VALUES(1,1,1,2,'19:30:10','20:00:10')
INSERT INTO Flug VALUES(2,2,3,2,'11:30:10','14:00:10')
INSERT INTO Flug VALUES(3,1,3,2,'10:30:10','12:00:10')
INSERT INTO Flug VALUES(4,2,2,3,'11:30:10','14:00:10')
INSERT INTO Flug VALUES(5,1,2,1,'10:30:10','12:00:10')

INSERT INTO Buchungen VALUES(1,1,1)
INSERT INTO Buchungen VALUES(2,2,2)
INSERT INTO Buchungen VALUES(3,3,3)
INSERT INTO Buchungen VALUES(4,4,3)


INSERT INTO Gepacksstuck VALUES(1,5,'Handbag',1)
INSERT INTO Gepacksstuck VALUES(2,7,'Cabin bag',1)
INSERT INTO Gepacksstuck VALUES(3,10,'Suitcase',2)



--Gebe aus alle Fluge die Anamaria gebucht hat
SELECT code,vorname FROM Flug F
JOIN Buchungen B ON B.Flug=F.code
JOIN Passagier P ON P.cnp=B.passcnp
WHERE P.vorname='Anamaria'


--Gebe die Anzahl der gebuchten Fluge (Buchungen) fur jeden Passagier an
SELECT COUNT(*) AS numberflights, passcnp FROM Buchungen
GROUP BY passcnp


--Gebe den Mittelwert der Passagiere (Buchungen) pro Flug aus 
SELECT AVG(ct.NR) FROM 
(SELECT COUNT(*) AS NR 
FROM Buchungen
GROUP BY flug) as ct


--Gebe alle Flughafen, Name und Ort aus, auf denen wenigstens 2 Fluge landen
SELECT name, ort, COUNT(*) AS nrflights FROM Flughafen Fh
JOIN Flug F on F.destination=Fh.id
GROUP BY name, ort
HAVING COUNT(*)>=2


--Gebe top 3 Kunden mit dem schwarsten Gepack und ihre Fluge
SELECT TOP(3) B.passcnp, B.flug, SUM(G.gewicht) FROM Buchungen B
JOIN Gepacksstuck G on B.id=G.buchung
GROUP BY B.passcnp, B.flug
ORDER BY SUM(G.gewicht) DESC


--Gebe fur jeden Flughafen die totale Anzahl der Fluge aus, die von diesem Flughafen abfliegen oder auf diesen Flughafen landen
SELECT originflights.id,originflights.nrorg+destinationflights.nrdest FROM 
(SELECT Fh.id, COUNT(*) as nrorg FROM Flug F
JOIN Flughafen Fh ON F.origin=Fh.id
GROUP BY Fh.id) AS originflights
JOIN
(SELECT Fh.id, COUNT(*) as nrdest FROM Flug F
JOIN Flughafen Fh ON F.destination=Fh.id
GROUP BY Fh.id) AS destinationflights 
ON originflights.id=destinationflights.id


--Finde das Stadtepaar mit den meisten Flugen (welches Paar (org,dest) erscheint am meisten in der Tabelle Flug)
SELECT ort FROM Flughafen JOIN (
SELECT TOP(1) destination, origin
FROM Flug
GROUP BY destination, origin
ORDER BY COUNT(*) DESC ) AS mostflights 
ON Flughafen.id=mostflights.origin 
OR Flughafen.id=mostflights.destination

