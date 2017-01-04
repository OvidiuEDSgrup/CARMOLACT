
Create procedure wOPIaPozOrdineDePlataExtras_mt940 @sesiune varchar(50)=null, @parXML xml
--> procedura de vizualizare a codului mt940 pentru pozitiile de extras bancar din macheta Ordine de plata
as
declare @eroare varchar(2000)

begin try
	--select @parxml.value('(row/row/@idPozOP)[1]','int')
	select 
		replace(p.detalii.value('(row/@date)[1]','varchar(max)'),'~',char(10)+'~') date
	from pozordinedeplata p where p.idpozop=@parxml.value('(row/row/@idPozOP)[1]','int')
	for xml raw--('parametri')--, root('Date')
end try

begin catch
	set @eroare=ERROR_MESSAGE() + char(10)+' (' + OBJECT_NAME(@@PROCID) + ')'
end catch
if len(@eroare)>0 raiserror(@eroare,16,1)
