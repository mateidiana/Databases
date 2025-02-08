create table Kunde(
	cnp int primary key,
	name varchar(30),
	vorname varchar(30)
);

create table Konto(
	knr int primary key,
	wahrung varchar(30),
	balance float,
	kundecnp int,
	foreign key (kundecnp) references Kunde(cnp)
);

create table Kredit(
	id int primary key,
	betrag float,
	wahrung varchar(30),
	laufzeit date,
	mrate float,
	kundecnp int,
	foreign key(kundecnp) references Kunde(cnp)
);

insert into Kunde values(1,'Popescu','Ovidiu')
insert into Kunde values(2,'Georgescu','Maria')
insert into Kunde values(3,'Xulescu','Ion')

insert into Konto values(1,'EURO',4000,1)
insert into Konto values(2,'RON',3000,3)
insert into Konto values(3,'EURO',8000,2)
insert into Konto values(4,'YEN',10000,1)

insert into Kredit values(1,1000,'EURO','2020-11-11',0.2,1)
insert into Kredit values(2,1000,'RON','2019-11-11',0.2,3)
insert into Kredit values(3,1000,'EURO','2021-11-11',0.3,2)
insert into Kredit values(4,1000,'RON','2022-11-11',0.3,2)

select * from Kredit
select * from Kunde
select * from Konto



--Gebe den Mittelwert des Betrags aller beantragten Kredite aus
select avg(betrag),wahrung
from Kredit
group by wahrung



--Gebe alle Kunden aus die mind ein Kredit mit dem Betrag hoher als 1000 euro haben
select distinct k.cnp, k.name
from Kunde k
where exists(select 1 from kredit kr
			where kr.kundecnp=k.cnp
			and kr.wahrung='EURO' and kr.betrag>=1000
)

--ODER

select distinct cnp, name, vorname from(
select * from Kunde
join Kredit on Kunde.cnp=Kredit.kundecnp) as kundenKredite
where wahrung='EURO' and betrag>=1000




--Gebe die Anzahl der geoffneten Kontos mit wahrung euro
select count(*), wahrung
from Konto
where wahrung='EURO'
group by wahrung



--Gebe die Kunden aus die 2 Kredite haben mit unterschiedlichen wahrungen in ron und eur, so dass der betrag des kredites in euro mehr
--als der betrag des kredites in ron ist
select k.cnp, k.name
from Kunde k
where exists(select 1 from kredit kr 
			where kr.kundecnp=k.cnp
			and kr.wahrung='EURO' and kr.betrag >= any(select betrag 
								from kredit kr 
							        where kr.kundecnp=k.cnp 
								and kr.wahrung='RON')
)



--Gebe alle Kunden aus und die Anzahl von Wahrungen fur Kunden die Konten in mehrere Wahrungen haben
select cnp,name,vorname,count(*) as nrwahrungen from konto 
join kunde on konto.kundecnp=kunde.cnp
group by cnp,name,vorname
having count(*)>1