
CREATE procedure [dbo].[yso_rapAnalizaProduseLactate] @luna int,@tert nvarchar(4000),@anul int,@cod nvarchar(4000),@lm nvarchar(4000), @top int, @topPeAn int
as
--@topPeAm =1 se face situatia pe tot anul, 0 se face situatia pe o luna selectata
/*
declare @data1 datetime,@tert nvarchar(4000),@data2 datetime,@cod nvarchar(4000),@lm nvarchar(4000)
select @data1='2016-03-01 00:00:00',@tert=null,@data2='2016-03-31 00:00:00',@cod=NULL,@lm=NULL
--*/
if @topPeAn=0
begin
		select top (isnull(@top,2000)) ltrim(rtrim(ProdLapte.Denumire)) as tert,
		(case when MONTH(p.Data_lunii)=1 then 'Ianuarie'
			when MONTH(p.Data_lunii)=2 then 'Februarie'
			when MONTH(p.Data_lunii)=3 then 'Martie'
			when MONTH(p.Data_lunii)=4 then 'Aprilie'
			when MONTH(p.Data_lunii)=5 then 'Mai'
			when MONTH(p.Data_lunii)=6 then 'Iunie'
			when MONTH(p.Data_lunii)=7 then 'Iulie'
			when MONTH(p.Data_lunii)=8 then 'August'
			when MONTH(p.Data_lunii)=9 then 'Septembrie'
			when MONTH(p.Data_lunii)=10 then 'Octombrie'
			when MONTH(p.Data_lunii)=11 then 'Noiembrie'
			when MONTH(p.Data_lunii)=12 then 'Decembrie' end)
		 as luna,YEAR(p.Data_lunii) as an, MONTH(p.Data_lunii) as lunaInt,
		SUM(p.cant_UM) as cant, SUM(p.cant_UM*g.pret)/(case when SUM(p.cant_UM)=0 then 1 else SUM(p.cant_UM) end)   as pret,
		SUM(p.cant_UM)*(SUM(g.pret)/(case when COUNT(*)=0 then 1 else COUNT(*)end)) as valoare,
		max(ltrim(rtrim(isnull(prodLapte.Strada,''))))+' Loc.: '+max(ltrim(rtrim(isnull(localitati.oras,''))))+' Jud.: '+max(ltrim(rtrim(isnull(judete.denumire,'')))) as adresa
		from BordAchizLapte p
		left join ProdLapte ON p.Producator = ProdLapte.Cod_producator 
		left join GrilaPretCentrColectLapte g on p.Centru_colectare=g.Centru_colectare and p.Tip_lapte=g.Tip_lapte and p.Data_lunii=g.Data_lunii
        left join dbo.CentrColectLapte ON p.Centru_colectare = dbo.CentrColectLapte.Cod_centru_colectare 
		left join lm ON dbo.CentrColectLapte.Loc_de_munca = lm.Cod 
		left join localitati on localitati.cod_oras=ltrim(rtrim(ProdLapte.Localitate))
		left join judete on judete.cod_judet=ltrim(rtrim(ProdLapte.Judet))
		--left join infotert i on p.Producator=i.Tert and i.Identificator=d.Gestiune_primitoare
		where 
		(ISNULL(@tert,'')='' or p.Producator=@tert)
		and (ISNULL(@lm,'')='' or lm.Cod=@lm)
		--and (ISNULL(@pl,'')='' or i.Identificator=@pl)
		and month(p.Data_lunii)=@luna and year(p.Data_lunii)=@anul
		and p.cant_UM>0
		group by MONTH(p.Data_lunii),ltrim(rtrim(ProdLapte.Denumire)),YEAR(p.Data_lunii)
		order by cast(MONTH(p.Data_lunii) as int),sum(p.Cant_UM) desc, ltrim(rtrim(ProdLapte.Denumire))
end

if @topPeAn=1
begin
select top (isnull(@top,2000)) ltrim(rtrim(ProdLapte.Denumire)) as tert,
		@anul as luna,YEAR(p.Data_lunii) as an, @anul as lunaInt,
		SUM(p.cant_UM) as cant, SUM(p.cant_UM*g.pret)/(case when SUM(p.cant_UM)=0 then 1 else SUM(p.cant_UM) end)   as pret,
		SUM(p.cant_UM)*(SUM(g.pret)/(case when COUNT(*)=0 then 1 else COUNT(*)end)) as valoare,
		max(ltrim(rtrim(isnull(prodLapte.Strada,''))))+' Loc.: '+max(ltrim(rtrim(isnull(localitati.oras,''))))+' Jud.: '+max(ltrim(rtrim(isnull(judete.denumire,'')))) as adresa
		from BordAchizLapte p
		left join GrilaPretCentrColectLapte g on p.Centru_colectare=g.Centru_colectare and p.Tip_lapte=g.Tip_lapte and p.Data_lunii=g.Data_lunii
		left join ProdLapte ON p.Producator = ProdLapte.Cod_producator 
        left join dbo.CentrColectLapte ON p.Centru_colectare = dbo.CentrColectLapte.Cod_centru_colectare 
		left join lm ON dbo.CentrColectLapte.Loc_de_munca = lm.Cod 
		left join localitati on localitati.cod_oras=ltrim(rtrim(ProdLapte.Localitate))
		left join judete on judete.cod_judet=ltrim(rtrim(ProdLapte.Judet))
		--left join infotert i on p.Producator=i.Tert and i.Identificator=d.Gestiune_primitoare
		where 
		(ISNULL(@tert,'')='' or p.Producator=@tert)
		and (ISNULL(@lm,'')='' or lm.Cod=@lm)
		--and (ISNULL(@pl,'')='' or i.Identificator=@pl)
		and year(p.Data_lunii)=@anul
		and p.cant_UM>0
		group by year(p.Data_lunii),ltrim(rtrim(ProdLapte.Denumire))
		order by cast(year(p.Data_lunii) as int),sum(p.Cant_UM) desc, ltrim(rtrim(ProdLapte.Denumire))
end
