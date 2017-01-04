Create procedure pCitireTertiTLIClient @datasus datetime, @limita int=0
as
	declare @nrSplit int, @iSplit int,
	@pXMLSend xml, @raspuns varchar(max), @pXMLRec xml, @iDoc int, @pTXT varchar(max)
begin try
	set @limita=isnull(nullif(@limita,0),500)
	select @nrSplit=round(count(*)/@limita,0)+1 from #informTVA -- impartim tabela in maxim @limita inregistrari
	set @iSplit=1
	while @iSplit<=@nrSplit
		begin
			set @pXMLSend=(
			select convert(varchar(10),@datasus,101) as data, 
			(
			select cui as codfiscal 
				from 
					(select (ROW_NUMBER() over (order by cui)) rownr, cui from #informTVA) x
				where rownr between @limita*(@iSplit-1)+1 and @limita*@iSplit
				for xml raw, type)
			for xml raw, type)
			set @pTXT=convert(varchar(max),@pXMLSend)
			exec httpXMLSOAPRequest
				'http://mfinante.asis.ro/handlere/CitireTertiTLI.ashx',
				'POST',	
				@pTXT,
				'',
				'',
				'',	
				'',
				@raspuns OUTPUT

				set @pXMLRec=convert(xml, @raspuns)
				EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXMLRec
				if object_id('tempdb..#corectari') is not null drop table #corectari
				select codfiscal, dela, panala, tip
				into #corectari
				from openxml(@iDoc, 'result/message/row')
				with
				(
					 codfiscal varchar(20) '@codfiscal'
					,dela datetime '@dela'
					,panala varchar(20) '@panala'
					,tip varchar(1) '@tip' 
				)
				EXEC sp_xml_removedocument @iDoc

				update i
					set is_tli=(case when c.tip='D' then 0 when c.tip='I' then 1 end),
						i.dela=(case when c.tip='D' then c.panala else c.dela end)
				from #informTVA i
					inner join #corectari c on c.codfiscal=i.cui and i.data_raportare=@datasus
			set @iSplit=@iSplit+1
		end
end try 

begin catch
	declare @eroare varchar(2000)
	set @eroare='Procedura pCitireTertiTLIClient (linia '+convert(varchar(20),ERROR_LINE())+') :'+char(10)+rtrim(error_message())
	raiserror(@eroare,16,1)
end catch
