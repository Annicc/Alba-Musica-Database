start transaction;

drop table if exists Traccia;
drop table if exists Compone_brano;
drop table if exists Brano;
drop table if exists Ha_tag;
drop table if exists Tag;
drop table if exists Appartiene_brano;
drop table if exists Genere_musicale;
drop table if exists Forma_prodotto;
drop table if exists Prodotto;
drop table if exists Diritto_autore;
drop table if exists Concessione;
drop table if exists Pubblica;
drop table if exists Distributore;
drop table if exists Produttore;
drop table if exists Produzione;
drop table if exists Prodotto_fisico;
drop table if exists Vendita;
drop table if exists Detiene;
drop table if exists Artista;
drop table if exists Compone_artista;
drop table if exists Solista;
drop table if exists Prodotta;
drop table if exists Scritta;
drop table if exists Cantata;
drop table if exists Studio;
drop table if exists Prenotazione;
drop table if exists Contratto;
drop table if exists Ricevuta;

/* CREAZIONE DEL DATABASE */

create table Studio(
    id              serial 			primary key,
	nome			varchar(40)		not null unique,
	costo_orario	money		not null default 0,
	via				varchar(100)	not null,
	n_civico		varchar(8)		not null,
	CAP				char(5)			not null,
	stato			char(2)			not null default 'it'
);

create table Traccia(
	id      			serial			primary key,
	denominazione		varchar(100)	not null,   
	durata				interval		second not null,
	data_registrazione	date			not null, 
	studio  			int				default '0',
	foreign key (studio) references Studio(id) on update cascade on delete set default
);

create table Genere_musicale(
	nome 			varchar(30) not null primary key, 
	sottogenere 	varchar(30), 
	foreign key (sottogenere) references Genere_musicale (nome) on update cascade on delete restrict 
);

create table Tag(
	nome varchar(15) not null primary key
);

create table Brano(
	id      			serial	 	primary key,
	titolo      		varchar(50) not null,
	durata      		interval	second not null,
	data_composizione   date 		not null
);

create table Distributore(
	codice_univoco_fatturazione		int			primary key,       
	nome							varchar(100)	not null,
    telefono						char(20)		not null,
    email							varchar(40)		not null
);

create table Produttore(
	codice_univoco_fatturazione		int			primary key,       
	nome							varchar(100)	not null,
    telefono						char(20)		not null,
    email							varchar(40)		not null
);

create table Artista(
	nome_arte	varchar(30)	primary key
);

create table Solista(
	nome_arte		varchar(30)	primary key,
	nome			varchar(20)	not null,
	cognome			varchar(20)	not null,
	data_nascita	date
);

create table Contratto(
	id					serial			primary key,
	tipo				varchar(50)		not null,
	descrizione			varchar(200),
	data_inizio			date			not null,
	data_termine		date,
	produttore			int,
	distributore		int,
	artista				varchar(20),
	foreign key (produttore) references Produttore(codice_univoco_fatturazione) on update cascade on delete cascade,
	foreign key (distributore) references Distributore(codice_univoco_fatturazione) on update cascade on delete cascade,
	foreign key (artista) references Artista(nome_arte) on update cascade on delete cascade
);

create table Ricevuta(
	id				serial			primary key,
	importo			money			not null default 0,
	descrizione		varchar(200),
	data_emissione	date			not null,
	contratto		int,
	foreign key (contratto) references Contratto(id) on update cascade on delete restrict
);

create table Diritto_autore(
	DOI				varchar(100) primary key
) ;

create table Prodotto(
	id 					serial			primary key,
	data_pubblicazione	date, 
	copertina   		varchar(100), 
	titolo 				varchar(50) 	not null, 
	DOI     			varchar(50) 	unique, 
	foreign key (DOI) references Diritto_autore (DOI) on update cascade on delete set null 
);

