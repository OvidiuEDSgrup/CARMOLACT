
CREATE PROCEDURE wOPPreluareRetineriSalariiInOrdineDePlata @sesiune VARCHAR(50), @parXML XML
AS
BEGIN TRY
	DECLARE @utilizator VARCHAR(20), @dreptConducere INT, @areDreptCond INT, @docPozitii XML, @dataplatii DATETIME, @cont VARCHAR(20), @explicatiiOP VARCHAR(2000), 
		@luna INT, @an INT, @lunaalfa VARCHAR(15), @datajos DATETIME, @datasus DATETIME, 
		@benret VARCHAR(20), @denbenret VARCHAR(30), @banca VARCHAR(30), @lm VARCHAR(9), @marca VARCHAR(6), @sirmarci VARCHAR(200), 
		@obanca INT, @tipcard VARCHAR(30), @untippers INT, @tippers VARCHAR(1), @dreptacces char(1), 
		@mesaj VARCHAR(500), @contCorespondentPI VARCHAR(40), @NrOPInitial int, @marci_err varchar(2000), @lista_lm int

	EXEC wIaUtilizator @sesiune = @sesiune, @utilizator = @utilizator OUTPUT

	SET @dreptConducere=dbo.iauParL('PS','DREPTCOND')
	SET @cont = @parXML.value('(/*/@cont)[1]', 'varchar(20)')
	SET @dataplatii = isnull(@parXML.value('(/*/@dataplatii)[1]', 'datetime'),@parXML.value('(/*/@data)[1]', 'datetime'))
	SET @luna = @parXML.value('(/*/@luna)[1]', 'int')
	SET @an = @parXML.value('(/*/@an)[1]', 'int')
	SET @explicatiiOP = @parXML.value('(/*/@explicatii)[1]', 'varchar(2000)')
	SET @benret = isnull(@parXML.value('(/*/@benret)[1]', 'char(20)'),'')
	SET @banca = @parXML.value('(/*/@banca)[1]', 'varchar(30)')
	SET @lm = @parXML.value('(/*/@lm)[1]', 'varchar(9)')
	SET @marca = @parXML.value('(/*/@marca)[1]', 'varchar(6)')
	SET @sirmarci = @parXML.value('(/*/@sirmarci)[1]', 'varchar(200)')
	SET @tippers = @parXML.value('(/*/@tippers)[1]', 'varchar(1)')
	SET @dreptacces = @parXML.value('(/*/@dreptacces)[1]', 'varchar(1)')
	SET @NrOPInitial = isnull(@parXML.value('(/*/@ordin)[1]', 'int'),0)
	if @NrOPInitial<>0
		set @NrOPInitial=@NrOPInitial-1
	
	if @benret=''
		raiserror ('Beneficiar retinere necompletat!',16,1)

	SET @datajos=convert(datetime,str(@luna,2)+'/01/'+str(@an,4))
	SET @datasus=dbo.EOM(@datajos)
	SELECT @lunaalfa=LunaAlfa from fCalendar(@datasus,@datasus)
	SET @obanca=(case when isnull(@banca,'')='' then 0 else 1 end)
	SET @untippers=(case when isnull(@tippers,'A')='A' then 0 else 1 end)
	SELECT @contCorespondentPI=cont_creditor from benret where cod_beneficiar=@benret
	SET @lista_lm=dbo.f_areLMFiltru(@utilizator)

