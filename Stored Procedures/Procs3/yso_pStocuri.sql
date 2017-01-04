--***
create procedure yso_pStocuri(@dDataJos datetime, @dDataSus datetime, @cCod char(20), @cGestiune char(20), @cCodi char(20), @cGrupa char(13), @TipStoc char(1), @cCont char(13), @Corelatii int, 
	@Locatie char(30), @LM char(9), @Comanda char(40), @Contract char(20), @Furnizor char(13), @Lot char(20))

as
begin
declare @cSub char(13), @StocCom int, @StocFurn int, @StocLot int, @SubgestFolLM int, @PropDataS char(20), 
	@dDataIstoric datetime, @dDataStartPozdoc datetime, @nAnInc int, @nLunaInc int, @nAnImpl int, @nLunaImpl int

select @cSub='', @StocCom=0, @StocFurn=0, @StocLot=0, @SubgestFolLM=0, @PropDataS=''

select @cSub=(case when tip_parametru='GE' and parametru='SUBPRO' then val_alfanumerica else @cSub end),
	@StocCom = (case when tip_parametru='GE' and parametru='STOCPECOM' then val_logica else @StocCom end),
	@StocFurn = (case when tip_parametru='GE' and parametru='STOCFURN' then val_logica else @StocFurn end),
	@StocLot = (case when tip_parametru='GE' and parametru='STOCLOT' then val_logica else @StocLot end),
	@SubgestFolLM=(case when tip_parametru='GE' and parametru='SUBGLMFOL' then val_logica else @SubgestFolLM end),
	@PropDataS=(case when tip_parametru='GE' and parametru='DATASTOCP' and val_logica=1 then val_alfanumerica else @PropDataS end)
from par where tip_parametru='GE'

if @Corelatii is null set @Corelatii=0

if @Corelatii<>1 begin
	set @nAnInc=isnull((select max(val_numerica) from par where tip_parametru='GE' and parametru='ANULINC'), 1901)
	set @nLunaInc=isnull((select max(val_numerica) from par where tip_parametru='GE' and parametru='LUNAINC'), 1)
	set @dDataIstoric=dbo.eom(dateadd(year, @nAnInc-1901, dateadd(month, @nLunaInc-1, '01/01/1901')))
	set @dDataStartPozdoc=dateadd(day, 1, @dDataIstoric)
	if @dDataSus is null set @dDataSus='12/31/2999'
	if @dDataJos is null set @dDataJos=(case when @dDataSus>=@dDataIstoric then @dDataStartPozdoc else @dDataSus end)
	if @dDataJos<@dDataStartPozdoc
	begin
		set @dDataIstoric=(select max(data_lunii) from istoricstocuri where data_lunii<@dDataJos 
			or data_lunii=@dDataJos and @dDataJos=@dDataSus)
		if @dDataIstoric is null
		begin
			set @nAnImpl=isnull((select max(val_numerica) from par where tip_parametru='GE' and parametru='ANULIMPL'), 1901)
			set @nLunaImpl=isnull((select max(val_numerica) from par where tip_parametru='GE' and parametru='LUNAIMPL'), 1)
			set @dDataIstoric=dbo.eom(dateadd(year, @nAnImpl-1901, dateadd(month, @nLunaImpl-1, '01/01/1901')))
		end
		set @dDataStartPozdoc=dateadd(day, 1, @dDataIstoric)
	end	
end
else begin
	set @dDataStartPozdoc=@dDataJos
end

select @TipStoc=isnull(@TipStoc, ''), @cGrupa=(case when isnull(@cGrupa, '')='' then '%' else @cGrupa end), @cCont=isnull(@cCont, ''), 
	@Locatie=isnull(@Locatie, ''), @LM=isnull(@LM, ''), @Comanda=isnull(@Comanda, ''), 
	@Contract=isnull(@Contract, ''), @Furnizor=isnull(@Furnizor, ''), @Lot=isnull(@Lot, '')

if OBJECT_ID('tempdb..#doc') is not null
	drop table #doc

