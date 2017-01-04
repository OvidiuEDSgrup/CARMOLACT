create
-- alter
function [dbo].[fStocuriCenGest](@dDataSus datetime,@cGestiune char(9)) 
returns float
as
begin

declare @nValStoc float
/*
declare @AccDVI int, @TimbruLit int
set @AccDVI = (select isnull(max(convert(int, val_numerica)),0) from par where tip_parametru='GE' and parametru='ACCIMP')
set @TimbruLit = (select isnull(max(convert(int, val_numerica)),0) from par where tip_parametru='GE' and parametru='TIMBRULIT')

declare @docstoc table (subunitate char(9),gestiune char(13),cont char(20),cod char(20),data datetime,cod_intrare char(20),pret float,tip_document char(2),numar_document char(9),cantitate float,tip_miscare char(1),in_out char(1),predator char(13),jurnal char(3),tert char(13),serie char(20),pret_cu_amanuntul float,tip_gestiune char(1),locatie char(30),data_expirarii datetime,TVA_neexigibil int,pret_vanzare float,accize_cump float,loc_de_munca char(13),comanda char(20),numar_pozitie int,
	grp varchar(100),ordine varchar(30),
	dataStoc datetime, pretStoc float, contStoc char(20), dataExpStoc datetime, locatieStoc char(30))

if @GrCod  is null set @GrCod  = 1
if @GrGest is null set @GrGest = 1
if @GrCodi is null set @GrCodi = 1
if @TipStoc is null set @TipStoc = ''
if @UM2 is null set @UM2 = 0

insert @docstoc
select subunitate,gestiune,cont,cod,data,cod_intrare,pret,tip_document,numar_document,cantitate,tip_miscare,in_out,predator,jurnal,tert,serie,pret_cu_amanuntul,tip_gestiune,locatie,data_expirarii,TVA_neexigibil,pret_vanzare,accize_cump,loc_de_munca,comanda,numar_pozitie,
subunitate+tip_gestiune+gestiune+cod+cod_intrare,
(case when tip_document = 'SI' then '0' else '1' end)+(case when tip_miscare='I' and tip_document<>'AI' or tip_miscare='E' and cantitate<0 then '0' when tip_document='AI' then '1' else '2' end)+convert(char(8),data,112)+str(numar_pozitie),
'01/01/2999', 0, '', '01/01/2999', ''
from dbo.fStocuri(null, @dDataSus, @cCod, @cGestiune, @cCodi, @cGrupa, @TipStoc, @UM2, @cCont)

/* -- Merge greu cu putina memorie libera
update @docstoc
set 
dataStoc=data, pretStoc=pret, contStoc=cont, dataExpStoc=data_expirarii, locatieStoc=locatie
from @docstoc d
where not exists (select 1 from @docstoc d1 where d1.grp=d.grp and d1.ordine<d.ordine)
*/

update @docstoc
set 
dataStoc=data, pretStoc=pret, contStoc=cont, dataExpStoc=data_expirarii, locatieStoc=locatie
from @docstoc d, (select d2.grp, min(d2.ordine) as ordine from @docstoc d2 group by d2.grp) d1
where d.grp=d1.grp and d.ordine=d.ordine
*/

--insert @stoc
SET @nValStoc=(SELECT sum(valoare_stoc)
--subunitate, 
--max(case when @GrGest=1 then gestiune else '' end),
--max(case when @GrGest=1 then tip_gestiune when tip_gestiune in ('F', 'T') then tip_gestiune else '' end), 
--max(case when @GrCod=1 then cod else '' end), 
--min(dataStoc), max(case when @GrCodi=1 then cod_intrare else '' end),
--max(pretStoc), 
--sum(round(convert(decimal(15,5), case when tip_document='SI' then cantitate else 0 end), 3)),
--sum(round(convert(decimal(15,5), case when tip_document<>'SI' and tip_miscare='I' then cantitate else 0 end), 3)),
--sum(round(convert(decimal(15,5), case when tip_document<>'SI' and tip_miscare='E' then cantitate else 0 end), 3)),
--max(case when tip_miscare='E' then data else '01/01/1901' end),
--sum(round(convert(decimal(15,5), (case when tip_miscare='E' then -1 else 1 end)*cantitate), 3)),
--max(contStoc), min(dataExpStoc), max(TVA_neexigibil),
--max(case when (@AccDVI=1 or @TimbruLit=1) and tip_miscare='I' and accize_cump<>0 and tip_document<>'AI' and tip_gestiune<>'A' then accize_cump when tip_miscare='I' then pret_cu_amanuntul else 0 end), 
--max(locatieStoc),
--sum((case when tip_miscare='E' then -1 else 1 end)*cantitate*pret)
from fStocuriCen(@dDataSus,null,@cGestiune,null,null,null,null,null,null,null,null,null,null,null,null,null))
--group by subunitate,gestiune

return @nValStoc
end

/****** Object:  View [dbo].[AS_comenzi]    Script Date: 03/31/2008 10:12:40 ******/

