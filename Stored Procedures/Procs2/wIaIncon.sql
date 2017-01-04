--***
create procedure [dbo].[wIaIncon] @sesiune varchar(20) , @parXML xml
as
declare @Sub char(9), @f_nrdocument varchar(40), @f_tipdocument varchar(20), @tipdocument varchar(2), @nrdocument char(40), @data datetime,
	@pozitii int,@datajos datetime,@datasus datetime,@lista_lm int,@utilizator varchar(20),@tert varchar(13),@efect varchar(20),
    @tip varchar(2),@numar varchar(20),@marca varchar(6), @decont varchar(40),@tipefect varchar(1)
        
exec luare_date_par 'GE', 'SUBPRO', 0, 0, @Sub output
select         
	@f_nrdocument=isnull(@parXML.value('(/row/@f_nrdocument)[1]','varchar(40)'),''),
	@f_tipdocument=isnull(@parXML.value('(/row/@f_tipdocument)[1]','varchar(20)'),''),
	@datajos=isnull(@parXML.value('(/row/@datajos)[1]','datetime'),'1901-01-01'),
	@datasus=isnull(@parXML.value('(/row/@datasus)[1]','datetime'),'2901-01-01'),
	@tipdocument=@parXML.value('(/row/@tipdocument)[1]','char(2)'),
	@nrdocument=@parXML.value('(/row/@nrdocument)[1]','varchar(40)'),
	@data=@parXML.value('(/row/@data)[1]','datetime'),
	@tert=@parXML.value('(/row/@tert)[1]','varchar(13)'),
	@tipefect = ISNULL(@parXML.value('(/row/@tipefect)[1]','varchar(1)'), ''), 
	@efect=@parXML.value('(/row/@efect)[1]','varchar(20)'),
	@marca=@parXML.value('(/row/@marca)[1]','varchar(6)'),
	@decont=@parXML.value('(/row/@decont)[1]','varchar(40)'),
	@tip=@parXML.value('(/row/@tip)[1]','varchar(2)'), 
	@numar=@parXML.value('(/row/@numar)[1]','varchar(20)')
	
if @tipdocument is null and @nrdocument is null and @numar is not null
begin 
	set @tipdocument=@tip
	set @nrdocument=@numar
end

if object_id('tempdb..#incon') is not null drop table #incon
select top 100 ic.tip_document as tipdocument, ic.Numar_document as nrdocument,
	ic.data, ic.Numar_pozitie as nrpozitii,
	@tert as tert, @efect as efect, @marca as marca, @decont as decont,
	@tip as tip, @tipefect as tipefect 
into #incon
from incon  ic
where isnull(ic.tip_document,'') like @f_tipdocument+'%'
	and isnull(ic.Numar_document,'') like @f_nrdocument+'%'
	and ic.Data between @datajos and @datasus
	and (@tipdocument is null or ic.Tip_document=@tipdocument)
	and (@nrdocument is null or ic.Numar_document=@nrdocument)
	and (@data is null or ic.Data=@data)

select rtrim(ic.tipdocument) as tipdocument ,rtrim(ic.nrdocument)as nrdocument,
	convert(varchar(10),ic.data,101) as data,rtrim(poz.nr) as nrpozitii,
	RTRIM(tert) as tert, RTRIM(efect) as efect, RTRIM(marca) as marca, RTRIM(decont) as decont,
	tip, tipefect--, convert(decimal(15,2), total.suma) total -- nu se poate folosi in tab la generare inreg.
from #incon ic
OUTER APPLY
(	
	select 
		count(1) nr
	from pozincon where subunitate=@Sub and tip_document=ic.tipdocument and numar_document=ic.nrdocument and data=ic.data
) poz
order by ic.tipdocument
for xml raw

/*
select * from  incon
*/
