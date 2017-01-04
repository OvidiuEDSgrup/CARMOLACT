
create procedure wOPSitComandaCarduriTicheteExcel_p @sesiune VARCHAR(50), @parXML XML
AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
set nocount on
begin try
	declare @utilizator varchar(100), @data datetime, @datajos datetime, @datasus datetime, @mesaj varchar(250)
	
	exec wIaUtilizator @sesiune=@sesiune, @utilizator = @utilizator output

	set @data = @parXML.value('(/*/@data)[1]', 'datetime')

	select @datajos = dbo.BOM(@data), @datasus = dbo.EOM(@data)

	select convert(char(10),@datajos,101) as datajos, convert(char(10),@datasus,101) as datasus, 
		'sitComandaCarduriTicheteExcel' as procedura, 
		'Comanda_carduri_tichete_'+dbo.fDenumireLuna(@dataSus)+'_'+convert(char(4),year(@datasus))+'.xlsx' as numefisier 
	for xml raw
end try

begin catch
	set @mesaj = ERROR_MESSAGE() + ' (wOPSitComandaCarduriTicheteExcel_p)'
	select 1 as inchideFereastra for xml raw,root('Mesaje')
	RAISERROR (@mesaj, 11, 1)
end catch