create table Prodotto_fisico(
	tipo							varchar(20)		unique,
	prodotto						int,
	costo_produzione_per_copia		money,
	costo_vendita					money,
	percentuale_ricavo	decimal(3,2)	default 0,
	primary key (tipo, prodotto),
	foreign key (prodotto) references Prodotto(id) on update cascade on delete restrict
);

create table Compone_brano(
	traccia   int,
	brano     int,
	primary key (traccia, brano),
	foreign key (traccia) references Traccia(id) on update cascade on delete cascade, 
	foreign key (brano) references Brano(id) on update cascade on delete cascade
);

create table Ha_tag(
    brano		int,
    nome		varchar(15), 
    primary key (brano, nome),
    foreign key (brano) references Brano(id) on update cascade on delete cascade,
   	foreign key (nome) references Tag(nome) on update cascade on delete cascade
);

create table Appartiene_brano(
	brano 	int, 
	nomeGenere 	varchar(30) not null, 
	primary key(brano, nomeGenere),
	foreign key (brano) references Brano(id) on update cascade on delete cascade,
	foreign key (nomeGenere) references Genere_musicale(nome) on update cascade on delete cascade
);

create table Appartiene_prodotto(
	prodotto 	int, 
	nomeGenere 	varchar(30) not null, 
	primary key (prodotto, nomeGenere), 
	foreign key (prodotto) references Prodotto(id) on update cascade on delete cascade, 
	foreign key (nomeGenere) references Genere_musicale(nome) on update cascade on delete cascade
);

create table Forma_prodotto(
	brano 	int, 
	prodotto 	int, 
	primary key (brano, prodotto), 
	foreign key (brano) references Brano(id) on update cascade on delete no action, 
	foreign key (prodotto) references Prodotto(id) on update cascade on delete no action
);

create table Concessione(
	DOI					varchar(100),        
	azienda			int,
    data_inizio			date		not null,
    costo_mensile		money		not null,
	percentuale_ricavo	decimal(3,2)	default 0,
	primary key (DOI, azienda),
    foreign key (DOI) references Diritto_autore(DOI) on update cascade on delete cascade,
	foreign key (azienda) references Distributore(codice_univoco_fatturazione) on update cascade on delete cascade
) ;

create table Pubblica(
	azienda		int,         
	prodotto		int,	
    primary key (azienda, prodotto),
    foreign key (azienda) references Distributore(codice_univoco_fatturazione) on update cascade on delete cascade,
    foreign key (prodotto) references Prodotto(id) on update cascade on delete cascade
) ;

create table Produzione(
	azienda				int,     
	prodottoFisico			varchar(20)		not null,
	prodotto				int				not null,
    n_copie_prodotte		int				not null,
	primary key (azienda, prodottoFisico, prodotto),
    foreign key (azienda) references Produttore(codice_univoco_fatturazione) on update cascade on delete cascade,
    foreign key (prodottoFisico) references Prodotto_fisico(tipo) on update cascade on delete cascade
   ); 

create table Vendita(
	azienda			int,
	prodottoFisico		varchar(20),
	prodotto			int,
	n_copie_vendute		int				not null default 0,
	primary key (azienda, prodottoFisico, prodotto),
	foreign key (azienda) 		references Distributore(codice_univoco_fatturazione) 	on update cascade on delete set null,
	foreign key (prodottoFisico) 	references Prodotto_fisico(tipo) 						on update cascade on delete restrict
);

create table Detiene(
	DOI			varchar(100),
	artista		varchar(30),
	primary key (DOI, artista),
	foreign key (DOI) references Diritto_autore(DOI) on update cascade on delete cascade,
	foreign key (artista) references Artista(nome_arte) on update cascade on delete cascade
);


create table Compone_artista(
	artista	varchar(30),
	solista	varchar(30),
	primary key (artista, solista),
	foreign key (artista) references Artista(nome_arte) on update cascade on delete restrict,
	foreign key (solista) references Solista(nome_arte) on update cascade on delete restrict
);

