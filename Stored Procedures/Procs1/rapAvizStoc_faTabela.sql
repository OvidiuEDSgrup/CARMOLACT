--***
CREATE PROCEDURE rapAvizStoc_faTabela @sesiune varchar(50)=null, @parxml xml = null
as

if object_id('tempdb..#rapAvizStoc_tabela') is null create table #rapAvizStoc_tabela (cod varchar(100) default '')

alter table #rapAvizStoc_tabela
	add dencod varchar(1000) default '', um varchar(50) default '', gestiune varchar(100)default '', dengestiune varchar(1000)default '', data datetime default '1901-1-1'
		, stoc decimal(20,5) default 0, pret decimal(20,5) default 0
/*
RTRIM(s.cod) AS cod, MAX(RTRIM(n.Denumire)) AS dencod, MAX(RTRIM(n.UM)) AS um, RTRIM(s.gestiune) AS gestiune,
		MAX(RTRIM(g.Denumire_gestiune)) AS dengestiune, MIN(s.data) AS data, SUM(s.stoc) AS stoc, max(s.pret_cu_amanuntul) AS pret
		*/
