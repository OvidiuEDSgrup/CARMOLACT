--***
CREATE procedure rapDocumente_faTabela @sesiune varchar(50)=null, @parxml xml =null
as

if object_id('tempdb..#rapDocumente_tabela') is null create table #rapDocumente_tabela (subunitate varchar(1) default '1')

alter table #rapDocumente_tabela add tipnivel varchar(2000) default '', cod varchar(200) default '', parinte varchar(200) default '', nr_crt int default 0, cantitate decimal(15,3) default 0,
		valCost decimal(15,2) default 0, lm varchar(2000) default '',
		comanda varchar(2000) default '', gestiune varchar(2000)default '', TVA decimal(15,2) default 0, tip varchar(20) default '', numar varchar(20)  default '',
		data datetime default '1901-1-1', um varchar(50) default '', pret_de_stoc varchar(30) default 0, pret_vanzare varchar(30) default 0, pret_valuta varchar(30) default 0,
		discount decimal(15,2) default 0
		--> campurile specifice fiecarui raport se vor adauga ulterior cu alter table
		, nivel varchar(200) default 0, numeNivel varchar(2000) default '', ordine varchar(2000) default 0,
		codAfisat varchar(1000) default '', explicatii varchar(2000) default '', nivel1 varchar(200) default '', numeNivel1 varchar(2000) default '',
		valuta varchar(20) default '', curs decimal(10,4) default 0,
		valgr decimal(15,2) default 0, topgr int default 0