create table #doc 
(subunitate char(9), gestiune char(20), cont char(20), cod char(20), data datetime, cod_intrare char(20), pret float, 
tip_document char(2), numar_document char(9), cantitate float, cantitate_UM2 float, tip_miscare char(1), in_out char(1), 
predator char(20), codi_pred char(20), jurnal char(3), tert char(13), serie char(20), pret_cu_amanuntul float, tip_gestiune char(1), 
locatie char(30), data_expirarii datetime, TVA_neexigibil int, pret_vanzare float, accize_cump float, loc_de_munca char(9), 
comanda char(40), [contract] char(20), furnizor char(13), lot char(20), numar_pozitie int, cont_corespondent char(13), schimb int,
grp varchar(80), grppred varchar(80))

if OBJECT_ID('tempdb..#docstoc') is not null
	drop table #docstoc

create table #docstoc 
(subunitate char(9),gestiune char(20),cont char(20),cod char(20),data datetime,cod_intrare char(20),pret float,tip_document char(2),numar_document char(9),cantitate float,cantitate_UM2 float,tip_miscare char(1),in_out char(1),predator char(20),
	codi_pred char(20), jurnal char(3),tert char(13),serie char(20),pret_cu_amanuntul float,tip_gestiune char(1),locatie char(30),data_expirarii datetime,TVA_neexigibil int,pret_vanzare float,accize_cump float,loc_de_munca char(9),comanda char(40),
	[contract] char(20),furnizor char(13),lot char(20),numar_pozitie int,cont_corespondent char(13), schimb int, contractdinpozdoc_pebune varchar(20))

declare @DIst datetime,@DJPdoc datetime,@DSus datetime,
	@Cod char(20),@Gest char(20),@Codi char(20),@Grupa char(13),@Cont char(13),@Corel int,
	@Loc char(30),@Com char(40),@Cntr char(20),@Furn char(13)
	
select @DIst =@dDataIstoric,@DJPdoc =@dDataStartPozdoc,@DSus =@dDataSus,
	@Cod =@cCod,@Gest =@cGestiune,@Codi =@cCodi,@Grupa =@cGrupa,@TipStoc =@TipStoc,@Cont =@cCont,@Corel =@Corelatii,
	@Loc =@Locatie,@LM =@LM,@Com =@Comanda,@Cntr =@Contract,@Furn =@Furnizor,@Lot =@Lot
	
declare @Sb char(13),@C35 int,@C8 int,@UM2 int,@PrestTE int,@SFL int
set @Sb=isnull((select max(val_alfanumerica) from par where tip_parametru='GE' and parametru='SUBPRO'),'')
set @C35=isnull((select max(cast(val_logica as int)) from par where tip_parametru='GE' and parametru='STCUST35'),0)
set @C8=isnull((select max(cast(val_logica as int)) from par where tip_parametru='GE' and parametru='STCUST8'),0)
set @PrestTE=isnull((select max(cast(val_logica as int)) from par where tip_parametru='GE' and parametru='PRESTTE'),0)
set @UM2=isnull((select max(cast(val_logica as int)) from par where tip_parametru='GE' and parametru='URMCANT2'),0)
set @SFL=isnull((select max(convert(int, val_logica)) from par where tip_parametru='GE' and parametru='SUBGLMFOL'),0)

	/**	Pregatire filtrare pe proprietati utilizatori*/
declare @fltGstUt int, @eLmUtiliz int
declare @GestUtiliz table(valoare varchar(200), cod varchar(20))
insert into @GestUtiliz (valoare,cod)
select valoare, cod_proprietate from fPropUtiliz() where cod_proprietate='GESTIUNE' and valoare<>'' and @TipStoc<>'F'
set	@fltGstUt=isnull((select count(1) from @GestUtiliz),0)
declare @LmUtiliz table(valoare varchar(200), cod_proprietate varchar(20), marca varchar(20))
insert into @LmUtiliz(valoare, cod_proprietate, marca)
select valoare, cod_proprietate, p.marca
		from fPropUtiliz() f left join personal p on (@sfl=1 or rtrim(f.valoare)=rtrim(p.loc_de_munca))
	where valoare<>'' and cod_proprietate='LOCMUNCA' and @TipStoc='F'
set @eLmUtiliz=isnull((select max(1) from @LmUtiliz),0)

insert #docstoc
select subunitate,cod_gestiune,i.cont,i.cod,data,cod_intrare,pret,'SI','',i.stoc,(case when @UM2=0 and isnull(n.UM_1,'')<>'' and isnull(n.coeficient_conversie_1,0)<>0 then round(convert(decimal(17,5),i.stoc/n.coeficient_conversie_1),3) when @UM2=0 or left(isnull(n.UM_2,''),1)<>'Y' then 0 else i.stoc_UM2 end),'I','1','','','','','',i.pret_cu_amanuntul,tip_gestiune,locatie,data_expirarii,TVA_neexigibil,i.pret_vanzare,0,i.loc_de_munca,comanda,i.contract,i.furnizor,lot,0,'',0,
	'' Contract
