--***
create procedure [dbo].[insertSemif] @dDataJos datetime,@dDataSus datetime 
as
begin
declare @cArtS char(13),@lCuPct int, @PM int,@dDataLT datetime, @subunitate char(9)
declare @nLM int,@nFetch int,@cCod char(20),@nStocInit float,@nCantitate float,@nConsCurent float,@lmT int, @DecSemif int
declare @cLm char(13),@cCom char(13),@cLMI char(13),@cComI char(13),@nPretLT float,@bucla int
set @cArtS=isnull((select val_alfanumerica from par where tip_parametru='PC' and parametru='ARTCALS'),'')
set @lCuPct=isnull((select val_logica from par where tip_parametru='PC' and parametru='COMPCT'),0)
set @lmT=isnull((select val_logica from par where tip_parametru='PC' and parametru='INLOCLMT'),0)
set @subunitate = (select val_alfanumerica from par where tip_parametru='GE' and parametru='SUBPRO') 
-- parametru in baza caruia se va deconta semifabricatul la pretul predarii
set @DecSemif=isnull((select val_logica from par where tip_parametru='PC' and parametru='DECSEMIF'),0)
set @nLm=isnull((select max(lungime) from strlm where costuri=1),0)
-- Consumuri de semifabricate 
SELECT data,LEFT(LOC_DE_MUNCA,@nLm) AS LOC_DE_MUNCA,left(COMANDA,13) as comanda,cod,gestiune,cod_intrare,cantitate,pret_de_stoc,numar
into #semi1 FROM POZDOC WHERE TIP='CM' and data between @dDataJos and @dDataSus and cont_corespondent like '711%'
--Completare comanda inferioara si loc munca inferior 
select p.cod,p.cod_intrare,LEFT(p.LOC_DE_MUNCA,@nLm) AS LOC_DE_MUNCA,left((case when c.tip_comanda='C' then p.comanda else p.comanda end),13) as comanda
into #semi2 from pozdoc p,comenzi c
where @DecSemif=0 and p.comanda=c.comanda and c.subunitate = @subunitate and p.tip='PP' and p.data between @dDataJos and @dDataSus and
exists (select cod,cod_intrare from #semi1 where 
p.cod=#semi1.cod and p.cod_intrare=#semi1.cod_intrare)
if @PM=1
begin
	declare codTMP cursor for	
	SELECT #semi1.cod,LEFT(#semi1.LOC_DE_MUNCA,@nLm),#semi1.COMANDA,
	isnull(LEFT(#semi2.LOC_DE_MUNCA,@nLm),''),isnull(#semi2.comanda,'711'),
	sum(DISTINCT cantitate)
	from #semi1 left outer join #semi2 
	on #semi1.cod=#semi2.cod and 
	#semi1.cod_intrare=#semi2.cod_intrare
	group by #semi1.cod,LEFT(#semi1.LOC_DE_MUNCA,@nLm),#semi1.COMANDA,
	isnull(LEFT(#semi2.LOC_DE_MUNCA,@nLm),''),isnull(#semi2.comanda,'711')
	open codTMP
	fetch next from codTMP into @cCod,@cLM,@cCom,@cLMI,@cComI,@nCantitate
	set @nFetch=@@fetch_status
	while @nFetch=0
	begin
		set @nStocInit=isnull((select sum(cantitate) from nutstocint(@dDataLT,'',@cCod,'','')),0)
		if @nStocInit>@nCantitate set @nStocInit=@nCantitate
		set @nPretLT=isnull((select sum(VALOARE)/SUM(cantitate) from nutstocint(@dDataLT,'',@cCod,'','')),0)
		if @nPretLT is null set @nPretLT=-5
		set @nConsCurent=@nCantitate-@nStocinit
		if @nConsCurent<0 set @nConsCurent=0
		insert into costtmp (DATA,LM_SUP,COMANDA_SUP,ART_SUP,LM_INF,COMANDA_INF,ART_INF,CANTITATE,VALOARE,PARCURS,Tip,Numar) 
		SELECT @dDataSus,@cLm,@cCom,@cArtS,'','711','T',@nStocInit,@nPretLT,0,'CM','1'
		if @nConsCurent>0
			insert into costtmp (DATA,LM_SUP,COMANDA_SUP,ART_SUP,LM_INF,COMANDA_INF,ART_INF,CANTITATE,VALOARE,PARCURS,Tip,Numar) 
			SELECT @dDataSus,@cLm,@cCom,@cArtS,@cLMI,@cComI,'T',@nConscurent,0,0,'CX','2'
		fetch next from codTMP into @cCod,@cLM,@cCom,@cLMI,@cComI,@nCantitate
		set @nFetch=@@fetch_status
	end
	close codTmp
	deallocate CodTmp
end
else
begin
	insert into costtmp (DATA,LM_SUP,COMANDA_SUP,ART_SUP,LM_INF,COMANDA_INF,ART_INF,CANTITATE,VALOARE,PARCURS,Tip,Numar) 
	SELECT #semi1.DATA,LEFT(#semi1.LOC_DE_MUNCA,@nLm),#semi1.COMANDA,
	(case when isnull(LEFT(#semi1.LOC_DE_MUNCA,@nLm),'')='' and isnull(#semi1.comanda,'')='' then 'T' else @cArtS end)
	,isnull(LEFT(#semi2.LOC_DE_MUNCA,@nLm),''),isnull((case when cp.tip_comanda='C' then #semi2.cod else #semi2.comanda end),'711'),'T',
	sum(cantitate),(case when #semi2.comanda is null then sum(cantitate*pret_de_stoc)/sum(cantitate) else 0 end),0,'CX',#semi1.numar
	from #semi1 left outer join #semi2  
	 on #semi1.cod=#semi2.cod and #semi1.cod_intrare=#semi2.cod_intrare
	 left outer join comenzi cp on #semi2.comanda=cp.comanda and cp.subunitate = @subunitate
	 group by   
	#semi1.DATA,LEFT(#semi1.LOC_DE_MUNCA,@nLm),#semi1.COMANDA,
	(case when isnull(LEFT(#semi1.LOC_DE_MUNCA,@nLm),'')='' and isnull(#semi1.comanda,'')='' then 'T' else @cArtS end)
	,isnull(LEFT(#semi2.LOC_DE_MUNCA,@nLm),''),isnull((case when cp.tip_comanda='C' then #semi2.cod else #semi2.comanda end),'711'),#semi1.numar,#semi2.comanda having abs(sum(cantitate))>0.00001
end
drop table #semi1
drop table #semi2
end
