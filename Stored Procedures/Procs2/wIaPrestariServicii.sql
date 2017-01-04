--***
create procedure wIaPrestariServicii @sesiune varchar(20) , @parXML xml
as
declare @numar varchar(20),@data datetime,@subunitate char(9),@utilizator varchar(20),@lista_lm int, @tip_doc varchar(2),
	@tert varchar(13), @tip varchar(2),@valtotal float, @valPrest float, @valPrestTva float, @tcantitate float
        
select         
	@numar=@parXML.value('(/row/@numar)[1]','varchar(20)'),
	@data=@parXML.value('(/row/@data)[1]','datetime'),
	@tert=@parXML.value('(/row/@tert)[1]','varchar(13)'),
	@valtotal=@parXML.value('(/row/@valtotala)[1]','float'),
	@tip=@parXML.value('(/row/@tip)[1]','varchar(2)'),
	@tcantitate = @parXML.value('(/row/@tcantitate)[1]', 'float')

IF @tip IN ('RC', 'RA', 'RF')
	SET @tip_doc = 'RM'

select @valPrest=convert(decimal(17,2),sum(isnull(Cantitate*Pret_valuta,0))),
	@valPrestTva=convert(decimal(17,2),sum(isnull(Tva_deductibil,0)))
from pozdoc 
where subunitate='1'
	and numar=@numar
	and data=@data
	and tip in('RP','RZ')

select @tcantitate = convert(decimal(17,2), sum(isnull(p.Cantitate, 0)))
from pozdoc p
where p.subunitate = '1' and p.Tip = @tip_doc and p.Numar = @numar and p.Data = @data

select @numar as numar, convert(char(10),@data,101) as data, RTRIM(@tert) as tert, @tip as tip, convert(decimal(17,2), @valtotal) valtotala,
	convert(decimal(17,2),isnull(@valPrest,0)) as valPrest, convert(decimal(17,2),isnull(@valPrestTva,0)) as valPrestTva,
	convert(decimal(17,2),isnull(@valPrest,0)+isnull(@valPrestTva,0)) as valTotalPrest, convert(decimal(17,2), @tcantitate) as tcantitate
for xml raw

/*
select * from  pozdoc where tip='RP'
*/