from istoricstocuri i
left outer join nomencl n on i.cod=n.cod
where @Corel<>1 and data_lunii=@DIst and subunitate=@Sb and tip_gestiune not in ('V','I') and (@Cod is null or i.cod=rtrim(@Cod)) and (@Gest is null or cod_gestiune=@Gest) and (@Codi is null or cod_intrare=rtrim(@Codi)) and isnull(n.grupa,'') like RTrim(@Grupa) and (@TipStoc='' or @TipStoc='D' and i.tip_gestiune not in ('F','T') or i.tip_gestiune=@TipStoc) and i.cont like RTrim(@Cont)+'%'
and (@Loc='' or locatie in ('',@Loc)) and (@LM='' or i.loc_de_munca in ('',@LM)) and (@Com='' or comanda in('',@Com)) and (@Cntr='' or i.contract in ('',@Cntr)) and (@Furn='' or i.furnizor in ('',@Furn)) and (@Lot='' or lot in ('',@Lot))
and (@fltGstUt=0 or exists(select 1from @GestUtiliz pr where pr.valoare=i.cod_gestiune))
and (@eLmUtiliz=0 or 
	exists(select 1from @LMUtiliz pr --inner join personal p on (@sfl=1 or pr.valoare=p.loc_de_munca and p.marca=i.cod_gestiune)
	where rtrim(pr.valoare) like rtrim(i.loc_de_munca)+'%' and (@sfl=1 or rtrim(pr.marca)=rtrim(i.cod_gestiune))))

