--***
create procedure rapRegistruPlatiIncasari_faTabela @sesiune varchar(50)=null, @parxml xml=null
as
if object_id('tempdb..#rapRegistruPlatiIncasari_Tabela') is null
		create table #rapRegistruPlatiIncasari_Tabela(subunitate varchar(1))
		
alter table #rapRegistruPlatiIncasari_Tabela add data datetime, plata_incasare varchar(2), numar varchar(20), explicatii varchar(500), incasari decimal(17,5),
			plati decimal(17,5), cont varchar(20)
