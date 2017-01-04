--***
CREATE procedure wStergPozadoc @sesiune varchar(50), @parXML xml
as
declare @subunitate char(9), @tip varchar(2), @numar varchar(8), @data datetime, @numar_pozitie int, @eroare xml,  @iDoc int, @multiselect int, @root varchar(500)  

begin try
	set @multiselect=0
	if isnull(@parXML.value('count(/row/@idpozadoc)','int'),0)=0
	begin
		set @root = '/row/row'
		set @multiselect=1 -- anumite actiuni nu se vor face daca sunt selectate mai multe pentru stergere
	end
	else
		set @root = '/row'

select @subunitate=ISNULL(@parXML.value('(/row/@subunitate)[1]', 'varchar(9)'), ''),
	@tip=ISNULL(@parXML.value('(/row/@tip)[1]', 'varchar(2)'), ''),
	@numar=ISNULL(@parXML.value('(/row/@numar)[1]', 'varchar(8)'), ''),
	@data=ISNULL(@parXML.value('(/row/@data)[1]', 'datetime'), '01/01/1901'),
	@numar_pozitie=ISNULL(@parXML.value('(/row/@numarpozitie)[1]', 'int'), '')

--delete pozadoc
--where subunitate = @subunitate and tip = @tip and Numar_document = @numar and data = @data 
--and (@numar_pozitie is null or numar_pozitie = @numar_pozitie)

	exec sp_xml_preparedocument @iDoc output, @parXML

	delete pozadoc
		from pozadoc p, 
		OPENXML (@iDoc, @root)
			WITH
			(idpozadoc int '@idpozadoc') as dx
		where p.idpozadoc = dx.idpozadoc

	exec sp_xml_removedocument @iDoc 

exec wIaPozadoc @sesiune=@sesiune, @parXML=@parXML

end try
begin catch
	--ROLLBACK TRAN
	declare @mesaj varchar(255)
	if isnull(@eroare.value('(/error/@coderoare)[1]', 'int'), 0) = 0
		set @mesaj=ERROR_MESSAGE()
	raiserror(@mesaj, 11, 1)
end catch