union all
select a.subunitate,a.gestiune,a.cont_de_stoc,a.cod,a.data,a.cod_intrare,a.pret_de_stoc,a.tip,a.numar,a.cantitate,(case when @UM2=0 and isnull(n.UM_1,'')<>'' and isnull(n.coeficient_conversie_1,0)<>0 then round(convert(decimal(17,5),a.cantitate/n.coeficient_conversie_1),3) when a.tip in ('PF','CI','AF') or @UM2=0 or left(isnull(n.UM_2,''),1)<>'Y' then 0 when a.tip='RM' and a.numar_DVI<>'' then a.accize_datorate else a.suprataxe_vama end),a.tip_miscare,(case when a.tip_miscare='I' then '2' else '3' end),a.gestiune_primitoare,(case when a.tip not in ('TE','DF','PF') then '' when a.grupa='' then a.cod_intrare else a.grupa end),a.jurnal,(case when a.tip in ('RM','AP') then a.tert when a.tip in ('AI','AE') then left(a.factura,13) else a.loc_de_munca end),'',(case when a.tip_miscare='I' then a.pret_cu_amanuntul else a.pret_amanunt_predator end),(case when a.tip in ('PF','CI','AF') then 'F' else isnull(b.tip_gestiune,'') end),(case when a.tip in ('TE','DF','PF') then isnull(s.locatie,a.locatie) else a.locatie end),(case when a.tip in ('TE','DF','PF') then isnull(s.data_expirarii,a.data_expirarii) else a.data_expirarii end),a.TVA_neexigibil,(case when a.tip_miscare='I' then a.pret_amanunt_predator when a.tip in ('AP','AC') then a.pret_vanzare else a.pret_cu_amanuntul end),a.accize_cumparare,(case when @SFL=1 and a.tip in ('PF','CI') then isnull(s.loc_de_munca,'') else a.loc_de_munca end),a.comanda,(case when a.tip='TE' then a.factura when a.tip in ('AP','AC','PP') then a.contract else '' end),(case a.tip when 'RM' then a.tert when 'AI' then a.cont_venituri else '' end),(case when a.tip='RM' then a.cont_corespondent when a.tip in ('PP','AI') then a.grupa else '' end),a.numar_pozitie,(case when a.tip in ('RM','RS') then a.cont_factura else a.cont_corespondent end),a.procent_vama, a.contract
from pozdoc a
left outer join gestiuni b on a.tip not in ('PF','CI','AF') and b.subunitate=a.subunitate and b.cod_gestiune=a.gestiune
left outer join nomencl n on a.cod=n.cod
left outer join stocuri s on a.tip in ('TE','DF','PF','CI') and s.subunitate=a.subunitate and s.cod_gestiune=a.gestiune and s.tip_gestiune=(case when a.tip in ('DF','PF','CI') then 'F' else b.tip_gestiune end) and s.cod=a.cod and s.cod_intrare=a.cod_intrare
where a.subunitate=@Sb and a.tip_miscare between 'E' and 'I' and (a.tip in ('PF','CI','AF') or isnull(b.tip_gestiune,'')<>'I' and (@Corel=1 or isnull(b.tip_gestiune,'')<>'V')) and isnull(n.tip,'') not in ('R','S') and a.data between @DJPdoc and @DSus and (@Cod is null or a.cod=@Cod) and (@Gest is null or a.gestiune=@Gest) and (@Codi is null or a.cod_intrare=rtrim(@Codi)) and isnull(n.grupa,'') like RTrim(@Grupa) and (@TipStoc='' or @TipStoc='D' and a.tip not in ('PF','CI','AF') or @TipStoc='F' and a.tip in ('PF','CI','AF')) and a.cont_de_stoc like RTrim(@Cont)+'%'
and (@Loc='' or (case when a.tip in ('TE','DF','PF') then isnull(s.locatie,a.locatie) else a.locatie end) in ('',@Loc)) 
and (@LM='' or (case when @SFL=1 and a.tip in ('PF','CI') then isnull(s.loc_de_munca,'') else a.loc_de_munca end) like rtrim(@LM)+'%') 
and (@Com='' or a.comanda in('',@Com))
and (@Cntr='' or (case when a.tip='TE' then a.factura when a.tip in ('AP','AC','PP') then a.contract else '' end) in ('',@Cntr))
and (@Furn='' or (case a.tip when 'RM' then a.tert when 'AI' then a.cont_venituri else '' end) in ('',@Furn))
and (@Lot='' or (case when a.tip='RM' then a.cont_corespondent when a.tip in ('PP','AI') then a.grupa else '' end) in ('',@Lot))
and (@fltGstUt=0 or exists(select 1from @GestUtiliz pr where pr.valoare=a.gestiune))
and (@eLmUtiliz=0 or 
	exists(select 1from @LMUtiliz pr --inner join personal p on (@sfl=1 or pr.valoare=p.loc_de_munca and p.marca=a.gestiune)
			where rtrim(pr.valoare) like rtrim(case when @SFL=1 and a.tip in ('PF','CI') then isnull(s.loc_de_munca,'') else a.loc_de_munca end)+'%'
					and (@sfl=1 or rtrim(pr.marca)=rtrim(a.gestiune))))
union all
select a.subunitate,a.gestiune_primitoare,a.cont_corespondent,a.cod,a.data,(case when a.grupa='' then a.cod_intrare else a.grupa end),(case when a.tip='TE' and @PrestTE=1 and a.accize_datorate<>0 then accize_datorate else a.pret_de_stoc end)*(case when a.tip='DF' and a.procent_vama>0 then (1-convert(decimal(12,3),a.procent_vama/100)) else 1 end),(case a.tip when 'DF' then 'DI' when 'PF' then 'PI' else 'TI' end),a.numar,a.cantitate,(case when @UM2=0 and isnull(n.UM_1,'')<>'' and isnull(n.coeficient_conversie_1,0)<>0 then round(convert(decimal(17,5),a.cantitate/n.coeficient_conversie_1),3) when a.tip in ('DF','PF') or @UM2=0 or left(isnull(n.UM_2,''),1)<>'Y' then 0 else a.suprataxe_vama end),'I','2',a.gestiune,a.cod_intrare,a.jurnal,'','',a.pret_cu_amanuntul,(case when a.tip in ('DF','PF') then 'F' else isnull(tip_gestiune,'') end),a.locatie,a.data_expirarii,a.TVA_neexigibil,a.pret_amanunt_predator,a.accize_cumparare,a.loc_de_munca,a.comanda,(case when a.tip='TE' then a.factura else '' end),'','',a.numar_pozitie,a.cont_de_stoc,a.procent_vama, a.contract
from pozdoc a
left outer join gestiuni b on a.tip not in ('DF','PF') and b.subunitate=a.subunitate and b.cod_gestiune=a.gestiune_primitoare
left outer join nomencl n on a.cod=n.cod
where a.subunitate=@Sb and (a.tip in ('DF','PF') or a.tip='TE' and isnull(tip_gestiune,'') not in ('V','I')) and isnull(n.tip,'') not in ('R','S') and (@Cod is null or a.cod=@Cod) and (@Gest is null or gestiune_primitoare=@Gest) and (@Codi is null or (case when a.grupa='' then a.cod_intrare else a.grupa end)=rtrim(@Codi)) and a.data between @DJPdoc and @DSus and isnull(n.grupa,'') like RTrim(@Grupa) and (@TipStoc='' or @TipStoc='D' and a.tip='TE' or @TipStoc='F' and a.tip in ('DF','PF')) and a.cont_corespondent like RTrim(@Cont)+'%'
and (@Loc='' or a.locatie in ('',@Loc)) and (@LM='' or a.loc_de_munca in ('',@LM)) and (@Com='' or a.comanda in('',@Com))
and (@Cntr='' or (case when a.tip='TE' then a.factura else '' end) in ('',@Cntr))
and (@fltGstUt=0 or exists(select 1from @GestUtiliz pr where pr.valoare=a.gestiune_primitoare))
and (@eLmUtiliz=0 or 
	exists(select 1from @LMUtiliz pr --inner join personal p on (@sfl=1 or pr.valoare=p.loc_de_munca and p.marca=a.gestiune_primitoare)
		where rtrim(pr.valoare) like rtrim(a.loc_de_munca)+'%' and (@sfl=1 or rtrim(pr.marca)=rtrim(a.gestiune_primitoare))))
