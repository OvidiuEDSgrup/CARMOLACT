
CREATE PROCEDURE wIaRapProductie @sesiune VARCHAR(50), @parXML XML
AS
DECLARE		
	@fltDescriere VARCHAR(80), @datajos DATETIME, @datasus DATETIME, @idRealizare INT, @tip varchar(2),@f_numar varchar(100)


/** Va lua pozitiile cu tip "RP"-> raportare pe tehnologie **/

SET @datajos = isnull(@parXML.value('(/row/@datajos)[1]', 'datetime'),'01/01/1910')
SET @datasus = isnull(@parXML.value('(/row/@datasus)[1]', 'datetime'),'01/01/2110')
SET @idRealizare = @parXML.value('(/row/@idRealizare)[1]', 'int')
SET @tip= @parXML.value('(/row/@tip)[1]', 'varchar(2)')
SET @f_numar= '%'+isnull(@parXML.value('(/row/@f_numar)[1]', 'varchar(100)'),'')+'%'


SELECT 
	rtrim(r.nrDoc) AS numar_doc,CONVERT(VARCHAR(10), r.data, 101) AS data, 
	r.id AS idRealizare,isnull(pr.nr,0)  AS nrpoz, (CASE WHEN isnull(pr.nr,0) = 0 THEN '#FF0000' when r.detalii.value('(/*/@stare)[1]','int')=1 then'#808080' END) AS culoare,
	(CASE when isnull(r.detalii.value('(/*/@stare)[1]','int') ,0) <> 0 then 1 else 0 end ) as _nemodificabil,
	rs.id resursa, rs.descriere denresursa
FROM Realizari r
LEFT JOIN 
	(
		select idRealizare,count(*) nr
		from PozRealizari
		group by idRealizare

	)pr on pr.idRealizare=r.id
LEFT JOIN Resurse rs on rs.id=r.idResursa
WHERE
	(@idRealizare is null OR r.id=@idRealizare)
	AND r.data BETWEEN @datajos	AND @datasus
	AND r.tip=@tip
	and r.nrDoc like @f_numar
FOR XML raw, root('Date')