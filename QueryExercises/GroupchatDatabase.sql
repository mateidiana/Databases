create table Benutzer(
	id int primary key,
	username varchar(30),
	email varchar(30)
);

create table Gruppe(
	id int primary key,
	name varchar(30),
	beschreibung varchar(30)
);

create table BelongsToGruppe(
	id int primary key,
	benutzerId int,
	foreign key (benutzerId) references Benutzer(id),
	gruppeId int,
	foreign key (gruppeId) references Gruppe(id) 
);

create table Nachricht(
	id int primary key,
	sender int,
	foreign key (sender) references Benutzer(id),
	gruppe int,
	foreign key (gruppe) references Gruppe(id),
	text varchar(30),
	zeit time,
	datum date
);

create table Anruf(
	id int primary key,
	dauer int,
	gruppeId int,
	foreign key(gruppeId) references Gruppe(id)
);

create table BelongsToAnruf(
	id int primary key,
	benutzerId int,
	foreign key (benutzerId) references Benutzer(id),
	anrufId int,
	foreign key(anrufId) references Anruf(id)
);



insert into Benutzer values(1, 'Marcela', 'marcela@gmail.com')
insert into Benutzer values(2, 'Mariana', 'm@gmail.com')
insert into Benutzer values(3, 'Sorina', 'sorina@gmail.com')
insert into Benutzer values(4, 'Lucretia', 'lucretia@gmail.com')
insert into Benutzer values(5, 'Anastasia', 'anastasia@gmail.com')

insert into Gruppe values(1, 'Revelion 2025', 'Planung fur das Silvester')
insert into Gruppe values(2, 'Arbeit', 'Company 101')
insert into Gruppe values(3, 'Garden Club', 'Planting')

insert into BelongsToGruppe values (1,1,1)
insert into BelongsToGruppe values (2,2,1)
insert into BelongsToGruppe values (3,3,1)
insert into BelongsToGruppe values (4,4,2)
insert into BelongsToGruppe values (5,5,2)
insert into BelongsToGruppe values (6,5,1)

insert into Nachricht values(1,1,1,'Ich komme','19:30:10','2024-11-11')
insert into Nachricht values(2,2,1,'Ich komme auch','19:30:10','2024-11-11')
insert into Nachricht values(3,3,1,'Ich komme nicht','19:30:10','2025-11-11')
insert into Nachricht values(4,1,1,'Ich bringe Bier','19:30:10','2024-11-11')

insert into Anruf values(1,25,1)
insert into Anruf values(2,35,1)
insert into Anruf values(3,50,2)
insert into Anruf values(4,15,2)

insert into BelongsToAnruf values(1,1,1)
insert into BelongsToAnruf values(2,3,1)
insert into BelongsToAnruf values(3,4,3)
insert into BelongsToAnruf values(4,5,3)

select * from Benutzer
select * from BelongsToGruppe
select * from Gruppe
select * from Nachricht


select distinct username from Benutzer
join BelongsToGruppe on Benutzer.id=BelongsToGruppe.benutzerId
join Gruppe on Gruppe.id=BelongsToGruppe.gruppeId
join Nachricht on Nachricht.sender=Benutzer.id and Nachricht.gruppe=Gruppe.id
where Gruppe.name='Revelion 2025' and Benutzer.id not in 

(select Benutzer.id from Benutzer 
join BelongsToGruppe on Benutzer.id=BelongsToGruppe.benutzerId
join Gruppe on Gruppe.id=BelongsToGruppe.gruppeId
join Nachricht on Nachricht.sender=Benutzer.id and Nachricht.gruppe=Gruppe.id
where Gruppe.Name='Revelion 2025' and Nachricht.datum>'2024-12-30'
)


--Schreibe ein SQL Query welches die avg dauer und avg anzahl teilnehmern aller anrufe ausgibt von allen gruppen mit mehr als 3 mitglieder

select gruppeId,avg(dauer) as avgDauer, avg(nrTeilnehmer) as avgTeilnehmer from (
select * from Anruf where Anruf.gruppeId in(
select Gruppe.id from Gruppe 
join BelongsToGruppe on Gruppe.id=BelongsToGruppe.gruppeId
group by Gruppe.id
having count(*)>3) ) as AnrufGruppe
join
(select anrufId, count(*) as nrTeilnehmer from BelongsToAnruf
group by anrufId) as NrPart on AnrufGruppe.gruppeId=NrPart.anrufId
group by gruppeId



