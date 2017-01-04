Create procedure pCitireCifAnaf @dataRap datetime=null, @limita int=0 
as
declare @pTXT varchar(max), @raspuns varchar(max), @nrSplit int, @iSplit int, @poz int, @mesaj varchar(1000), @intMAX varchar(10)

begin try
	if not exists (select 1 from #informTVA) 
		return
	set @intMAX='2147483647'
	set @dataRap=isnull(@dataRap,getdate())
	set @limita=isnull(nullif(@limita,0),500)
	if OBJECT_ID('tempdb..#informTVA') is null 
		begin
			create table #informTVA (cui varchar(20))
			exec CreazaDiezTerti @numeTabela='#informTVA'
		end
	if OBJECT_ID('tempdb..#eroriTVA') is null 
		create table #eroriTVA (raspuns varchar(max), eroare varchar(500))
	insert into #eroriTVA (eroare)
	select 'CUI:'+rtrim(cui)
	from #informTVA 
	where REPLICATE('0',10-len(rtrim(ltrim(cui))))+rtrim(ltrim(cui))>@intMAX

	select @nrSplit=round(count(*)/@limita,0)+1 from #informTVA -- impartim tabela in maxim @limita inregistrari
	if exists (select 1 from #eroriTVA) 
		set @iSplit=@nrSplit+1
	else
		set @iSplit=1
	while @iSplit<=@nrSplit 
		begin
			set @pTXT=''
			select @pTXT=@pTXT+'{"cui":"'+rtrim(cui)+'", "data":"'+convert(varchar(10),isnull(data_raportare,@dataRap),120)+'"},' 
			from 
				(select (ROW_NUMBER() over (order by cui)) rownr, cui, data_raportare from #informTVA) x
			where rownr between @limita*(@iSplit-1)+1 and @limita*@iSplit
			
			if rtrim(@pTXT)!='' 
				set @pTXT='['+left(@pTXT,len(@pTXT)-1)+']'
			else
				set @pTXT='[{"cui":"1", "data":"'+convert(varchar(10),@dataRap,120)+'"}]'
			exec httpXMLSOAPRequest
					  @URI= 'https://webservicesp.anaf.ro:/PlatitorTvaRest/api/v1/ws/tva',
					  @method= 'POST',
					  @requestBody= @pTXT,
					  @contentType='application/json',
					  @SoapAction='',
					  @UserName='', 
					  @Password='',
					  @responsetext=@raspuns output

			if OBJECT_ID('fn_RemoveAccent') is not null and len(@raspuns)<=4000 
				set @raspuns=dbo.fn_RemoveAccent(@raspuns)

			IF OBJECT_ID('tempdb.dbo.#json') is not null drop table #json
			if object_id('tempdb..#pivot') is not null drop table #pivot
			if charindex('Eroare=',@raspuns)=0 -- nu este eroare
				begin
					select * INTO #json from dbo.parseJSON (convert(xml, @raspuns).value('/result[1]','varchar(max)'))
					
					select parent_id, adresa, cui, data, denumire, tva, data_sfarsit, data_anul_imp, mesaj
					into #pivot
					from 
					(select parent_id, name, StringValue from #json) data
					pivot 
					(max(StringValue) for name in (adresa, cui, data, denumire, tva, data_sfarsit, data_anul_imp, mesaj)) pvt

					update  itva 
						set data_ora=getdate(),
							tip='ANAF', 
							data_raportare=isnull(data_raportare,dbo.EOM(p.data)),
							is_tva=(case when p.tva='true' then 1 else 0 end), 
							adresa=p.adresa, 
							valid=(case when p.mesaj in ('cui negasit') then 0 else 1 end),
							denumire=left(p.denumire,250)
					from #informTVA itva
						inner join #pivot p on ltrim(rtrim(p.cui))=ltrim(rtrim(itva.cui)) and (itva.data_raportare is null or itva.data_raportare=p.data)
				end
			else
				begin
					set @raspuns=replace(@raspuns,'&lt;','<')
					set @raspuns=replace(@raspuns,'&gt;','>')
					set @raspuns=replace(@raspuns,'"','"')
					set @raspuns=replace(@raspuns,'&amp;','&')
					set @raspuns=replace(@raspuns,'&#xA;',char(10))
					set @raspuns=replace(@raspuns,'&#xD;',char(13))
					set @raspuns=replace(@raspuns,'&#39;','''')
					set @raspuns=replace(@raspuns,'&#40;','(')
					set @raspuns=replace(@raspuns,'&#41;',')')
					set @poz=charindex('Can',@raspuns,charindex('<div id="code">',@raspuns,1))
					insert into #eroriTVA (eroare,raspuns)
					select substring(@raspuns, @poz, charindex(':',@raspuns,@poz)-@poz), @raspuns
				end
			set @iSplit=@iSplit+1
		end
		-- aici vom face tratarea erorilor ca sa fie in clar
		update #eroriTVA
				set eroare='CUI:'+substring(eroare, charindex('''', eroare),len(eroare))
		where charindex('can not construct instance of int from string value',lower(eroare))!=0 and charindex('''', eroare)!=0
		
		set @mesaj=''
		
		select distinct @mesaj=@mesaj+replace(eroare, 'CUI:','')+','
		from #eroriTVA 
		where charindex('CUI:',eroare)!=0
		
		if len(@mesaj)!=0
			set @mesaj='Aveti coduri fiscale eronate: '+left(@mesaj, len(@mesaj)-1)+ '! Verificati codurile fiscale!'
		else
			if exists (select 1 from #eroriTVA)
				set @mesaj='Eroare la citirea datelor prin serviciul web ANAF! Probabil sunt coduri fiscale eronate care s-au trimis spre verificare la serviciul web ANAF! Luati legatura cu furnizorul aplicatiei!'
		if len(@mesaj)!=0
			raiserror(@mesaj,11,1)

end try 

begin catch
	declare @eroare varchar(2000)
	set @eroare='Procedura pCitireCifAnaf (linia '+convert(varchar(20),ERROR_LINE())+') :'+char(10)+rtrim(error_message())
	raiserror(@eroare,16,1)
end catch
