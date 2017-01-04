--***
create procedure [dbo].[wOPCalcCost] @sesiune varchar(50), @parXML xml 
as 

declare @data datetime,@dataj datetime,@datas datetime 
set @data=ISNULL(@parXML.value('(/parametri/@data)[1]', 'datetime'), '')

set @dataj=dbo.BOM(@data)
set @datas=dbo.EOM(@data)

begin try
    exec calcCost @dataj,@datas
    declare @totalinc float,@totalrep float
    
    select @totalinc=SUM(CANTITATE*VALOARE) from COSTTMP where LM_SUP='' and COMANDA_SUP='' and ART_SUP in ('P','R','S','A','N')
	and COMANDA_SUP not in (select comanda from comenzi where Tip_comanda='D')
	
	select @totalrep=SUM(cantitate*valoare) from COSTTMP where PARCURS=1


    if exists(select * from COSTTMP where PARCURS=0)
		select 'Exista bucle de cheltuieli in repartizarea costurilor' as textMesaj for xml raw, root('Mesaje')
	else if Abs(@totalinc-@totalrep)>1
		select 'Cheltuielile incarcate nu sunt egale cu cheltuielile repartizate' as textMesaj for xml raw, root('Mesaje')
	else    
		select 'Calcul efectuat cu succes' as textMesaj for xml raw, root('Mesaje')
end try 
begin catch 
	declare @eroare varchar(200) 
	set @eroare=ERROR_MESSAGE()
	raiserror(@eroare, 16, 1) 
end catch
