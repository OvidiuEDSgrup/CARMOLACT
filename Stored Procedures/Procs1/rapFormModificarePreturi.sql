
create procedure rapFormModificarePreturi @sesiune varchar(50), @numar varchar(20), @data datetime
as
begin try

set transaction isolation level read uncommitted

	declare @locm varchar(50), @detalii xml, @delegat varchar(20), @tertDelegat varchar(20),
		@mesaj varchar(1000), @subunitate varchar(10), @tertCustodie varchar(100), @gestiuneCustodie varchar(50),
		@gestiune varchar(20), @tert varchar(20), @utilizator varchar(50), @detalii_gest varchar(100)
	
	exec wIaUtilizator @sesiune = @sesiune, @utilizator = @utilizator output
	exec luare_date_par 'GE', 'SUBPRO', 0, 0, @subunitate output

	if object_id('tempdb..#PozDocFiltr') is not null
		drop table #PozDocFiltr

	/** Pregatire prefiltrare din tabela PozDoc pentru a nu lucra cu toata, decat ceea ce este de interes dupa filtre**/
	create table [dbo].[#PozDocFiltr] ([Numar] [varchar](20) NOT NULL, [Cod] [varchar](20) NOT NULL, [Data] [datetime] NOT NULL, 
		[Gestiune] [varchar](20) NOT NULL, [Cantitate] [float] NOT NULL, [pret_amanunt_predator] [float] NOT NULL, [Pret_cu_amanuntul] [float] NOT NULL, 
		[Cod_intrare] [varchar](20) NOT NULL, [Tert] [varchar](20) NOT NULL, [Gestiune_primitoare] [varchar](20) NOT NULL, [numar_pozitie] [int],
		[Locatie] [varchar](50), [Utilizator] [varchar](200), [TVA_neexigibil][float] NOT NULL, idPozdoc int
		)

	insert into #PozDocFiltr (
		Numar, Cod, Data, Gestiune, Cantitate, pret_amanunt_predator, Pret_cu_amanuntul, 
		Cod_intrare, Tert, Gestiune_primitoare, numar_pozitie, Locatie, Utilizator, TVA_neexigibil, idPozdoc
		)
	select 
		rtrim(Numar), rtrim(Cod), Data data, rtrim(Gestiune), Cantitate, Pret_amanunt_predator, Pret_cu_amanuntul,
		rtrim(Cod_intrare), rtrim(pz.Tert), rtrim(Gestiune_primitoare), Numar_pozitie, Locatie, rtrim(Utilizator),
		pz.TVA_neexigibil, idPozdoc
	from pozdoc pz
	where pz.subunitate = @subunitate
		AND pz.tip = 'TE'
		AND pz.data = @data
		and pz.numar = @numar

	create index IX1 on #pozdocfiltr(numar, cod, cod_intrare)
	create index IX2 on #pozdocfiltr(cod)
	
	select top 1 @detalii = detalii, @locm = RTRIM(Loc_munca) from doc where tip = 'TE' and numar = @numar and data = @data

	/** Datele despre firma se vor stoca de acuma incolo in tabela #dateFirma */
	IF OBJECT_ID('tempdb.dbo.#dateFirma') IS NOT NULL DROP TABLE #dateFirma
	CREATE TABLE #dateFirma(locm varchar(50))
	EXEC wDateFirma_tabela
	EXEC wDateFirma @locm = @locm

	select @detalii_gest = rtrim(detalii.value('(/row/@dengestdest)[1]','varchar(100)'))
	from doc
	where Subunitate = @subunitate and Tip = 'TE' and Data = @data and Numar = @numar

	if isnull(@detalii_gest, '') = ''
		select @detalii_gest = (select rtrim(g.denumire_gestiune)
								from doc d
								inner join gestiuni g on d.gestiune_primitoare = g.cod_gestiune
								where d.Subunitate = @subunitate and d.Tip = 'TE' and d.Data = @data and d.Numar = @numar)


	select @delegat = isnull(rtrim(@detalii.value('(/row/@delegat)[1]', 'varchar(20)')), ''),
		@tertDelegat = isnull(rtrim(@detalii.value('(/row/@tertdelegat)[1]', 'varchar(20)')), '')


	if @tertDelegat = ''
		exec luare_date_par 'UC', 'TERTGEN', 0, 0, @tertDelegat OUTPUT
	
	
	/** Selectul principal	**/
	select
		df.firma as firma, df.codFiscal as cif, df.ordreg as ordreg, df.judet as jud,
		df.sediu as loc, df.adresa as adr, df.cont as cont, df.banca as banca, df.capitalSocial,
		RTRIM(pz.numar) as NUMAR, convert(varchar(10), pz.data, 103) as data, 
		rtrim(g.denumire_gestiune) as predator,
		rtrim(pz.gestiune) as cod_gestiune,
		rtrim(@detalii_gest) as primitor,
		row_number() over (order by pz.numar_pozitie) as nrcrt,
		rtrim(n.Cod) as cod,
		rtrim(n.denumire) as explicatie,
		rtrim(n.um) as UM,
		round(pz.cantitate, 3) as CANT,
		pz.pret_amanunt_predator as pret_vechi,
		pz.Pret_cu_amanuntul AS pret_nou,
		ISNULL(ROUND(pz.cantitate * pz.pret_amanunt_predator, 2), 0) AS valoare_veche,
		ISNULL(ROUND(pz.cantitate * pz.Pret_cu_amanuntul, 2), 0) AS valoare_noua,

		--> diferente: valoare, adaos, tva neexigibil
		ABS(ISNULL(ROUND(pz.cantitate * pz.pret_amanunt_predator, 2), 0) - ISNULL(ROUND(pz.cantitate * pz.Pret_cu_amanuntul, 2), 0)) AS dif_valoare,
		ROUND(CONVERT(decimal(17,5), pz.Pret_cu_amanuntul * pz.TVA_neexigibil / (100.00 + pz.tva_neexigibil)), 2) AS tvaNeexUnitarIntrare,
		ROUND(CONVERT(decimal(17,5), pz.pret_amanunt_predator * pz.TVA_neexigibil) / (100.00 + pz.TVA_neexigibil), 2) AS tvaNeexUnitarIesire,

		CONVERT(float, 0) AS dif_adaos,
		CONVERT(float, 0) AS dif_tvaneex,

		round(pz.cantitate, 3) as CANT2, -- camp de rezerva pentru SP 
		idPozdoc,
		ISNULL(@detalii.value('(/row/@explicatii)[1]', 'varchar(300)'), '') AS observatii,

		/** Footer - date expeditie */
		isnull(rtrim(@detalii.value('(/row/@dendelegat)[1]', 'varchar(100)')), '') as NUMEDELEGAT,
		isnull(dbo.fStrToken(del.Buletin, 1, ','), '') as sr,
		isnull(dbo.fStrToken(del.Buletin, 2, ','), '') as nrbi,
		isnull(rtrim(del.Eliberat), '') as ELIB,
		isnull(rtrim(del.Mijloc_tp), '') as nrmij,
		isnull(convert(varchar(10), @detalii.value('(/row/@data_expedierii)[1]', 'datetime'), 103), convert(varchar(10), getdate(), 103)) as dataexp,
		isnull(@detalii.value('(/row/@ora_expedierii)[1]', 'varchar(6)'), '') as ORAEXP,
		'Operat: ' + rtrim(pz.utilizator) + '. Tiparit la ' + convert(varchar(10), getdate(), 103) + ' ' + convert(varchar(5), getdate(), 108)
			+ ', de catre ' + @utilizator as date_tiparire,
		pz.numar_pozitie as ordine,
		ISNULL(g.detalii.value('(/row/@dengestionar)[1]', 'varchar(300)'), '') AS gestionar
	into #date
	from #PozDocFiltr pz
	left join terti t on t.Subunitate = @subunitate and t.tert = left(pz.Locatie, 13)
	left join infotert inf on inf.Subunitate = @subunitate and inf.tert = t.tert and inf.Identificator <> '' and inf.Identificator = substring(pz.Locatie, 14, 5)
	left join infotert del on del.identificator = isnull(@delegat, '') and del.tert = isnull(@tertDelegat, '') and del.subunitate = 'C1'
	left join localitati l on t.localitate = l.cod_oras
	left join judete j on t.judet = j.cod_judet
	left join bancibnr b on b.Cod = t.Banca
	left join nomencl n on n.Cod = pz.Cod
	left join gestiuni g on pz.gestiune = g.cod_gestiune and g.Subunitate = @Subunitate
	left join #dateFirma df ON 1 = 1
	
	UPDATE #date
	SET dif_adaos = ROUND(CANT * (pret_nou - tvaNeexUnitarIntrare) - CANT * (pret_vechi - tvaNeexUnitarIesire), 2),
		dif_tvaneex = ROUND(CONVERT(decimal(17,5), CANT * (TvaNeexUnitarIntrare - TvaNeexUnitarIesire)), 2)


	-- SP
	if exists (select 1 from sys.sysobjects where name = 'rapFormModificarePreturiSP')
		exec rapFormModificarePreturiSP @sesiune = @sesiune, @numar = @numar, @data = @data
	
	select * from #date order by ordine

end try
begin catch
	set @mesaj = ERROR_MESSAGE() + ' (' + OBJECT_NAME(@@PROCID) + ')'
	raiserror(@mesaj, 16, 1)
end catch