create table Prodotta(
	artista	varchar(20),
	traccia	int,
	primary key (artista, traccia),
	foreign key (artista) references Artista(nome_arte) on update cascade on delete set null,
	foreign key (traccia) references Traccia(id) on update cascade on delete cascade
);

create table Scritta(
	artista	varchar(20),
	traccia	int,
	primary key (artista, traccia),
	foreign key (artista) references Artista(nome_arte) on update cascade on delete set null,
	foreign key (traccia) references Traccia(id) on update cascade on delete cascade
);

create table Cantata(
	artista	varchar(20),
	traccia	int,
	primary key (artista, traccia),
	foreign key (artista) references Artista(nome_arte) on update cascade on delete set null,
	foreign key (traccia) references Traccia(id) on update cascade on delete cascade
);

create table Prenotazione(
	data			timestamp,
	studio		int,
	artista	varchar(20),
	durata			interval			hour not null default '1 hours',
	ricevuta		int,
	primary key (data, studio, artista),
	foreign key (studio) references Studio(id) on update cascade on delete restrict,
	foreign key (artista) references Artista(nome_arte) on update cascade on delete restrict,
	foreign key (ricevuta) references Ricevuta(id) on update cascade on delete restrict
);

/* POPOLAMENTO DEL DATABASE */

insert into Studio (id, nome, costo_orario, via, n_civico, CAP, stato) values
(1, 'AlbaStudio1', 20, 'via della marmotta', '12', '30456', 'it'),
(2, 'AlbaStudio2', 30, 'viale del tutto', '42', '42420', 'it'),
(3, 'AlbaStudio3', 10, 'via dei pesci', '1', '30456', 'it');

insert into Traccia (id, denominazione, durata, data_registrazione, studio) values
(1, 'Traccia1', '00:02:30', '2019-06-06', 1),
(2, 'Traccia2', '00:03:37', '2019-07-09', 1),
(3, 'Base26', '00:07:20', '2020-06-26', 2),
(4, 'Base2', '00:04:00', '2019-02-13', 3),
(5, 'Cantato20-02-03', '00:01:02','2020-02-03', 2),
(6, 'Traccia2tony', '00:01:30', '2019-08-22', 3),
(7, 'Traccia4prova', '00:00:41', '2020-12-19', 3),
(8, 'test1', '00:09:10', '2020-11-18', 1),
(9, 'beep3', '00:00:10', '2018-09-27', 1),
(10, 'catanta1', '00:02:30', '2018-08-27', 3),
(11, 'traccia4', '00:04:10', '2018-06-17', 3);

insert into Genere_musicale (nome, sottogenere) values
('trap', null),
('drill', 'trap'),
('rock', null),
('punk rock', 'rock'),
('elettronica', null),
('techno', 'elettronica');

insert into Tag(nome) values
('explicit'),
('chill'),
('relax'),
('aggressive');

insert into Brano (id, titolo, durata, data_composizione) values
(1, 'Gelato', '00:02:30', '2019-07-23'),
(2, 'Casa blu', '00:02:30', '2019-07-26'),
(3, 'GangSkrt', '00:02:30', '2018-03-11'),
(4, 'Spongebob', '00:02:30', '2019-07-03'),
(5, 'La cantata del fattorino', '00:02:30', '2019-05-12'),
(6, 'Eh si', '00:02:30', '2019-11-23'),
(7, 'Cinque', '00:02:30', '2020-01-20'),
(8, 'Trapperino', '00:02:30', '2018-10-15');

insert into Distributore(codice_univoco_fatturazione, nome, telefono, email) values
('0123', 'Distribu', '3459573859', 'segreteria@distribu.it'),
('0233', 'Mondodori', '33595701839', 'contact@mododori.it'),
('0333', 'Filtrinelli', '31525781579', 'contact@filtrinelli.it');

