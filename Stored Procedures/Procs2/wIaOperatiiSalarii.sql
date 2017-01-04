
create procedure wIaOperatiiSalarii @sesiune varchar(50), @parXML XML
as
begin
	declare 
		@tip varchar(10), @datajos datetime, @datasus datetime

	select 
		@tip = @parXML.value('(/*/@tip)[1]','varchar(10)'),
		@datajos = @parXML.value('(/*/@datajos)[1]','varchar(10)'),
		@datasus = @parXML.value('(/*/@datasus)[1]','varchar(10)')

	select	
		convert(varchar(20),wj.data,101) data, convert(varchar(10),wj.data,108) ora, wj.utilizator utilizator, id, parametruXML, 
		convert(char(2),wj.parametruXML.value('(/row/@luna)[1]','int'),101) as luna, 
		convert(char(4),wj.parametruXML.value('(/row/@an)[1]','int')) as an,
		wj.parametruXML.value('(/row/@subtip)[1]','varchar(10)') as subtip
	into #opsal
	from webjurnaloperatii wj 
	where wj.tip=@tip and convert(datetime,wj.data) between @datajos and @datasus

	select	data, ora, utilizator, id, 
			convert(varchar(10),dbo.EOM(an+'-'+luna+'-01'),101) as datalunii, 
			dbo.fDenumireLuna(dbo.EOM(an+'-'+luna+'-01'))+' '+an as numeluna
	from #opsal
	where subtip=@tip
	order by data desc, ora desc
	for xml raw,root('Date')
end