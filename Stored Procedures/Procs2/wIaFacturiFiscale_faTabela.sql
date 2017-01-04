--***
create procedure wIaFacturiFiscale_faTabela @sesiune varchar(50)=null, @parxml xml=null
as
if object_id('tempdb.dbo.#plajeserii') is null
		create table #plajeserii (idplaja int)
	
alter table #plajeserii
	add denumire varchar(200), numarinf varchar(20), numarsup varchar(20), ultimnr varchar(20), ordine int, seriefiscala varchar(100), serie varchar(100), nrmin_folosit bigint, nrmax_folosit bigint,marcat int

-->	tabela #plajeUtilizate va fi creata in procedura Declaratia394, ce va apela procedura wIaFacturiFiscale unde se va popula aceasta tabela
if object_id('tempdb.dbo.#plajeUtilizate') is not null
	alter table #plajeUtilizate
		add denumire varchar(200), serie varchar(100), numarinf varchar(20), numarsup varchar(20), tabela varchar(50), nr int, continuare int, observatii varchar(100)