insert into Produttore(codice_univoco_fatturazione, nome, telefono, email) values
('0723', 'Fabbricahaha', '32535307639', 'segreteria@fabbricahaha.it'),
('0823', 'Fabbrica dello sghigno', '31536337669', 'contact@fabbricadellosghigno.it');

insert into Artista (nome_arte) values
('Giorgi'),
('Daft Funk'),
('Dark Polo'),
('TonyF'),
('Claudio Bisios'),
('Travis Scotty');

insert into Solista (nome_arte, nome, cognome, data_nascita) values
('TonyF', 'Antonio', 'Effe', '1996-05-28'),
('Pyrex', 'Firo', 'Rex', '1982-03-03'),
('Claudio Bisios', 'Claudio', 'Bisios', '1985-10-21'),
('Travis Scotty' , 'Travis', 'Scotty', '1991-04-25'),
('Daft1', 'Daft', 'Uno', '2002-09-02'),
('Daft2', 'Daft', 'Due', '1984-01-27'),
('GiorgioGrasso', 'Giorgio', 'Degan', '1989-09-26'),
('GiorgioAlto', 'Giorgio', 'Scattolin', '1999-01-10');

insert into Contratto (id, tipo, descrizione, data_inizio, data_termine, produttore, distributore, artista) values
(1, 'ArtConPrenotazione', 'Paga la prenotazione', '2020-01-02', '2020-10-02', null, null, 'Giorgi'),
(2, 'ArtConPrenotazione', 'Paga la prenotazione', '2019-03-25', null, null, null, 'Daft Funk'),
(3, 'ArtSenzaPrenotazione', 'Non paga la prenotazione', '2018-04-05', null, null, null, 'Dark Polo'),
(4, 'ArtSenzaPrenotazione', 'Non paga la prenotazione', '2013-03-12', '2015-06-30', null, null, 'TonyF'),
(5, 'ArtSenzaPrenotazione', 'Non paga la prenotazione', '2017-03-04', null, null, null, 'Claudio Bisios'),
(6, 'ArtConPrenotazione', 'Paga la prenotazione', '2020-01-03', '2020-03-02', null, null, 'Travis Scotty'),
(7, 'Produzione', null, '2020-04-05', null, '0723', null, null),
(8, 'VenditaCopie', null, '2019-05-05', null, null, '0123', null),
(9, 'VenditaCopie', null, '2019-10-25', null, null, '0233', null),
(10, 'ConcessioneDiritto', null, '2019-03-04', null, null, '0123', null),
(11, 'ConcessioneDiritto', null, '2019-09-08', null, null, '0233', null),
(12, 'Produzione', null, '2020-04-05', null, '0823', null, null),
(13, 'VenditaCopie', null, '2019-10-25', null, null, '0333', null),
(14, 'ConcessioneDiritto', null, '2019-09-08', null, null, '0333', null);

insert into Ricevuta (id, importo, descrizione, data_emissione, contratto) values
(1, 40, 'Prenotazione Studio 1', '2019-04-06', 1),
(2, 10, 'Prenotazione Studio 3', '2019-04-25', 1),
(3, 40, 'Prenotazione Studio 3', '2018-02-22', 6),
(4, 60, 'Prenotazione Studio 2', '2020-10-19', 2),
(5, 20, 'Prenotazione Studio 1', '2019-12-24', 6),
(6, 5100, 'Ordine cd', '2020-10-19', 7),
(7, 2850, 'Ordine vinili', '2020-10-01', 7),
(8, 5400, 'Ordine cd deluxe', '2019-05-22', 12),
(9, 4500, 'Ordine cassette', '2019-05-15', 12),
(10, 18450, 'Vendita cd', '2020-10-30', 8),
(11, 6020, 'Vendita vinili', '2020-10-15', 8),
(12, 6020, 'Vendita vinili', '2020-10-17', 9),
(13, 5490, 'Vendita cd deluxe', '2019-06-02', 13),
(14, 5490, 'Vendita cd deluxe', '2019-06-10', 8),
(15, 18620, 'Vendita cassette', '2020-11-10', 13),
(16, 13500, 'Concessione p.1', '2020-07-23', 10),
(17, 13500, 'Concessione p.1', '2020-08-23', 10),
(18, 13500, 'Concessione p.1', '2020-09-23', 10),
(19, 5600, 'Concessione p.2', '2019-08-27', 10),
(20, 3500, 'Concessione p.3', '2019-07-05', 10),
(21, 4650, 'Concessione p.4', '2019-11-23', 10),
(22, 7000, 'Concessione p.2', '2019-10-27', 11),
(23, 5100, 'Concessione p.4', '2019-12-23', 11),
(24, 2500, 'Concessione p.3', '2019-08-05', 14),
(25, 4000, 'Concessione p.2', '2019-11-27', 14);