--	verific daca utilizatorul are/nu are dreptul de Salarii conducere (SALCOND)
	SET @areDreptCond=0
	IF @dreptConducere=1 
	BEGIN
		SET @areDreptCond=isnull((select dbo.verificDreptUtilizator(@utilizator,'SALCOND')),0)
		IF @areDreptCond=0
			SET @dreptacces='S'
	END

	IF OBJECT_ID('tempdb..#pozitiiPreluare') IS NOT NULL
		DROP TABLE #pozitiiPreluare

	CREATE TABLE #pozitiiPreluare (marca VARCHAR(20), contiban varchar(100), suma FLOAT, ordin varchar(20))

	/** Populare din salarii (avans, rest de plata)**/
	INSERT INTO #pozitiiPreluare (marca, contiban, suma, ordin)
	SELECT RTRIM(r.Marca) marca, rtrim(isnull(nullif(b.Cont_banca,''),isnull(nullif(p.detalii.value('(/row/@ibangarantii)[1]','varchar(100)'),''),'')))
			,r.Retinut_la_lichidare as suma, convert(varchar(20),@NrOPInitial+ROW_NUMBER() OVER (ORDER BY p.Nume))
	from resal r
		LEFT OUTER JOIN personal p on p.marca=r.marca
		LEFT OUTER JOIN benret b on b.cod_beneficiar=r.Cod_beneficiar
		LEFT OUTER JOIN istpers ip on ip.marca=r.marca and ip.data=r.data
		LEFT OUTER JOIN LMFiltrare lu on lu.utilizator=@utilizator and lu.cod=isnull(ip.Loc_de_munca,p.Loc_de_munca)
	where r.Cod_beneficiar=@benret and r.Data=@datasus
		and (@dreptConducere=0 or (@dreptConducere=1 and @areDreptCond=1 and (@dreptacces='T' or @dreptacces='C' and p.pensie_suplimentara=1 or @dreptacces='S' and p.pensie_suplimentara<>1)) 
			or (@dreptConducere=1 and @areDreptCond=0 and @dreptacces='S' and p.pensie_suplimentara<>1))
		and (isnull(@marca,'')='' or r.Marca=@marca)
		and (isnull(@lm,'')='' or isnull(ip.Loc_de_munca,p.Loc_de_munca) like rtrim(@lm)+'%')
		and (isnull(@sirMarci,'')='' or charindex (','+rtrim (r.Marca)+',',rtrim(@sirMarci))<>0) 
		and (@untippers=0 or p.tip_salarizare between (case when @tippers='T' then '1' else '3' end) and (case when @tippers='T' then '2' else '7' end))
		and (@lista_lm=0 or lu.cod is not null)

	IF EXISTS (SELECT 1 FROM sysobjects WHERE NAME = 'wOPPreluareRetineriSalariiInOrdineDePlataSP1')
		EXEC wOPPreluareRetineriSalariiInOrdineDePlataSP1 @sesiune=@sesiune, @parXML=@parXML

	if exists (select 1 from #pozitiiPreluare where nullif(contiban,'') is null) and 1=0
	begin
		set @marci_err = ''
		select @marci_err = @marci_err + RTRIM(Marca) + ',' from #pozitiiPreluare where nullif(contiban,'') is null
		set @marci_err = 'Sunt marci care nu au cont iban in dreptul sumelor preluate (' + left(@marci_err,LEN(@marci_err)-1) + ')!'		-- Sterg ultima virgula din @marci_err
		raiserror(@marci_err,16,1)
	end

	SET @docPozitii = (
			SELECT
				'1' AS preluare, @dataplatii data, @cont cont, 'S' sursa,'1' fara_luare_date,'SR' tip,'SR' tipOP,@explicatiiOP explicatii,
				(
					SELECT 
						rtrim(pp.contiban) AS iban, rtrim(p.Banca) AS banca, convert(DECIMAL(18, 5), pp.suma) suma, '1' stare, -- am pus stare implicita=1 la salarii
						(select p.Cod_numeric_personal cnp, rtrim(@contCorespondentPI) as contcorespondent, rtrim(pp.ordin) as ordin FOR XML RAW,type) detalii, p.Marca marca,
							RTRIM(@denbenret) +' '+RTRIM(@lunaalfa)+' - '+CONVERT(char(4),@an)+' '+isnull(rtrim(p.Nume), '') AS explicatii
					FROM #pozitiiPreluare pp
						LEFT JOIN personal p ON p.Marca = pp.Marca
					FOR XML raw, type
				)
			FOR XML raw, type
			)

	EXEC wScriuPozOrdineDePlata @sesiune = @sesiune, @parXML = @docPozitii

END TRY

BEGIN CATCH
	SET @mesaj = ERROR_MESSAGE() + ' (wOPPreluareRetineriSalariiInOrdineDePlata)'
	RAISERROR (@mesaj, 16, 1)
END CATCH
