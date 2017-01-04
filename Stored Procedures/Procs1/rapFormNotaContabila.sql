--***
create procedure rapFormNotaContabila @sesiune varchar(50), @tip varchar(2), @numar varchar(20), @data datetime
as
begin try

	declare @utilizator varchar(20), @subunitate varchar(20)

	exec wIaUtilizator @sesiune = @sesiune, @utilizator = @utilizator output
	exec luare_date_par 'GE', 'SUBPRO', 0, 0, @subunitate output


	/** Datele despre firma se vor stoca de acuma incolo in tabela #dateFirma */
	IF OBJECT_ID('tempdb.dbo.#dateFirma') IS NOT NULL DROP TABLE #dateFirma
	
	CREATE TABLE #dateFirma (locm varchar(50))
	EXEC wDateFirma_tabela

	INSERT INTO #dateFirma (locm)
	SELECT DISTINCT ISNULL(d.Loc_munca, '') FROM pozncon d WHERE d.subunitate = @subunitate AND d.numar = @numar AND d.tip = @tip AND d.data = @data
	
	EXEC wDateFirma


	SELECT
		d.firma as unitate, d.codFiscal as cui, d.ordreg as ordreg, d.cont as cont, d.banca as banca,
		d.judet as judet, d.adresa as adresa, d.capitalSocial as capital,
		rtrim(pn.numar) as NC,
		rtrim(convert(varchar(10), pn.data, 103)) as DATA,
		rtrim(pn.cont_debitor) as CONTDB,
		rtrim(pn.cont_creditor) as CONTCR,
		convert(decimal(15,2), pn.suma) as SUMA,
		rtrim(pn.explicatii) as EXPLICATII,
		rtrim(pn.loc_munca) as LM,
		rtrim(pn.comanda) as COMANDA,
		(case when rtrim(isnull(pn.valuta, '')) = '' then '' else rtrim(pn.valuta) end) as VALUTA,
		(case when rtrim(isnull(pn.valuta, '')) = '' then '' else rtrim(pn.curs) end) as CURS,
		(case when rtrim(isnull(pn.valuta, '')) = '' then 0 else convert(decimal(15,2), pn.suma_valuta) end) as SUMAVALUTA
	FROM pozncon pn
	LEFT JOIN #dateFirma d ON d.locm = pn.loc_munca
	WHERE pn.subunitate = @subunitate
		and pn.tip = @tip
		and pn.numar = @numar
		and pn.Data = @data

end try
begin catch
	declare @mesajEroare varchar(500)
	set @mesajEroare = ERROR_MESSAGE() + char(10) + '(' + OBJECT_NAME(@@PROCID) + ')'
	raiserror(@mesajEroare, 16, 1)
end catch
