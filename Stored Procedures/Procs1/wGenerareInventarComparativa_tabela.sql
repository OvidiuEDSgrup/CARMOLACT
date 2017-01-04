--***
CREATE PROCEDURE wGenerareInventarComparativa_tabela @sesiune VARCHAR(50)=null, @parXML XML=null
/*	procedura de creare a tabelei de transfer intre procedura wGenerareInventarComparativa_tabela si apelant */
as
if object_id('tempdb..#inventar_comparativa') is null create table #inventar_comparativa(cod varchar(20))

alter table #inventar_comparativa add
/*	stoc_scriptic FLOAT, stoc_faptic FLOAT, pret FLOAT, plusinv FLOAT, minusinv FLOAT, valplusinv FLOAT, 
		valminusinv FLOAT,pretstoc float,pretam float
		, lot varchar(100) default '', locatie varchar(100) default ''
*/		
		
	stoc_scriptic FLOAT, stoc_faptic FLOAT, pret FLOAT, plusinv FLOAT, minusinv FLOAT, valplusinv FLOAT, 
		valminusinv FLOAT,pretstoc float,pretam float, cont varchar(40) default '', locatie varchar(100) default '', lot varchar(100) default ''
