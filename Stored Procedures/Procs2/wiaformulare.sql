--***
CREATE PROCEDURE wiaformulare @sesiune VARCHAR(40), @parXML XML, @raspunsXml xml = null output
AS
DECLARE @utilizator VARCHAR(255), @formimplicit VARCHAR(255), @tip VARCHAR(10), @meniu varchar(20), @faraMesaje int

EXEC wIaUtilizator @sesiune = @sesiune, @utilizator = @utilizator OUTPUT

set @tip = ISNULL(@parXML.value('(/row/@tip)[1]', 'varchar(2)'), '')
set @meniu = ISNULL(@parXML.value('(/row/@codmeniu)[1]', 'varchar(20)'), '')
set @faraMesaje = ISNULL(@parXML.value('(/row/@faraMesaje)[1]', 'int'), 0)

/**
	Citesc ultimul formular folosit din proprietati. Folosesc tip ='PROPUTILIZ', nu 'UTILIZATOR' pt. ca 
	vreau sa nu se vada in ED la proprietati pe utilizator 
**/
SELECT @formimplicit = Valoare
FROM proprietati p
WHERE p.Tip = 'PROPUTILIZ'
	AND p.Cod_proprietate = 'FORM' + @tip
	AND p.cod = @utilizator

IF EXISTS (SELECT * FROM sysobjects WHERE NAME = 'wIaFormulareSP' AND type = 'P')
begin
	EXEC wIaFormulareSP @sesiune, @parXML
	return
end

set @raspunsXML=(
SELECT rtrim(wcf.cod_formular) AS formular, RTRIM(af.Denumire_formular) AS denumire, rtrim(wcf.loc_munca) AS lm,
	(CASE WHEN @formimplicit = wcf.cod_formular THEN 0 ELSE 1 END) AS ordonare, l.*
FROM webConfigFormulare wcf
INNER JOIN antform af ON wcf.cod_formular = af.Numar_formular 
left outer join LMFiltrare l on l.utilizator=@utilizator and wcf.loc_munca=l.cod
where (@meniu='' or wcf.meniu = @meniu)
	and (exists (select 1 from webconfigmeniu m where m.meniu=wcf.meniu and m.tipmacheta='c') or wcf.tip = @tip)
	and (wcf.loc_munca is null or l.cod is not null)
FOR XML raw, root('Date'))

if isnull(@faraMesaje,0)=0
	select @raspunsXML