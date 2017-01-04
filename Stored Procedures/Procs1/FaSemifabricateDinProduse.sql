create procedure [dbo].[FaSemifabricateDinProduse]  @sesiune varchar(50), @parXML XML OUTPUT
AS

	DECLARE @utilizator VARCHAR(100)
	EXEC wIaUtilizator @sesiune=@sesiune, @utilizator=@utilizator OUTPUT

	DECLARE @nivel INT,@nranduri INT,@nMax int
	SELECT @nRanduri=COUNT(*) FROM tmpprodsisemif WHERE utilizator=@utilizator

	SET @nivel=0
	SET @nMax=35

	WHILE @nRanduri>0 AND @nivel<@nMax--bucla pentru Produse si Semifabricate
	BEGIN
		
		INSERT INTO tmpprodsisemif(id,utilizator,tip,codNomencl,idp,codp,nivel,cantitate)
			SELECT 
			(CASE WHEN tPoateESemif.codNomencl IS NOT NULL THEN ptTehn.id ELSE pt.id END),@utilizator,pt.tip,pt.cod,
			(CASE WHEN tPoateESemif.codNomencl IS NOT NULL THEN null ELSE pt.id END),
			(CASE WHEN tESemifParinte.codNomencl IS NOT null THEN parinti.codNomencl ELSE parinti.codp END),
			(CASE WHEN tESemifParinte.codNomencl IS NOT null THEN parinti.nivel+1 ELSE parinti.nivel END),
			pt.cantitate*parinti.cantitate
			FROM dbo.pozTehnologii pt
			INNER JOIN tmpprodsisemif parinti ON parinti.utilizator=@utilizator AND pt.idp=parinti.id
			LEFT OUTER JOIN dbo.tehnologii tESemifParinte ON tESemifParinte.codNomencl=parinti.codNomencl 
			LEFT OUTER JOIN dbo.tehnologii tPoateESemif ON tPoateESemif.codNomencl=pt.cod
			LEFT OUTER JOIN dbo.pozTehnologii ptTehn ON ptTehn.idp IS null and ptTehn.tip='T' AND ptTehn.cod=tPoateESemif.cod 
			LEFT OUTER JOIN tmpprodsisemif faraduplicate ON faraduplicate.utilizator=@utilizator 
				AND faraduplicate.id=(CASE WHEN tPoateESemif.codNomencl IS NOT NULL THEN ptTehn.id ELSE pt.id END)
			WHERE pt.tip NOT IN ('A','L') AND faraduplicate.id IS NULL
				
		SET @nRanduri=@@ROWCOUNT
		SET @nivel=@nivel+1
	END
	set @parXML.modify ('insert attribute nivel{sql:variable("@nivel")} into (/row)[1]')
	
	IF @nivel=@nMax
	begin
		RAISERROR('(FaSemifabricateDinProduse)Exista bucle in definirea tehnologiilor!',11,1)
		return
	end
	--Stergem cele care nu au tehnologie indiferent ce coduri sunt

	DELETE ps
	FROM tmpprodsisemif ps
	LEFT OUTER JOIN dbo.tehnologii t ON ps.codNomencl=t.codNomencl
	WHERE t.codNomencl IS NULL 

