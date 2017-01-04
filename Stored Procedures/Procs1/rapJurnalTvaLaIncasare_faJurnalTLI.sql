--***
create procedure rapJurnalTvaLaIncasare_faJurnalTLI @sesiune varchar(50)=null, @parxml xml=null
as
if object_id('tempdb..#jurnalTLI') is null
		create table #jurnalTLI (Factura varchar(20))
	
alter table #jurnalTLI
	add data datetime,denTert varchar(80),cod_fiscal varchar(20),baza float,TVA float,doc_incasare varchar(20),data_incasare datetime,
		suma_incasata decimal(12,2),sold_initial_tli decimal(12,2),rulaj_debit_tli decimal(12,2),rulaj_credit_tli decimal(12,2),baza_sold_tli decimal(12,2),sold_tli decimal(12,2),tert varchar(20),
		cota_tva decimal(3)