insert into Diritto_autore (DOI) values
('10.3945'),
('10.3253'),
('10.6234'),
('10.9564'),
('10.1532');

insert into Prodotto (id, data_pubblicazione, copertina, titolo, DOI) values
(1, '2020-07-23', '/TrapKing.png', 'TrapKing', '10.3945'),
(2, '2019-07-27', '/CasaBlu.jpg', 'Casa Blu', '10.3253'),
(3, '2019-07-03', '/Sponge.jpg', 'Sponge', '10.6234'),
(4, '2019-11-23', '/Ehsi.jpg', 'Eh si', '10.9564'),
(5, null, '/Cinque.png', 'Cinque', '10.1532');

insert into Prodotto_fisico(tipo, prodotto, costo_produzione_per_copia, costo_vendita, percentuale_ricavo) values
('cd', 1, '0,34', '1,23', 0.20),
('vinile', 1, '0,57', '3,01', 0.10),
('cd-deluxe', 3, '0,54', '1,83', 0.15),
('cassetta', 3, '0,30', '1,33', 0.20);

insert into Compone_brano (traccia, brano) values
(1, 1),
(2, 1),
(3, 2),
(4, 3),
(5, 3),
(6, 4),
(7, 5),
(8, 6),
(9, 7),
(10, 8),
(11, 8);

insert into Ha_tag(brano, nome) values
(1, 'explicit'),
(1, 'chill'),
(2, 'relax'),
(3, 'chill'),
(4, 'explicit'),
(4, 'aggressive'),
(5, 'aggressive'),
(6, 'relax'),
(7, 'explicit'),
(7, 'aggressive');

insert into Appartiene_brano (brano, nomeGenere) values
(1, 'trap'),
(1, 'drill'),
(2, 'rock'),
(3, 'punk rock'),
(4, 'elettronica'),
(5, 'trap'),
(5, 'drill'),
(6, 'techno'),
(7, 'punk rock'),
(8, 'trap');

insert into Appartiene_prodotto (prodotto, nomeGenere) values
(1, 'trap'),
(2, 'rock'),
(3, 'elettronica'),
(3, 'trap'),
(4, 'techno'),
(5, 'punk rock');

insert into Forma_prodotto (brano, prodotto) values
(1, 1),
(3, 1),
(8, 1),
(2, 2),
(4, 3),
(5, 3),
(6, 4),
(7, 5);

insert into Concessione (DOI, azienda, data_inizio, costo_mensile, percentuale_ricavo) values
('10.3945', '0123', '2020-07-23', 13500, 0.10),
('10.3253', '0123', '2019-08-27', 5600, 0.20),
('10.6234', '0123', '2019-07-05', 3500, 0.15),
('10.9564', '0123', '2019-11-23', 4650, 0.18),
('10.3253', '0233', '2019-10-27', 7000, 0.14),
('10.9564', '0233', '2019-12-23', 5100, 0.10),
('10.6234', '0333', '2019-08-05', 2500, 0.21),
('10.3253', '0333', '2019-11-27', 4000, 0.23);

