
--***
CREATE PROCEDURE wJurnalizareOperatie @sesiune VARCHAR(50), @parXML XML, @obiectSql VARCHAR(100)
AS
BEGIN
	DECLARE @utilizator VARCHAR(100), @tip varchar(2), @data char(10), @ora varchar(5)
	EXEC wIaUtilizator @sesiune = @sesiune, @utilizator = @utilizator OUTPUT
	--set @data=convert(char(10),GETDATE(),101)
	--set @ora=convert(char(5),GETDATE(),108)
	--if @parXML.value('(/*/@data)[1]', 'char(10)') is not null 
	--	set @parXML.modify('replace value of (/*/@data)[1] with sql:variable("@data")') 
		
	--if @parXML.value('(/*/@ora)[1]', 'char(10)') is not null 
	--	set @parXML.modify('replace value of (/*/@ora)[1] with sql:variable("@ora")') 
		
	--if @parXML.value('(/*/@utilizator)[1]', 'char(10)') is not null 
	--	set @parXML.modify('replace value of (/*/@utilizator)[1] with sql:variable("@utilizator")') 
		

    set @parXML=convert(xml,replace(replace(convert(varchar(max),@parXML), '</parametri', '</row'), '<parametri', '<row'))

	set @tip=@parXML.value('(/*/@tip)[1]','varchar(2)')

	INSERT INTO webJurnalOperatii (sesiune, utilizator, data, tip, obiectSql, parametruXML)
	VALUES (@sesiune, @utilizator, GETDATE(), @tip, @obiectSql,@parXML)
END
