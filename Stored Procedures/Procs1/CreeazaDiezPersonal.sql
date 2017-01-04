create procedure CreeazaDiezPersonal @numeTabela varchar(100)
AS
begin try
	--	tabela utilizata in procedurile pentru calcul salar de baza (pornind de la salar de incadrare cu sporuri cu caracter permament setate sa intre in salarul de baza
	if @numeTabela='#personalSalBaza'
	Begin
		alter table #personalSalBaza
		add salar_de_incadrare float not null, salar_de_baza float not null,
			indemnizatia_de_conducere float not null, spor_specific float not null, 
			spor_conditii_1 float not null, spor_conditii_2 float not null, spor_conditii_3 float not null, 
			spor_conditii_4 float not null, spor_conditii_5 float not null, spor_conditii_6 float not null
	end
	if @numeTabela='#personalDetalii'
	Begin
		alter table #personalDetalii
		add rtipactident varchar(80), rcetatenie varchar(80), rnationalitate varchar(80), mentiuni varchar(100),
			localitate varchar(100), tipcontract varchar(100), datainchcntr datetime, temeiincet varchar(100), texttemei varchar(100), 
			detaliicntr varchar(100), excepdatasf varchar(100), reptimpmunca varchar(100), intervalreptm varchar(100), oreintervalreptm int,
			pasaport varchar(100), contractvechi varchar(100), datacntrvechi datetime
	end
end try

begin catch
	declare @mesajEroare varchar(1000)
	set @mesajEroare = ERROR_MESSAGE() + ' (' + OBJECT_NAME(@@PROCID) + ')'
	raiserror (@mesajEroare, 11, 1)
end catch
