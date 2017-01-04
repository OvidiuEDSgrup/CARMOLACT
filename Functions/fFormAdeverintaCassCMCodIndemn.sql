--***
/*	Functie utilizata pentru generarea formularului de adeverinta cass (partea de concedii medicale, grupata de coduri de indemnizatie). */

Create function dbo.fFormAdeverintaCassCMCodIndemn ()
returns @cass_cm table
	(marca char(6), cod_indemnizatie varchar(100), zile_cm int, zile_calend_cm int, total_zile_cm int, total_zile_calend_cm int)
as
begin
	declare @cTerm char(8), @marca char(6)
	Set @cTerm=isnull((select convert(char(8), abs(convert(int, host_id())))),'')
	select @marca=Numar from avnefac where Terminal=@cTerm
	--Set @cTerm='1244'
	
	insert into @cass_cm 
	select cm.Marca, max(ci.tip_diagnostic_certificat+' - '+rtrim(ci.denumire)) as cod_indemnizatie,
		sum(cm.zile_lucratoare) as zile_cm, sum(DATEDIFF(day,cm.Data_inceput,cm.Data_sfarsit)+1) as zile_calend_cm,
		(select sum(cm1.zile_lucratoare) from conmed cm1 where cm1.marca=cm.marca and cm1.data>=max(a.data_facturii) 
			and cm1.data_inceput<=max((case when len(a.cod_tert)>4 and ISDATE(a.cod_tert)=1 then a.cod_tert else a.data end))) as total_zile_cm,
		(select sum(DATEDIFF(day,cm1.Data_inceput,cm1.Data_sfarsit)+1) from conmed cm1 where cm1.marca=cm.marca and cm1.data>=max(a.data_facturii) 
			and cm1.data_inceput<=max((case when len(a.cod_tert)>4 and ISDATE(a.cod_tert)=1 then a.cod_tert else a.data end))) as total_zile_calend_cm
	from conmed cm
		left outer join fDiagnostic_CM() ci on ci.Tip_diagnostic=cm.Tip_diagnostic, avnefac a
	where a.Terminal=@cTerm and cm.marca=a.numar and cm.data>=a.data_facturii and cm.data_inceput<=(case when len(a.cod_tert)>4 and ISDATE(a.cod_tert)=1 then a.cod_tert else a.data end)
	GROUP BY cm.marca, cm.Tip_diagnostic
	
	return
End

/*
	select * from fFormAdeverintaCassCMCodIndemn()
*/