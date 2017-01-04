--***
create procedure rapRegistruDeCasa_faTabela @sesiune varchar(50)=null, @parxml xml=null
as
if object_id('tempdb..#rapRegistruDeCasa_Tabela') is null
		create table #rapRegistruDeCasa_Tabela(subunitate varchar(1))
	
alter table #rapRegistruDeCasa_Tabela
	add 
		cont varchar(20), data datetime, numar varchar(20), plata_incasare varchar(2), tert varchar(20), 
			factura varchar(20), marca varchar(100), cont_corespondent varchar(20), suma decimal(17,5), sumai decimal(17,5), sumap decimal(17,5), valuta varchar(3), 
			curs decimal(17,5), suma_valuta decimal(17,5), sumavi decimal(17,5), sumavp decimal(17,5), explicatii varchar(2000), utilizator varchar(100), 
			jurnal varchar(10), numar_pozitie int, sold decimal(17,5), soldv decimal(17,5), sold_prec decimal(17,5), soldv_prec decimal(17,5), 
			observatiiFooter varchar(max), antet int
