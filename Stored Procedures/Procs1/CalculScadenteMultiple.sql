--***
create procedure [dbo].[CalculScadenteMultiple] @procApelanta varchar(200)
as
	create table #fsterse(tip varchar(1),tert varchar(20),factura varchar(20),data_scadentei datetime,totalf float,achitat float,sold float)

	if @procApelanta='wIaFacturiTerti' --Datele ne vin in tabela #facturi
	begin
		delete f
		OUTPUT DELETED.tip,DELETED.tert,DELETED.numar,convert(datetime,deleted.datascadentei,101),DELETED.valoare+DELETED.tva as totalf,DELETED.achitat,0
		INTO #fsterse
			from #facturi f
			inner join ScadenteFacturi sf on f.tip=sf.tip and f.tert=sf.tert and f.numar=sf.factura
		where abs(f.sold)>0.01
	end	
	else if @procApelanta='wOPPreluareFacturiInOrdineDePlata'
	begin
		select * into #pfacturiOrig	from #pfacturi
		
		delete f
		OUTPUT (case when deleted.tip=0x54 then 'F' else 'B' end),DELETED.tert,DELETED.factura,convert(datetime,deleted.data_scadentei,101),DELETED.valoare+DELETED.tva as totalf,deleted.achitat,0
		INTO #fsterse
			from #pfacturi f
			inner join ScadenteFacturi sf on f.tip=(case when sf.Tip='F' then 0x54 else 0x46 end) and f.tert=sf.tert and f.factura=sf.factura
		where abs(f.sold)>0.01
	end
	
	--> creez structura:
	select top 0 sf.suma as running,
		sf.tip,sf.tert,sf.factura,sf.data_scadentei,sf.suma,sf.tertf,sf.facturaf,f.achitat as achitat,convert(float,0) as sold,convert(int,0) as ranc,f.totalf
	into #fdeadaugat
	from #fsterse f
	inner join ScadenteFacturi sf on f.Tip=sf.tip and f.tert=sf.tert and f.factura=sf.factura
	
	--> inserez datele; cu dinamic sa evit eroarea de compatibilitate cu sql 2008 de pe ROWS UNBOUNDED PRECEDING in momentul instalarii;
	declare @comanda_sql nvarchar(max)
	select @comanda_sql='
	insert into #fdeadaugat
	select sum(sf.suma) over (partition by sf.tert,sf.factura order by sf.data_scadentei ROWS UNBOUNDED PRECEDING) as running,
		sf.tip,sf.tert,sf.factura,sf.data_scadentei,sf.suma,sf.tertf,sf.facturaf,f.achitat as achitat,convert(float,0) as sold,convert(int,0) as ranc,f.totalf
	
	from #fsterse f
	inner join ScadenteFacturi sf on f.Tip=sf.tip and f.tert=sf.tert and f.factura=sf.factura

	insert into #fdeadaugat
	select max(f.totalf),sf.tip,sf.tert,sf.factura,max(f.data_scadentei),max(f.totalf)-max(sf.running),null,null,max(f.achitat),0.00 as sold,0 as ranc,max(f.totalf)
	from #fdeadaugat sf
	inner join #fsterse f on sf.tip=f.tip and sf.tert=f.tert and sf.factura=f.factura
	group by sf.tip,sf.tert,sf.factura
	having abs(max(f.totalf)-max(sf.running))>0.01

	
	update #fdeadaugat
	set ranc=c.ranc,
		running=c.running
	from (
		select sf.tert,sf.factura,row_number() over (partition by sf.tert,sf.factura order by sf.data_scadentei) as ranc,
			sf.data_scadentei,sum(sf.suma) over (partition by sf.tert,sf.factura order by sf.data_scadentei ROWS UNBOUNDED PRECEDING) as running,sf.suma,sf.sold
		from #fdeadaugat sf) c where #fdeadaugat.tert=c.tert and #fdeadaugat.factura=#fdeadaugat.factura and #fdeadaugat.data_scadentei=c.data_scadentei
	'
	
	exec (@comanda_sql)
	
	update #fdeadaugat
	set sold=(case 	when achitat>totalf and abs(running-totalf)<0.1 then totalf-achitat
					when achitat>running then 0 
					when achitat>running-suma and suma<achitat then running-achitat
					when achitat>running-suma and suma>achitat then suma-achitat
					else suma
					end)

	update f set data_scadentei=(case when ffurn.factura is null or ffurn.data_ultimei_achitari<'01/01/1980' then '12/31/2999' else ffurn.data_ultimei_achitari end)
		from #fdeadaugat f
		left join facturi ffurn on (case when f.tip='F' then 0x46 else 0x54 end)=ffurn.tip and ffurn.tert=f.tertf and ffurn.factura=f.Facturaf
		where f.tertf is not null

	if @procApelanta='wIaFacturiTerti' --Datele ne vin in tabela #facturi
	begin
		insert into #facturi
		select 
		sf.tip as tip, sf.tert,f.factura, convert(char(10),f.data,101),
		convert(char(10),sf.Data_scadentei,101) as datascadentei, 
		convert(decimal(12,2),sf.suma-sf.suma*(f.TVA_11+f.TVA_22)/f.valoare) as valoare,
		convert(decimal(12,2),sf.suma*(f.TVA_11+f.TVA_22)/f.valoare) as TVA,
		CONVERT (decimal (12,2), sf.suma-sf.sold) as achitat, 
		convert(char(10),f.Data_ultimei_achitari ,101), 
		convert(decimal(12,2),sf.sold) as sold, 
		RTRIM(f.Cont_de_tert) as cont, rtrim(f.Loc_de_munca) as lm,
		f.valuta, f.curs, f.Sold_valuta*sf.suma/(f.valoare+f.tva_11+f.tva_22)
		from #fdeadaugat sf
		inner join facturi f on f.subunitate='1' and f.tip=(case when sf.Tip='B' then 0x46 else 0x54 end) and f.tert=sf.tert and f.Factura=sf.factura
	end	
	else if @procApelanta='wOPPreluareFacturiInOrdineDePlata' --Datele ne vin in tabela #pfacturi
	begin
		
		insert into #pfacturi(subunitate,loc_de_munca,tip,factura,tert,data,data_scadentei,valoare,tva,valuta,curs,valoare_valuta,achitat,sold,cont_factura,achitat_valuta,sold_valuta,comanda,data_ultimei_achitari,achitat_interval,achitat_interval_plata,explicatii)
		select 
		pfo.subunitate,
		pfo.loc_de_munca,
		pfo.tip,
		pfo.factura,
		pfo.tert,
		pfo.data,
		fa.data_scadentei,
		convert(decimal(12,2),fa.suma-pfo.tva*fa.suma/(f.valoare+f.tva_11+f.tva_22)),
		convert(decimal(12,2),pfo.tva*fa.suma/(f.valoare+f.tva_11+f.tva_22)),
		pfo.valuta,
		pfo.curs,
		convert(decimal(12,2),pfo.valoare_valuta*fa.suma/(f.valoare+f.tva_11+f.tva_22)),
		convert(decimal(12,2),fa.suma-fa.sold),
		convert(decimal(12,2),fa.sold),
		pfo.cont_factura,
		convert(decimal(12,2),pfo.achitat_valuta*fa.suma/(f.valoare+f.tva_11+f.tva_22)),
		convert(decimal(12,2),pfo.sold_valuta*fa.suma/(f.valoare+f.tva_11+f.tva_22)),
		f.comanda,
		f.data_ultimei_achitari,
		pfo.achitat_interval,
		pfo.achitat_interval_plata,
		pfo.explicatii
		from #fdeadaugat fa
		inner join #pFacturiOrig pfO on (case when fa.Tip='B' then 0x46 else 0x54 end)=pfo.tip and fa.tert=pfo.tert and fa.factura=pfo.factura
		inner join facturi f on f.subunitate='1' and f.tip=(case when fa.Tip='B' then 0x46 else 0x54 end) and f.tert=fa.tert and f.Factura=fa.factura
	end
