
Create procedure wStergPozOrdineDePlataExtras @sesiune varchar(50)=null, @parXML xml
/**
	Procedura de stergere a operatiunilor preluate de pe transferuri bancare in format mt940
*/
as
declare @eroare varchar(2000)	
select @eroare=''
begin try
	if object_id('tempdb..#pozop_desters') is not null drop table #pozop_desters
	
	declare @iDoc int
	EXEC sp_xml_preparedocument @iDoc OUTPUT, @parXML

	select isnull(idPozOPtop,idPozOPdetalii) idpozop
		into #pozop_desters
		from OPENXML(@iDoc, '/*/*/*')
		WITH
		(
			idPozOPtop int './@idPozOP'
			,idPozOPdetalii int '../@idPozOP'
		)
	exec sp_xml_removedocument @iDoc

	if (select count(1) from #pozop_desters)=0
		raiserror('Nu a fost identificata nici o pozitie de sters! Nu s-a sters nimic!',16,1)
	
	delete p from pozordinedeplata p inner join #pozop_desters s on p.idpozop=s.idpozop
	exec wIaPozOrdineDePlataExtras @sesiune=@sesiune, @parxml=@parxml
end try

begin catch
	set @eroare=ERROR_MESSAGE() + char(10)+' (' + OBJECT_NAME(@@PROCID) + ')'
end catch

if object_id('tempdb..#pozop_desters') is not null drop table #pozop_desters
if len(@eroare)>0 raiserror(@eroare,16,1)
