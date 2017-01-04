--***
CREATE procedure wSalvareGPS @sesiune varchar(50), @parXML xml
as
if exists(select * from sysobjects where name='wSalvareGPSSP' and type='P')
begin
	declare @returnValue int
	exec @returnValue = wSalvareGPSSP @sesiune, @parXML 
	return @returnValue 
end
begin try
	set transaction isolation level READ UNCOMMITTED
	declare @user varchar(50)
	exec wIaUtilizator @sesiune=@sesiune, @utilizator=@user output
	
	-- in versiunile de mobile <= 036 se trimite fara root...
	if @parXML.exist('(/Date)')=0
		set @parXML = '<Date>' + convert(varchar(max), @parXML)+'</Date>'
	
	declare @iDoc int
	EXEC sp_xml_preparedocument @iDoc OUTPUT, @parXML
	
	insert into GpsTracking(Tip, Cod, Data, x, y, kmph, detaliiXML) 
	select 'Agent', @user, CONVERT(datetime,docXML.data,126), docXML.latitude, docXML.longitude, docXML.kph, @parXML
	from OPENXML(@iDoc, '/Date/row')
	WITH 
	(
		data varchar(50) '@data',
		latitude varchar(50) '@latitude',
		longitude varchar(50) '@longitude',
		kph varchar(50) '@kph'
	) docXML
	where not exists (select 1 from GpsTracking g where g.Tip='Agent' and g.Cod=@user and g.Data=CONVERT(datetime,docXML.data,126))

	exec sp_xml_removedocument @iDoc
	
	select CONVERT(varchar(30), max(g.Data),126) as lastSync
	from GpsTracking g where g.Tip='Agent' and g.Cod=@user
	for xml raw,Root('Mesaje')

end try
begin catch 
	declare @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT
	SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();
		
	RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState )

end catch

