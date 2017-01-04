
--***
CREATE PROCEDURE wIaPreturiAmanunt @sesiune VARCHAR(50), @parXML XML
as
/*
	Procedura primiseste parametrii de mai jos (XML) si in functie de o linie din acesti parametrii va oferi preturile
	In mod normal este suficient idpozdoc.
	Totusi, pentru evaluarea stocurilor, idpozdoc este egal cu zero -> va conta gestiunea si codul din pozitii + data din parxml
*/

declare @data datetime,@dinTabela int
select @data= @parXML.value('(/row/@data)[1]', 'datetime')

declare @nAnImpl int, @nLunaImpl int, @dDataIstoric datetime

set @nAnImpl=isnull((select max(val_numerica) from par where tip_parametru='GE' and parametru='ANULIMPL'), 1901)
set @nLunaImpl=isnull((select max(val_numerica) from par where tip_parametru='GE' and parametru='LUNAIMPL'), 1)
set @dDataIstoric=dbo.eom(dateadd(year, @nAnImpl-1901, dateadd(month, @nLunaImpl-1, '01/01/1901')))

if exists(select 1 from #preturiam where idpozdoc=0)
	begin
		set @dinTabela=1 --Pentru STOC / SOLD
	end
else
	begin
		set @dinTabela=0 -- Pentru MISCARI se va face legatura cu POZDOC pe idpozdoc
	end


select (case when @dinTabela=1 then pa.gestiune else (case when pa.tip='TI' then p.gestiune_primitoare else p.gestiune end) end) as gestiune,convert(int,0) as categpret
into #gestpr
from #preturiam pa
left join pozdoc p on pa.idpozdoc=p.idpozdoc
group by (case when @dinTabela=1 then pa.gestiune else (case when pa.tip='TI' then p.gestiune_primitoare else p.gestiune end) end)

update #gestpr
set categpret=p.valoare
FROM proprietati p
WHERE p.tip = 'GESTIUNE'
AND p.Cod_proprietate = 'CATEGPRET'
AND p.cod = #gestpr.gestiune

select n.cod,pa.gestiune,p.idpozdoc,rank() over (partition by n.cod order by ctva.dela desc) as ranc,isnull(ctva.CotaTVA,n.cota_tva) as cota_tva
into #ntva
from #preturiam pa
left join pozdoc p on pa.idpozdoc=p.idpozdoc
inner join nomencl n on pa.cod=n.cod
left join CategoriiTVA ctva on ctva.CategorieTVA=n.CategorieTVA and isnull(@data,( case when p.tip ='SI' then @dDataIstoric else p.data end))>=ctva.dela

delete from #ntva where ranc>1

if @dinTabela=0
	update p set cota_tva=n.cota_tva
	from #preturiam p
	inner join #ntva n on p.idpozdoc=n.idPozDoc
else
	update p set cota_tva=n.cota_tva
	from #preturiam p
	inner join #ntva n on p.cod=n.cod and p.gestiune=n.gestiune


/*Categoria de pret aferenta gestiunii*/
select pa.idpozdoc,pa.tip,pa.gestiune,g.categpret,pa.cod,prg.Data_inferioara,rank() over (partition by pa.gestiune,pa.cod,pa.idpozdoc order by prg.data_inferioara desc) as ranc,prg.pret_cu_amanuntul
into #t1
from #preturiam pa
left join pozdoc p on pa.idpozdoc=p.idpozdoc
inner join #gestpr g on (case when @dinTabela=1 then pa.gestiune when pa.tip='TI' then p.gestiune_primitoare else p.gestiune end)=g.Gestiune
left join preturi prg on prg.Cod_produs=pa.cod and prg.Tip_pret='1' and prg.um=g.categpret and isnull(@data,( case when p.tip ='SI' then @dDataIstoric else p.data end))>=prg.data_inferioara
delete from #t1 where ranc>1 

if @dinTabela=1
begin
	update p set pret_amanunt=#t1.Pret_cu_amanuntul
	from #preturiam p
	inner join #t1 on p.gestiune=#t1.gestiune and p.cod=#t1.cod
	where #t1.Pret_cu_amanuntul is not null
end
else
begin
	update p set pret_amanunt=#t1.Pret_cu_amanuntul
	from #preturiam p
	inner join #t1 on p.idpozdoc=#t1.idpozdoc and p.tip=#t1.tip
	where #t1.Pret_cu_amanuntul is not null
end
drop table #t1


/*Categoria de pret 1*/
select pa.idpozdoc,pa.tip,pa.gestiune,prg.um,pa.cod,prg.Data_inferioara,rank() over (partition by pa.gestiune,pa.cod,pa.idpozdoc order by prg.data_inferioara desc) as ranc,prg.pret_cu_amanuntul
into #t2
from #preturiam pa
left join pozdoc p on pa.idpozdoc=p.idpozdoc
left join preturi prg on prg.Cod_produs=pa.cod and prg.Tip_pret='1' and prg.um='1' and isnull(@data,( case when p.tip ='SI' then @dDataIstoric else p.data end))>=prg.data_inferioara

if @dinTabela=1
begin
	update p set pret_amanunt=#t2.Pret_cu_amanuntul
	from #preturiam p
	inner join #t2 on p.gestiune=#t2.gestiune and p.cod=#t2.cod
	where isnull(p.pret_amanunt,0)=0 and #t2.Pret_cu_amanuntul is not null
end
else
begin
	update p set pret_amanunt=#t2.Pret_cu_amanuntul
	from #preturiam p
	inner join #t2 on p.idpozdoc=#t2.idpozdoc and p.tip=#t2.tip
	where isnull(p.pret_amanunt,0)=0 and #t2.Pret_cu_amanuntul is not null
end

update #preturiam set pret_vanzare=round(pret_amanunt/(1.00+cota_tva/100.00),5)

if exists(select * from sysobjects where name='wIaPreturiAmanuntSP2' and type='P')
	exec wIaPreturiAmanuntSP2 @sesiune=@sesiune, @parXML=@parXML 

if exists(select * from #preturiam where isnull(pret_amanunt,0)=0)
begin
	update pr set pret_vanzare=0,pret_amanunt=0
	from #preturiam pr
	inner join pozdoc p on p.idpozdoc=pr.idpozdoc
	where isnull(pr.pret_amanunt,0)=0
	
	declare @msgErr varchar(max)
	set @msgErr='Eroare: Aveti documente fara pret cu amanuntul completat:'+char(13)

	/*
	if @dinTabela=0
		select top 20 @msgErr=@msgErr+'Document: '+ltrim(p.tip)+'-'+ltrim(rtrim(p.numar))+'-'+convert(char(10),isnull(@data,( case when p.tip ='SI' then @dDataIstoric else p.data end)),103)+',Cod:'+ltrim(p.cod)+char(13)
		from #preturiam pr
		inner join pozdoc p on p.idpozdoc=pr.idpozdoc
		where isnull(pr.pret_amanunt,0)=0
	else
		select top 20 @msgErr=@msgErr+'Cod: '+ltrim(pr.cod)+char(13)
		from #preturiam pr
		where isnull(pr.pret_amanunt,0)=0
	
	raiserror(@msgErr,16,1)*/
end
