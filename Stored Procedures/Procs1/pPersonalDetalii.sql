--***
/**	procedura pentru citire date din personal.detalii. */
Create procedure pPersonalDetalii @sesiune varchar(50)=null, @parXML xml=null
As
/*
	if object_id('tempdb..#personalDetalii') is not null 
		drop table #personalDetalii
	exec pPersonalDetalii 
*/
Begin try

	declare @tabela int
	set @tabela=1
	if object_id('tempdb..#personalDetalii') is null
	begin
		Create table #personalDetalii (marca varchar(6) not null)
		exec CreeazaDiezPersonal @numeTabela='#personalDetalii'
		set @tabela=0
	end

	insert into #personalDetalii (marca, rtipactident, rcetatenie, rnationalitate, mentiuni, localitate, tipcontract, datainchcntr, temeiincet, texttemei, 
		detaliicntr, excepdatasf, reptimpmunca, intervalreptm , oreintervalreptm, pasaport, contractvechi, datacntrvechi)
	select marca, detalii.value('(/row/@rtipactident)[1]','varchar(100)'), detalii.value('(/row/@rcetatenie)[1]','varchar(100)'), detalii.value('(/row/@rnationalitate)[1]','varchar(100)'), 
		detalii.value('(/row/@mentiuni)[1]','varchar(100)'), detalii.value('(/row/@localitate)[1]','varchar(100)'), detalii.value('(/row/@tipcontract)[1]','varchar(100)'), 
		detalii.value('(/row/@datainchcntr)[1]','varchar(100)'), detalii.value('(/row/@temeiincet)[1]','varchar(100)'), detalii.value('(/row/@texttemei)[1]','varchar(100)'), 
		detalii.value('(/row/@detaliicntr)[1]','varchar(100)'), detalii.value('(/row/@excepdatasf)[1]','varchar(100)'), detalii.value('(/row/@reptimpmunca)[1]','varchar(100)'), 
		detalii.value('(/row/@intervalreptm)[1]','varchar(100)'), detalii.value('(/row/@oreintervalreptm)[1]','int'), 
		detalii.value('(/row/@pasaport)[1]','varchar(100)'), detalii.value('(/row/@contractvechi)[1]','varchar(100)'), detalii.value('(/row/@datacntrvechi)[1]','varchar(100)')
	from personal

	if @tabela=0
		select * from #personalDetalii

End try

begin catch
	declare @eroare varchar(2000)
	set @eroare='Procedura pPersonalDetalii (linia '+convert(varchar(20),ERROR_LINE())+') :'+char(10)+rtrim(error_message())
	raiserror(@eroare,16,1)
end catch