insert into Pubblica (azienda, prodotto) values
('0123', 1),
('0333', 2),
('0123', 3),
('0333', 4),
('0233', 2),
('0233', 4);

insert into Produzione(azienda, prodottoFisico, prodotto, n_copie_prodotte) values
('0723', 'cd', 1, 15000),
('0723', 'vinile', 1, 5000),
('0823', 'cd-deluxe', 3, 10000),
('0823', 'cassetta', 3, 15000);

insert into Vendita (azienda, prodottoFisico, prodotto, n_copie_vendute) values
('0123', 'cd', 1, 15000),
('0123', 'vinile', 1, 2000),
('0233', 'vinile', 1, 2000),
('0333', 'cd-deluxe', 3, 5000),
('0123', 'cd-deluxe', 3, 3000),
('0333', 'cassetta', 3, 14000);

insert into Detiene (DOI, artista) values
('10.3945', 'Giorgi'),
('10.3945', 'Dark Polo'),
('10.3945', 'Daft Funk'),
('10.3945', 'Claudio Bisios'),
('10.3945', 'Travis Scotty'),
('10.3253', 'TonyF'),
('10.6234', 'Travis Scotty'),
('10.9564', 'Dark Polo'),
('10.1532', 'Giorgi'),
('10.1532', 'Daft Funk');

insert into Compone_artista (artista, solista) values
('Dark Polo', 'TonyF'),
('TonyF', 'TonyF'),
('Dark Polo', 'Pyrex'),
('Claudio Bisios', 'Claudio Bisios'),
('Travis Scotty', 'Travis Scotty'),
('Daft Funk', 'Daft1'),
('Daft Funk', 'Daft2'),
('Giorgi', 'GiorgioGrasso'),
('Giorgi', 'GiorgioAlto');

insert into Prodotta (artista, traccia) values
('Giorgi', 1),
('Dark Polo', 2),
('Daft Funk', 4),
('Travis Scotty', 6),
('Dark Polo', 8),
('Daft Funk', 9),
('Travis Scotty', 10);

insert into Scritta (artista, traccia) values
('Giorgi', 1),
('Claudio Bisios', 5),
('Dark Polo', 8),
('TonyF', 3),
('Giorgi', 9);

insert into Cantata (artista, traccia) values
('Giorgi', 1),
('Dark Polo', 2),
('TonyF', 3),
('Claudio Bisios', 5),
('Travis Scotty', 7),
('Dark Polo', 8),
('Giorgi', 9),
('Travis Scotty', 10),
('Dark Polo', 11);

insert into Prenotazione (data, studio, artista, durata, ricevuta) values
('2019-04-06', 1, 'Giorgi', '02:00:00', 1),
('2020-11-23', 1, 'TonyF', '03:00:00', null),
('2019-02-28', 2, 'Dark Polo', '02:00:00', null),
('2019-09-12', 3, 'TonyF', '01:00:00', null),
('2019-04-25', 3, 'Giorgi', '01:00:00', 2),
('2018-02-22', 3, 'Travis Scotty', '04:00:00', 3),
('2020-10-19', 2, 'Daft Funk', '02:00:00', 4),
('2019-07-24', 1, 'Claudio Bisios', '03:00:00', null),
('2019-12-24', 1, 'Travis Scotty', '01:00:00', 5);

/*
indice per la ricerca filtrata sulle tracce
*/
drop index if exists idx_tracce;
create index idx_tracce on Traccia (denominazione);
/* esempio di query: ricerca delle tracce che contengono la keyword "base" nella denominazione (e che sono percui basi musicali). */
select * from traccia where lower(denominazione) like '%base%';

