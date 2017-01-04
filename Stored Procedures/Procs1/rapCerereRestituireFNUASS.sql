/**
	Procedura este folosita pentru a lista Cererea de restituire de la FNUASS. 
**/
create procedure rapCerereRestituireFNUASS (@sesiune varchar(50), @datajos datetime, @datasus datetime, @parXML xml='<row/>')
AS
/*
	exec rapCerereRestituireFNUASS '', '01/01/2016', '01/31/2016', '<row />'
*/
begin try 
	/*	Procedura specifica pentru validari. */
	if exists (select * from sysobjects where name ='rapCerereRestituireFNUASSSP')
		exec rapCerereRestituireFNUASSSP @sesiune=@sesiune, @datajos=@datajos, @datasus=@datasus, @parXML=@parXML

	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	DECLARE @codfisc VARCHAR(100), @caen VARCHAR(100), @sefpers varchar(100), @compartiment varchar(100), 
		@tip varchar(2), @mesaj varchar(1000), @cTextSelect nvarchar(max), @debug bit, 
		@utilizator varchar(50), @lista_lm int, @nrCertificateCM int, @perioada varchar(1000), @lmUtilizator varchar(20), @lmFiltru int, @nrLMFiltru int
	
	exec wIaUtilizator @sesiune=@sesiune, @utilizator=@utilizator output

	set @lista_lm=dbo.f_areLMFiltru(@utilizator)
	
	select @datajos=dbo.BOM(@datajos), @datasus=dbo.EOM(@datasus)
	
	/**
		Informatiile din PAR sau similare se iau o singura data, nu in selectul principal care ar cauza rularea instructiunilor de multe ori
	*/
	select	@codfisc=(case when parametru='CODFISC' then rtrim(val_alfanumerica) else @codfisc end),
			@caen=(case when parametru='CAEN' then rtrim(val_alfanumerica) else @caen end),
			@sefpers=(case when parametru='SEFPERS' then rtrim(val_alfanumerica) else @sefpers end),
			@compartiment=(case when parametru='COMP' then rtrim(val_alfanumerica) else @compartiment end)
	from par
	where Tip_parametru='GE' and Parametru in ('SEFPERS') 
		or Tip_parametru='PS' and Parametru in ('CAEN','COMP','CODFISC')

--	in cazul BD multifirma stabilesc locul de munca pe care lucreaza utilizatorul
	select @lmFiltru=isnull(min(Cod),''), @nrLMFiltru=count(1) from LMfiltrare where utilizator=@utilizator and cod in (select cod from lm where Nivel=1)
	if @nrLMFiltru=1
		select @lmUtilizator=@lmFiltru

	/** Datele despre firma se vor stoca de acum incolo in tabela #dateFirma */
	IF OBJECT_ID('tempdb.dbo.#dateFirma') IS NOT NULL 
		DROP TABLE #dateFirma
	CREATE TABLE #dateFirma(locm varchar(50))

	exec wDateFirma_tabela

	insert into #dateFirma(locm)
	select @lmUtilizator

	EXEC wDateFirma

	set @nrCertificateCM=
		isnull((select count(1) 
			from D112asiguratD d 
				left outer join LMFiltrare lu on lu.utilizator=@utilizator and lu.cod=d.Loc_de_munca
			where d.Data between @datajos and @datasus
				and (@lista_lm=0 or lu.cod is not null)),0)

	set @perioada=''
	select @perioada=@perioada+rtrim(LunaAlfa)+' '+(case when year(@dataJos)<>year(@dataSus) then convert(varchar(4),year(data_lunii)) else '' end)+', '
	from fCalendar(@datajos, @dataSus) where data=Data_lunii
	select @perioada=left(@perioada,len(rtrim(@perioada))-1)
	if year(@datajos)=year(@datasus)
		set @perioada=rtrim(@perioada)+' '+convert(varchar(4),year(@dataSus))

--	Date cerere
	SELECT top 1
		max(df.firma) as denunit, max(isnull(nullif(@codfisc,''),df.codfiscal)) as codfisc, max(df.ordreg) as ordreg, max(df.judet) as judet, max(df.sediu) as localitate, max(df.adresa) as adrunit, 
		@caen as caen, max(df.banca) as banca, max(df.cont) as contbanca, 
		max(df.dirgen) as dirgen, max(df.direc) as direc, max(df.fdirec) as fdirec, @sefpers as sefpers, max(df.telfax) as telefon, max(df.email) as email, 
		@compartiment as comp, max(df.fdirgen) as functierepr, max(df.dirgen) as numerepr, 
		sum(convert(decimal(10),a.C2_16)) as J1, sum(convert(decimal(10),a.C2_26)) as J2, sum(convert(decimal(10),a.C2_36)) as J3, 
		sum(convert(decimal(10),a.C2_46)) as J4, sum(convert(decimal(10),a.C2_56)) as J5, 
		sum(convert(decimal(10),a.C2_10)) as prestatii, sum(convert(decimal(10),a.C2_9)) as cci, 
		(case when dbo.EOM(@dataJos)=dbo.EOM(@dataSus) then sum(convert(decimal(10),a.C2_130)) 
			else sum(convert(decimal(10),a.C2_10))-sum(convert(decimal(10),a.C2_9)) end) as sumadevirat, 
		dbo.Nr2Text((case when dbo.EOM(@dataJos)=dbo.EOM(@dataSus) then sum(convert(decimal(10),a.C2_130)) 
			else sum(convert(decimal(10),a.C2_10))-sum(convert(decimal(10),a.C2_9)) end)) as sumadeviratStr,
		@nrCertificateCM as NrCertificate, 
		(case when dbo.EOM(@dataJos)=dbo.EOM(@dataSus) then 'luna' else 'lunile' end)+' '+rtrim(@perioada) as perioada,
		(case when dbo.EOM(@dataJos)=dbo.EOM(@dataSus) then 'lunii' else 'lunilor' end)+' '+rtrim(@perioada) as perioada1
	FROM D112AngajatorB a
		left outer join LMFiltrare lu on lu.utilizator=@utilizator and lu.cod=a.Loc_de_munca
		left outer join #dateFirma df on 1=1
	where data between @dataJos and @dataSus
		and (@lista_lm=0 or lu.cod is not null)
	
end try
begin catch
	set @mesaj=ERROR_MESSAGE()+ ' (rapCerereRestituireFNUASS)'
	raiserror(@mesaj, 11, 1)
end catch