union all
select a.subunitate,a.tert,cont_corespondent,a.cod,a.data,cod_intrare,a.pret_de_stoc,a.tip,numar,a.cantitate,(case when @UM2=0 and isnull(n.UM_1,'')<>'' and isnull(n.coeficient_conversie_1,0)<>0 then round(convert(decimal(17,5),a.cantitate/n.coeficient_conversie_1),3) else 0 end),(case when tip_miscare='E' then 'I' else 'E' end),(case when tip_miscare='E' then '1' else '2' end),a.gestiune,a.cod_intrare,jurnal,'','',0,'T',locatie,data_expirarii,TVA_neexigibil,a.pret_vanzare,0,a.loc_de_munca,a.comanda,(case when a.tip='AP' then a.contract else '' end),'',(case when a.tip='AI' then a.grupa else '' end),numar_pozitie,a.cont_de_stoc,a.procent_vama, a.Contract
from pozdoc a 
left outer join gestiuni b on b.subunitate=a.subunitate and b.cod_gestiune=a.gestiune
left outer join nomencl n on a.cod=n.cod
where a.subunitate=@Sb and a.tip in ('AI','AP') and (@C35=1 and left(cont_corespondent,2)='35' or @C8=1 and left(cont_corespondent,1)='8') and isnull(n.tip,'') not in ('R','S') and isnull(tip_gestiune,'') not in ('V','I') and (@Cod is null or a.cod=@Cod) and (@Gest is null or a.tert=@Gest) and (@Codi is null or cod_intrare=rtrim(@Codi)) and a.data between @DJPdoc and @DSus and isnull(n.grupa,'') like RTrim(@Grupa) and (@TipStoc='' or @TipStoc='T') and a.cont_corespondent like RTrim(@Cont)+'%'
and (@Loc='' or locatie in ('',@Loc)) and (@LM='' or a.loc_de_munca in ('',@LM)) and (@Com='' or a.comanda in('',@Com))
and (@Cntr='' or (case when a.tip='AP' then a.contract else '' end) in ('',@Cntr))
and (@Lot='' or (case when a.tip='AI' then a.grupa else '' end) in ('',@Lot))
and (@fltGstUt=0 or exists(select 1from @GestUtiliz pr where pr.valoare=a.tert))
and (@eLmUtiliz=0 or 
		exists(select 1from @LMUtiliz pr --inner join personal p on (@sfl=1 or pr.valoare=p.loc_de_munca and p.marca=a.tert)
			where rtrim(pr.valoare) like rtrim(a.loc_de_munca)+'%' and (@sfl=1 or rtrim(pr.marca)=rtrim(a.tert))))
