CREATE 
PROCEDURE [PropStocGestDocIntrariLapte] 
--DECLARE
	@sub char(9),
	@tip char(2),
	@numar char(8),
	@data datetime 
AS
DECLARE @com char(20), @tura real		
SELECT TOP 1 @com=l.comanda, @tura=l.tura
FROM IntrariLapte l
WHERE l.subunitate=@sub and l.data=@data and l.tip=@tip and l.numar=@numar
ORDER BY l.subunitate, l.tip, l.numar, l.data, l.numar_pozitie

PRINT 'comanda '+@com
PRINT 'tura '+convert(char,@tura)

PRINT '1-TEST DACA AJUNGE'


declare @NrPoz int, @MinNrPoz int
select @NrPoz = val_numerica from par where tip_parametru='DO' and parametru='POZITIE'

set @NrPoz = isnull(@NrPoz, 0) + 1
if @NrPoz > 999999999 set @NrPoz = 1

DECLARE @ContCorAE char(13)
SELECT @ContCorAE = val_alfanumerica FROM par WHERE tip_parametru='GE' and parametru='CCORAE'

if isnull(@ContCorAE, '')=''
	set @ContCorAE='6588'

DECLARE @CtCoresp char(13), @Ct378 char(13), @AnGest378 int, @AnGr378 int, @Ct4428 char(13), @AnGest4428 int, 
	@CtCorespAE char(13), @CuCtFactAE int, @CtFactAE char(13), @CtFact char(13), @CtAdaos char(13), @CtTVANx char(13)  

exec luare_date_par 'GE', 'CADAOS', @AnGest378 output, @AnGr378 output, @Ct378 output
exec luare_date_par 'GE', 'CNTVA', @AnGest4428 output, 0, @Ct4428 output
exec luare_date_par 'GE', 'CCORAE', 0, 0, @CtCorespAE output
exec luare_date_par 'GE', 'CONT_AE?', @CuCtFactAE output, 0, ''
exec luare_date_par 'GE', 'CONT_AE', 0, 0, @CtFactAE output

set @CtFact=(case when @CuCtFactAE=1 then @CtFactAE else @CtCoresp end)

DECLARE lapte_faptic_compartimente CURSOR FOR 
SELECT p.Cod, l.Compartiment, SUM(p.cantitate) AS cantitate
FROM pozdoc p
	INNER JOIN tiplapte tl ON p.cod=RTRIM(tl.cod)+'.'
	INNER JOIN intrariLapte l ON p.subunitate=l.subunitate AND p.tip=l.tip AND p.numar=l.numar 
		AND p.data=l.data AND p.numar_pozitie=l.numar_pozitie
WHERE p.subunitate=@sub AND p.tip IN ('AI', 'RM') AND p.data=@data and p.comanda= @com
	and l.tura=@tura
GROUP BY p.Cod, l.Compartiment
ORDER BY p.Cod, l.Compartiment

DECLARE @cod char(20), @comp char(20), @cantFcomp float(8), @cantScomp float(8), @semn float(8), @trecut bit

OPEN lapte_faptic_compartimente

FETCH NEXT FROM lapte_faptic_compartimente
INTO @cod, @comp, @cantFcomp
--PRINT 'TEST DACA AJUNGE1'

WHILE @@FETCH_STATUS=0
BEGIN
	SET @cantScomp=0
	SET @semn=0
	SET @trecut=0
