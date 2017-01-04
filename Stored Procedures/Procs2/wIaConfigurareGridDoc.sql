﻿--***
Create procedure wIaConfigurareGridDoc @sesiune varchar(30), @parXML xml
as
  
--Declare @sesiune varchar(30), @parXML xml
--Set @sesiune = ''
--Set @parXML = '<row tipMacheta="C" codMeniu="N" Tip="N" />'

Declare @parTipMacheta varchar(2), @parCodMeniu varchar(20)
  
Set @parTipMacheta = @parXML.value('(/row/@tipMacheta)[1]','varchar(2)')
Set @parCodMeniu = @parXML.value('(/row/@codMeniu)[1]','varchar(20)')

declare @utilizator varchar(255),@limba varchar(50)
exec wIaUtilizator @sesiune=@sesiune, @utilizator=@utilizator output
set @limba= dbo.wfProprietateUtilizator('LIMBA',@utilizator)

select tip, dbo.wfTradu(@limba,numecol) as numecol, datafield, TipObiect, latime
from webConfigGrid 
where --tipMacheta = @parTipMacheta and 
	Meniu = @parCodMeniu and InPozitii = 0 and Vizibil = 1
order by Ordine
for xml raw

--Testare 
--exec wIaConfigurareGridDoc '','<row tipMacheta="C" codMeniu="N"/>'
  
  
  
