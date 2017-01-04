--***
create procedure rapJurnalTvaLaIncasare_faTabela @sesiune varchar(50)=null, @parxml xml=null
as
if object_id('tempdb..#rapJurnalTvaLaIncasare_Tabela') is null
		create table #rapJurnalTvaLaIncasare_Tabela(subunitate varchar(1) default '1')
	
alter table #rapJurnalTvaLaIncasare_Tabela
	add nrcrt int, factura varchar(50), data datetime, denumireTert varchar(1000), codFiscal varchar(200), totalFactura decimal(12,2),
		baza decimal(12,2), tva decimal(12,2), docIncasare varchar(50), dataDocInc datetime, sumaIncasata decimal(12,2), soldInitTLI decimal(12,2),
		rulajDebitTLI decimal(12,2), rulajCreditTLI decimal(12,2), bazaSoldTLI decimal(12,2), soldTLI decimal(12,2), ordonare varchar(1000), cota_tva decimal(3)