--exec yso_pStocuriDoc @dDataIstoric, @dDataStartPozdoc, @dDataSus, @cCod, @cGestiune, @cCodi, @cGrupa, @TipStoc, @cCont, @Corelatii, @Locatie, @LM, @Comanda, @Contract, @Furnizor, @Lot

insert #doc
select subunitate, gestiune, cont, cod, data, cod_intrare, pret, tip_document, numar_document, cantitate, cantitate_UM2, tip_miscare, in_out,
	(case when tip_document='TE' and rtrim(isnull(contractdinpozdoc_pebune,''))<>'' then contractdinpozdoc_pebune else predator end) predator,	codi_pred, jurnal, tert, serie, pret_cu_amanuntul, tip_gestiune, 
locatie, data_expirarii, TVA_neexigibil, pret_vanzare, accize_cump, loc_de_munca, comanda, [contract], furnizor, lot, numar_pozitie, cont_corespondent, schimb,
subunitate+(case when tip_gestiune in ('F', 'T') then tip_gestiune else 'G' end)+gestiune+cod+cod_intrare,
subunitate+(case when tip_document in ('PF','PI') then 'F' else 'G' end)+convert(char(20), (case when tip_document in ('TI', 'DI', 'PI') or tip_document='AP' and tip_gestiune='T' then predator else gestiune end))+cod+convert(char(20),
	(case when tip_document in ('TI', 'DI', 'PI') or tip_document='AP' and tip_gestiune='T' then codi_pred else cod_intrare end))
from #docstoc

if @Corelatii=0 and (@StocCom=1 or @StocFurn=1 or @StocLot=1 or @SubgestFolLM=1)
begin
	declare @ramase int, @ramaseant int
	set @ramase=isnull((select sum(1) from #doc where (@StocCom=1 and comanda='' or @StocFurn=1 and furnizor='' or @StocLot=1 and lot='' or @SubgestFolLM=1 and tip_gestiune='F' and loc_de_munca='')), 0)
	set @ramaseant=0
	while @ramase>0 and @ramase<>@ramaseant
	begin
		update #doc
		set comanda=(case when d.comanda='' then d1.comanda else d.comanda end),
			furnizor=(case when d.furnizor='' then d1.furnizor else d.furnizor end), 
			lot=(case when d.lot='' then d1.lot else d.lot end),
			loc_de_munca=(case when d.tip_gestiune='F' and d.loc_de_munca='' then d1.loc_de_munca else d.loc_de_munca end)
		from #doc d, (select d2.grp, max(comanda) as comanda, max(furnizor) as furnizor, max(lot) as lot, max(case when tip_gestiune='F' then loc_de_munca else '' end) as loc_de_munca
			from #doc d2 group by d2.grp 
			having (@StocCom=1 and max(comanda)<>'' or @StocFurn=1 and max(furnizor)<>'' or @StocLot=1 and max(lot)<>'' or @SubgestFolLM=1 and max(case when tip_gestiune='F' then loc_de_munca else '' end)<>'')) d1
		where (@StocCom=1 and d.comanda='' or @StocFurn=1 and d.furnizor='' or @StocLot=1 and d.lot='' or @SubgestFolLM=1 and tip_gestiune='F' and d.loc_de_munca='')
		and d.grppred=d1.grp
		
		set @ramaseant=@ramase
		set @ramase=isnull((select sum(1) from #doc where (@StocCom=1 and comanda='' or @StocFurn=1 and furnizor='' or @StocLot=1 and lot='' or @SubgestFolLM=1 and tip_gestiune='F' and loc_de_munca='')), 0)
	end
end

delete #doc
where @Locatie<>'' and locatie<>@Locatie or @LM<>'' and loc_de_munca<>@LM or @Comanda<>'' and comanda<>@Comanda 
or @Contract<>'' and [contract]<>@Contract or @Furnizor<>'' and furnizor<>@Furnizor or @Lot<>'' and lot<>@Lot

--insert @docstoc
select subunitate, gestiune, cont, d.cod, data, data, cod_intrare, pret, tip_document, numar_document, cantitate, cantitate_UM2, tip_miscare, in_out, predator, jurnal, tert, serie, pret_cu_amanuntul, tip_gestiune, 
locatie, data_expirarii, TVA_neexigibil, pret_vanzare, accize_cump, loc_de_munca, comanda, [contract], furnizor, lot, numar_pozitie, cont_corespondent, schimb
from #doc d
--*/
return
end