/*
Visualizza l’importo totale guadagnato da un prodotto. (costo di vendita - costo di produzione - percentuale per artista).
*/
select titolo as prodotto, sum(vendita_totale - (vendita_totale * percentuale_ricavo) - costo_totale) as totale
from (
	select titolo, percentuale_ricavo, sum(costo_vendita*n_copie_vendute) as vendita_totale, sum(costo_produzione_per_copia*n_copie_prodotte) as costo_totale
	from prodotto
		join prodotto_fisico on (prodotto_fisico.prodotto = prodotto.id)
		join vendita on (prodotto_fisico.prodotto = vendita.prodotto 
						 and prodotto_fisico.tipo = vendita.prodottofisico)
		join produzione on (prodotto_fisico.prodotto = produzione.prodotto 
							and prodotto_fisico.tipo = produzione.prodottofisico)
	group by titolo, percentuale_ricavo
) as costi
group by prodotto
order by totale desc

/*
Visualizza, per ogni genere, l’artista che ha più brani appartenenti al genere musicale.
*/
drop view if exists artisti_per_canzone;
create view artisti_per_canzone as
select nome_arte as artista, brano.id as brano, titolo
from brano
	join compone_brano on (brano.id = compone_brano.brano)
	join traccia on (traccia.id = compone_brano.traccia)
	left join prodotta on (traccia.id = prodotta.traccia)
	join artista on (artista.nome_arte = prodotta.artista)
	left join scritta on (artista.nome_arte = scritta.artista)
	left join cantata on (artista.nome_arte = cantata.artista)
group by nome_arte, brano.id, titolo;

select distinct nome, artista, max(totale) as massimo
from (
	select artista, nome, count(titolo)as totale
	from artisti_per_canzone
		join appartiene_brano on (artisti_per_canzone.brano = appartiene_brano.brano)
		join genere_musicale on (genere_musicale.nome = appartiene_brano.nomegenere)
	group by artista, nome
	) as generi_canzoni
group by nome, artista

/*
Visualizza il guadagno totale di un’artista. (guadagno concessioni + guadagno vendite - costo prenotazioni)

*/
select ricavi_concessione.artista, ricavo_concessioni + coalesce(ricavo_vendita, 0::money) - coalesce(costo_prenotazioni, 0::money) as guadagno
from (
	select nome_arte as artista, sum(((DATE_PART('year', CURRENT_DATE) - DATE_PART('year', concessione.data_inizio)) * 12 +
			(DATE_PART('month', CURRENT_DATE) - DATE_PART('month', concessione.data_inizio))) * (costo_mensile * percentuale_ricavo)) as ricavo_concessioni
	from artista
		join detiene on (artista.nome_arte = detiene.artista)
		join diritto_autore on (detiene.doi = diritto_autore.doi)
		join concessione on (diritto_autore.doi = concessione.doi)
	group by nome_arte
) as ricavi_concessione
left join (
	select nome_arte as artista, sum(ricevuta.importo) as costo_prenotazioni
	from artista
		join prenotazione on (prenotazione.artista = artista.nome_arte)
		join ricevuta on (ricevuta.id = prenotazione.ricevuta)
	group by nome_arte
) as costi_prenotazioni on (ricavi_concessione.artista = costi_prenotazioni.artista)
left join (
	select artista, sum(costo_vendita*n_copie_vendute*percentuale_ricavo) as ricavo_vendita
	from prodotto
		join prodotto_fisico on (prodotto_fisico.prodotto = prodotto.id)
		join vendita on (prodotto_fisico.prodotto = vendita.prodotto 
						 and prodotto_fisico.tipo = vendita.prodottofisico)
		join(
			select nome_arte as artista, forma_prodotto.prodotto as prodotto
			from forma_prodotto 
				join compone_brano on (compone_brano.brano = forma_prodotto.brano)
				left join prodotta on (compone_brano.traccia = prodotta.traccia)
				join artista on (artista.nome_arte = prodotta.artista)
				left join scritta on (artista.nome_arte = scritta.artista)
				left join cantata on (artista.nome_arte = cantata.artista)
			group by nome_arte, forma_prodotto.prodotto
		) as art_prod on (prodotto.id = art_prod.prodotto)
	group by artista
) as ricavi_vendita on (ricavi_vendita.artista = ricavi_concessione.artista)
order by guadagno desc

