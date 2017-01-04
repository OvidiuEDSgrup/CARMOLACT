--***
CREATE procedure wIaFormularePv @sesiune varchar(40), @parXML xml
as
declare @returnValue int, @msgEroare varchar(500)
if exists(select * from sysobjects where name='wIaFormularePvSP1' and type='P')      
begin
	exec @returnValue = wIaFormularePvSP1 @sesiune=@sesiune,@parXML=@parXML output
	if @parXML is null
		return @returnValue 
end

begin try
	exec wIaFormulare @sesiune=@sesiune, @parXML=@parXML
end try
begin catch
set @msgEroare=ERROR_MESSAGE()+'(wIaFormularePv)'
raiserror(@msgEroare,11,1)
end catch	