--	PRINT 'TEST DACA AJUNGE2'

	DECLARE lapte_faptic_gestiuni CURSOR STATIC FOR 
	SELECT p.gestiune, MAX(g.tip_gestiune) AS tip_gestiune, MAX(p.cod_intrare) AS cod_intrare,
		SUM(p.cantitate) AS cantitate, MAX(grasime) as grasime
	FROM pozdoc p
		INNER JOIN intrariLapte l ON p.subunitate=l.subunitate AND p.tip=l.tip AND p.numar=l.numar 
			AND p.data=l.data AND p.numar_pozitie=l.numar_pozitie
		INNER JOIN gestiuni g ON g.subunitate= p.subunitate and g.cod_gestiune= p.gestiune
	WHERE p.subunitate=@sub AND p.tip IN ('AI', 'RM') AND p.data=@data and p.comanda= @com
		and l.tura=@tura AND p.cod=@cod and l.Compartiment= @comp
		and p.gestiune<>''
	GROUP BY p.gestiune
	ORDER BY p.gestiune

	DECLARE @gest char(9), @tipgest char(1), @cantFgest float(8), @codIntrGest char(13), @grasGest float(8)
	DECLARE @cantSgest float(8)

	OPEN lapte_faptic_gestiuni

	FETCH NEXT FROM lapte_faptic_gestiuni
	INTO @gest, @tipgest, @codIntrGest, @cantFgest, @grasGest

	WHILE @@FETCH_STATUS=0
	BEGIN

		DECLARE @nrpozcreata int
		SET @nrpozcreata=0

		/*IF NOT EXISTS (select 1 from recodif 
					where Tip='STOC' and Alfa1=@tipgest and Alfa2=@gest and Alfa3=@cod and Alfa4=@codIntrGest
						and Alfa5='' and Alfa6='' and Alfa7='' and Alfa8='' and Alfa9='' and Alfa10='')
			INSERT recodif
			(Tip,Alfa1,Alfa2,Alfa3,Alfa4,Alfa5,Alfa6,Alfa7,Alfa8,Alfa9,Alfa10)
			select 'STOC', @tipgest, @gest, @cod, @codIntrGest, '', '', '', '', '', ''

		DELETE proprietati
		FROM proprietati pr 
			INNER JOIN recodif r ON r.tip= pr.tip and ltrim(rtrim(convert(char(20),r.identificator)))=pr.cod
		WHERE r.tip='STOC' and r.Alfa1=@tipgest and r.Alfa2=@gest and r.Alfa3=@cod and r.Alfa4=@codIntrGest 
			and Alfa5='' and Alfa6='' and Alfa7='' and Alfa8='' and Alfa9='' and Alfa10=''
		
		INSERT proprietati
		(Tip, Cod, Cod_proprietate, Valoare, Valoare_tupla)
		select pr.Tip, 
			(SELECT RTrim(LTrim(convert(char(20), r1.identificator))) from recodif r1
			where r1.tip='STOC' and r1.Alfa1=@tipgest and r1.Alfa2=@gest and r1.Alfa3=@cod and r1.Alfa4=@codIntrGest 
				and Alfa5='' and Alfa6='' and Alfa7='' and Alfa8='' and Alfa9='' and Alfa10=''),
			pr.Cod_proprietate, pr.Valoare, pr.Valoare_tupla
		FROM proprietati pr 
			INNER JOIN recodif r ON r.tip= pr.tip and ltrim(rtrim(convert(char(20),r.identificator)))=pr.cod					
		WHERE r.tip='STOC' and r.Alfa1=@tipgest and r.Alfa2=@gest and r.Alfa3=@cod and r.Alfa4=@codIntrGest 
			and Alfa5='' and Alfa6='' and Alfa7='' and Alfa8='' and Alfa9='' and Alfa10=''
		*/
		
		PRINT 'TEST DACA AJUNGE3: '+RTRIM(@gest)+' '+RTRIM(@tipgest)+' '+RTRIM(@cod)+' '+RTRIM(@codINtrGest)+' G%'+RTRIM(CONVERT(CHAR,@grasGest))

		DECLARE lapte_scriptic CURSOR FOR 
			SELECT p.cod_intrare, p.cantitate, p.pret_de_stoc, p.tip, p.numar, p.numar_pozitie, l.aviz, p.loc_de_munca, p.cod
			FROM pozdoc p
				INNER JOIN intrariLapte l ON p.subunitate=l.subunitate AND p.tip=l.tip AND p.numar=l.numar 
					AND p.data=l.data AND p.numar_pozitie=l.numar_pozitie
				--LEFT JOIN recodif r ON r.identificator=l.identificator
			WHERE p.subunitate=@sub AND p.tip IN ('AI', 'RM') AND p.data=@data and p.comanda= @com
				and l.tura=@tura AND RTRIM(p.cod)+'.'=@cod and l.Compartiment=@comp 
				and p.gestiune=@gest
			ORDER BY p.tip, p.numar, p.cod_intrare, p.numar_pozitie
		FOR UPDATE
			
		DECLARE @codIntrS char(13), @cantS float(8), @pretS float(8), @tipdocS char(2), @nrdocS char(8), @nrpozS int, 
			@avizExpS char(10), @lmS char(10), @ident int, @codS char(20)

		OPEN lapte_scriptic

		FETCH NEXT FROM lapte_scriptic 
		INTO @codIntrS, @cantS, @pretS, @tipdocS, @nrdocS, @nrpozS, @avizExpS, @lmS, @codS

		WHILE @@FETCH_STATUS=0
		BEGIN
			
			SET @cantSgest= 0 
			SET @nrpozcreata=0	
			SET @semn=0		
			PRINT CASE WHEN @codIntrS IS NULL THEN 'NULL' ELSE 'NIC' END

			PRINT 'TEST DACA AJUNGE4: '+RTRIM(@codS)+' '+RTRIM(@codIntrS)+' '+RTRIM(@cantS)+' '+RTRIM(@pretS)

			IF NOT EXISTS (select 1 from recodif 
					where Tip='STOC' and Alfa1=@tipgest and Alfa2=@gest and Alfa3=@codS and Alfa4=@codIntrS
						and Alfa5='' and Alfa6='' and Alfa7='' and Alfa8='' and Alfa9='' and Alfa10='')
				
				INSERT recodif
				(Tip,Alfa1,Alfa2,Alfa3,Alfa4,Alfa5,Alfa6,Alfa7,Alfa8,Alfa9,Alfa10)
				select 'STOC', @tipgest, @gest, @codS, @codIntrS, '', '', '', '', '', ''

			DELETE proprietati
			FROM proprietati pr 
				INNER JOIN recodif r ON r.tip= pr.tip and ltrim(rtrim(convert(char(20),r.identificator)))=pr.cod
			WHERE r.tip='STOC' and r.Alfa1=@tipgest and r.Alfa2=@gest and r.Alfa3=@codS and r.Alfa4=@codIntrS 
				and Alfa5='' and Alfa6='' and Alfa7='' and Alfa8='' and Alfa9='' and Alfa10=''
			
			INSERT proprietati
			(Tip, Cod, Cod_proprietate, Valoare, Valoare_tupla)
			select 'STOC', 
				(SELECT RTrim(LTrim(convert(char(20), r1.identificator))) from recodif r1
				where r1.tip='STOC' and r1.Alfa1=@tipgest and r1.Alfa2=@gest and r1.Alfa3=@codS and r1.Alfa4=@codIntrS 
					and Alfa5='' and Alfa6='' and Alfa7='' and Alfa8='' and Alfa9='' and Alfa10=''),
				'G', CONVERT(CHAR(20), @grasGest) , ''

	---1		
			FETCH NEXT FROM lapte_scriptic 
			INTO @codIntrS, @cantS, @pretS, @tipdocS, @nrdocS, @nrpozS, @avizExpS, @lmS, @codS
			
			

		END--WHILE 1 lapte_scriptic 

		CLOSE lapte_scriptic
		DEALLOCATE lapte_scriptic
		
		FETCH NEXT FROM lapte_faptic_gestiuni
		INTO @gest, @tipgest, @codIntrGest, @cantFgest, @grasGest

	END--WHILE lapte_faptic_gestiuni	

	CLOSE lapte_faptic_gestiuni
	DEALLOCATE lapte_faptic_gestiuni
		
	FETCH NEXT FROM lapte_faptic_compartimente
	INTO @cod, @comp, @cantFcomp

END--WHILE lapte_faptic_compartimente

CLOSE lapte_faptic_compartimente
DEALLOCATE lapte_faptic_compartimente