/*
Visualizza l’artista che ha creato più prodotti.
*/
drop view if exists artisti_per_prodotto;
create view artisti_per_prodotto as
select nome_arte as artista, compone_brano.brano as brano
from forma_prodotto 
	join compone_brano on (compone_brano.brano = forma_prodotto.brano)
	left join prodotta on (compone_brano.traccia = prodotta.traccia)
	join artista on (artista.nome_arte = prodotta.artista)
	left join scritta on (artista.nome_arte = scritta.artista)
	left join cantata on (artista.nome_arte = cantata.artista)
group by nome_arte, compone_brano.brano;

select massimo_prodotti.artista, massimo_prodotti.massimo
from(
	select artista, max(numero_prodotti) as massimo
	from(
		select artista, count(brano) as numero_prodotti
		from artisti_per_prodotto
		group by artista
		) as conto_prodotti
	group by artista
	) as massimo_prodotti
where massimo_prodotti.massimo = (
	select max(numero_prodotti)
	from(
		select artista, count(brano) as numero_prodotti
		from artisti_per_prodotto
		group by artista
		) as conto_prodotti
	)
group by artista, massimo_prodotti.massimo
order by artista asc

/*
Visualizzare i prodotti che hanno un maggior rapporto copie vendute/copie prodotte.
*/
select prodotto.titolo as prodotto, to_char((cast((sum(n_copie_vendute))as float)/cast((sum(n_copie_prodotte))as float)), '0.999') as rapporto
from prodotto
	join prodotto_fisico on (prodotto.id = prodotto_fisico.prodotto)
	join vendita on (prodotto_fisico.prodotto = vendita.prodotto 
					 and prodotto_fisico.tipo = vendita.prodottofisico)
	join produzione on (prodotto_fisico.prodotto = produzione.prodotto 
						and prodotto_fisico.tipo = produzione.prodottofisico)
group by prodotto.titolo
order by rapporto desc

/*
Visualizzare il distributore che ha acquistato il maggior numero di prodotti fisici per ogni prodotto.
*/
select v1.prodotto, v1.azienda, v1.massimo as copie_acquistate
from (
	select totale_copie.prodotto as prodotto, totale_copie.azienda, max(totale_copie.numero_copie) as massimo
	from(
		select prodotto.titolo as prodotto, distributore.nome as azienda, sum(n_copie_vendute) as numero_copie
		from prodotto
			join prodotto_fisico on (prodotto.id = prodotto_fisico.prodotto)
			join vendita on (prodotto_fisico.prodotto = vendita.prodotto 
							 and prodotto_fisico.tipo = vendita.prodottofisico)
			join distributore on (vendita.azienda = distributore.codice_univoco_fatturazione)
		group by prodotto.titolo, distributore.nome
		) as totale_copie
	group by totale_copie.prodotto, totale_copie.azienda
) as v1
join (
	select totale_copie.prodotto as prodotto, max(totale_copie.numero_copie) as massimo
	from(
		select prodotto.titolo as prodotto, distributore.nome as azienda, sum(n_copie_vendute) as numero_copie
		from prodotto
			join prodotto_fisico on (prodotto.id = prodotto_fisico.prodotto)
			join vendita on (prodotto_fisico.prodotto = vendita.prodotto 
							 and prodotto_fisico.tipo = vendita.prodottofisico)
			join distributore on (vendita.azienda = distributore.codice_univoco_fatturazione)
		group by prodotto.titolo, distributore.nome
		) as totale_copie
	group by totale_copie.prodotto
) as v2
on (v1.massimo = v2.massimo)
order by copie_acquistate desc


/*
g++ alba.cpp -L dependencies/lib -lpq -o alba
*/
commit;


