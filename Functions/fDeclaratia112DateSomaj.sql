--***
Create
function fDeclaratia112DateSomaj (@DataJ datetime, @DataS datetime, @oMarca int, @Marca char(6), @Lm char(9), @Strict int, @unSirMarci int, @SirMarci char(200), 
@TagAsigurat char(20))
returns @DateSomaj table 
(Data datetime, TagAsigurat char(20), Marca char(6), Nume char(50), CNP char(13), Tip_asigurat int, Pensionar int, Tip_contract char(2), 
Ore_norma int, Norma_luna int, Zile_lucrate int, Ore_lucrate int, Zile_suspendate int, Ore_suspendate int, 
Baza_somaj decimal(10), Somaj_individual decimal(7), TA int, OreSST int, ZileSST int, BazaST int, TASCA int, 
Venit_total decimal(10), Baza_CAS decimal(10), CAS_individual decimal (10), Baza_CASS decimal(10), CASS_individual decimal(7))
as
begin
declare @Bugetari int, @InstPubl int, @STOUG28 int, @ScadOSRN int, @ScadO100RN int, @NuCASS_H int, 
@Elite int, @Somesana int, @Pasmatex int, @Salubris int, @Colas int, @OreLuna int, @pCASIndiv decimal(4,2), @SalMin decimal(7)
set @Bugetari=dbo.iauParL('SP','UNITBUGET')
set @InstPubl=dbo.iauParL('SP','INSTPUBL')
set @STOUG28=dbo.iauParL('PS','STOUG28')
set @ScadOSRN=dbo.iauParL('PS','OSNRN')
set @ScadO100RN=dbo.iauParL('PS','O100NRN')
set @Elite=dbo.iauParL('SP','ELITE')
set @Somesana=dbo.iauParL('SP','SOMESANA')
set @Pasmatex=dbo.iauParL('SP','PASMATEX')
set @Salubris=dbo.iauParL('SP','SALUBRIS')
set @Colas=dbo.iauParL('SP','COLAS')
set @OreLuna=dbo.iauParLN(@DataS,'PS','ORE_LUNA')
set @SalMin=dbo.iauParLN(@DataS,'PS','S-MIN-BR')

declare @pontajMarca table
(Data datetime, Marca char(6), RegimLucru decimal(5,2), Zile_lucrate int, Ore_lucrate int, Zile_suspendate int, Ore_suspendate int, 
OreSST int, ZileSST int, SB int)
insert into @pontajMarca
select dbo.eom(a.Data) as Data, a.marca, (case when max(a.Regim_de_lucru)=0 then 8 else max(a.Regim_de_lucru) end), 
(sum(round((a.ore_regie+(case when @Somesana=1 then 0 else a.ore_acord end)+a.ore_concediu_de_odihna+a.ore_obligatii_cetatenesti+ 
(case when @Pasmatex=0 then a.ore_intrerupere_tehnologica+(case when @Elite=0 and @STOUG28=0 then a.ore else 0 end) else 0 end)+(case when @Colas=1 then a.spor_cond_8 else 0 end)
-@ScadOSRN*(a.ore_suplimentare_1+a.ore_suplimentare_2+a.ore_suplimentare_3+a.ore_suplimentare_4)-@ScadO100RN*(a.ore_spor_100) +@Salubris*(ore_suplimentare_1+ore_suplimentare_2-ore_suplimentare_3))/a.regim_de_lucru,2,3))) 
+max(isnull(cm.ZileCM_angajator,0)) as Zile_lucrate, 
(sum(round((a.ore_regie+(case when @Somesana=1 then 0 else a.ore_acord end)+a.ore_concediu_de_odihna+a.ore_obligatii_cetatenesti+ 
(case when @Pasmatex=0 then a.ore_intrerupere_tehnologica+(case when @Elite=0 and @STOUG28=0 then a.ore else 0 end) else 0 end)+(case when @Colas=1 then a.spor_cond_8 else 0 end)
-@ScadOSRN*(a.ore_suplimentare_1+a.ore_suplimentare_2+a.ore_suplimentare_3+a.ore_suplimentare_4)-@ScadO100RN*(a.ore_spor_100) +@Salubris*(ore_suplimentare_1+ore_suplimentare_2-ore_suplimentare_3)),3,3))) 
+max(isnull(cm.ZileCM_angajator,0))*max(a.regim_de_lucru) as Ore_lucrate, 
(sum(round((a.ore_concediu_fara_salar+a.ore_nemotivate+a.ore_invoiri+(case when @STOUG28=1 then a.ore else 0 end))/(case when a.regim_de_lucru=0 then 8 else a.regim_de_lucru end),2)))+
max(isnull(cm.ZileCM_fonduri,0)) as Zile_suspendate, 
(sum(round((a.ore_concediu_fara_salar+a.ore_nemotivate+a.ore_invoiri+(case when @STOUG28=1 then a.ore else 0 end)),3)))+
max(isnull(cm.ZileCM_fonduri,0)) *max(a.regim_de_lucru) as Ore_suspendate, 
(case when @STOUG28=1 then sum(a.ore) else 0 end) as OreSST, 
(case when @STOUG28=1 then sum(a.ore/a.regim_de_lucru) else 0 end) as ZileSST, 
(case when @STOUG28=1 then round(@SalMin*sum(a.ore/a.regim_de_lucru)/(@OreLuna/8),0) else 0 end) as SB
from pontaj a
left outer join net n on n.data=dbo.eom(a.Data) and a.marca=n.marca
left outer join Personal p on a.marca=p.marca
left outer join istPers i on i.data=dbo.eom(a.Data) and a.marca=i.marca
left outer join (select data, marca, sum(Zile_cu_reducere) as ZileCM_angajator, sum(Zile_lucratoare-Zile_cu_reducere) as ZileCM_fonduri from conmed 
where data between @DataJ and @DataS group by data, marca) cm on cm.Data=a.Data and cm.Marca=a.Marca
left outer join dbo.fDeclaratia112TagAsigurat (@DataJ, @DataS) ta on a.data=ta.data and a.marca=ta.marca
where a.data between @DataJ and @DataS and (@oMarca=0 or a.marca=@Marca)  
and (@Lm='' or i.loc_de_munca like rtrim(@Lm)+(case when @Strict=0 then '%' else '' end)) 
and (n.somaj_1>0 or p.coef_invalid<>5 and p.somaj_1<>0 and 0=0 and a.marca not in (select m.marca from conmed m where m.data=@DataS and m.tip_diagnostic='0-')) 
and (@unSirMarci=0 or charindex(','+rtrim(ltrim(a.marca))+',',@SirMarci)>0)
and (@TagAsigurat='' or @TagAsigurat like rtrim(ta.TagAsigurat)+'%')
group by dbo.eom(a.Data), a.Marca
order by dbo.eom(a.Data), a.Marca

insert @DateSomaj
select a.Data, max(ta.TagAsigurat), max(a.Marca) as Marca, max(a.Nume) as Nume, p.cod_numeric_personal as CNP, 
(case when a.Grupa_de_munca in ('N','D','S','C') then 1 when a.Grupa_de_munca in ('P','O') and a.Tip_colab in ('AS2','AS5') then 4 
when a.Grupa_de_munca in ('O') and a.Tip_colab in ('DAC') then 17 when a.Grupa_de_munca in ('O') and a.Tip_colab in ('CCC') then 18 
else 3 end) as Tip_asigurat, 
max((case when p.coef_invalid=5 then 1 else 0 end)) as Pensionar,
(case when a.Grupa_de_munca in ('N','D','S') then 'N' when a.Grupa_de_munca='C' then 'P'
+rtrim(convert(char(5),convert(int,isnull(pm.RegimLucru,8)))) else 'N' end) as Tip_contract, 
max(pm.RegimLucru) as Ore_norma, 
round((case when max(isnull(pm.RegimLucru,0))=0 then 8 else max(isnull(pm.RegimLucru,0)) end)*(case when max(a.Data)<@DataS then (case when dbo.iauParLN(max(a.Data),'PS','ORE_LUNA')=0 then dbo.Zile_lucratoare(dbo.bom(max(a.Data)),max(a.Data))*8 else dbo.iauParLN(max(a.Data),'PS','ORE_LUNA') end) else @OreLuna end)/8,0) as Norma_luna, 
sum(isnull(pm.Zile_lucrate,0)) as Zile_lucrate, sum(isnull(pm.Ore_lucrate,0)) as Ore_lucrate, sum(isnull(pm.Zile_suspendate,0)) as Zile_suspendate, sum(isnull(pm.Ore_suspendate,0)) as Ore_suspendate, 
sum(n.asig_sanatate_din_CAS) as Baza_somaj, sum(n.somaj_1) as Somaj_individual, (case when @InstPubl=1 then 2 else 1 end) as TA, 
sum(isnull(pm.OreSST,0)) as OreSST, sum(isnull(pm.ZileSST,0)) as ZileSST, sum(isnull(pm.SB,0)) as SB, 
(case when max(isnull(s.Marca,''))<>'' then 2 else 1 end) as TASCA, 
sum(b.Venit_total-(b.Indemniz_angajator+b.Indemniz_fnuass+b.Indemniz_faambp)), sum(n.Baza_CAS), sum(n.pensie_suplimentara_3) - isnull((select round(convert(float,@SalMin)*sum(m.zile_lucratoare)/max(m.zile_lucratoare_in_luna)*@pCASIndiv/100,0) from conmed m where m.data=@DataS and m.data_inceput<@DataJ and m.marca=max(a.marca) and (m.tip_diagnostic not in ('2-','3-','4-','0-') and (m.tip_diagnostic<>'10' and m.tip_diagnostic<>'11' or m.suma<>1))),0) as CAS_individual, 
sum((case when n.asig_sanatate_pl_unitate<>0 then b.venit_total-(b.Indemniz_Fnuass+b.Indemniz_Faambp+b.CMCAS)-1*(b.Indemniz_angajator+b.CMunitate)-@NuCASS_H*b.suma_impozabila-(case when @STOUG28=1 then b.Somaj_tehnic else 0 end) else 0 end)) as Baza_CASS, 
sum(n.Asig_sanatate_din_net)
from istpers a
left outer join net n on a.marca=n.marca and a.data=n.data
left outer join personal p on a.marca=p.marca
left outer join infopers f on a.marca=f.marca
left outer join dbo.fPSScutiriOUG13 (@DataJ, @DataS, @oMarca, @Marca, @Lm, @Strict) s on s.data=a.data and s.marca=a.marca
left outer join @pontajMarca pm on a.data=pm.data and a.marca=pm.marca 
left outer join (select data, marca, sum(venit_total) as venit_total, sum(ind_c_medical_unitate) as Indemniz_angajator, 
sum(ind_c_medical_cas) as Indemniz_fnuass, sum(spor_cond_9) as Indemniz_faambp, sum(Ind_invoiri) as Somaj_tehnic, 
sum(CMCas) as CMCas, sum(CMunitate) as CMunitate, sum(suma_impozabila) as suma_impozabila, max(spor_cond_10) as RegimL 
from brut where data=@DataS group by data, marca) b on a.data=b.data and a.marca=b.marca
left outer join dbo.fDeclaratia112TagAsigurat (@DataJ, @DataS) ta on a.data=ta.data and a.marca=ta.marca
where a.data between @DataJ and @DataS and (@oMarca=0 or a.marca=@Marca) 
and (@Lm='' or a.loc_de_munca like rtrim(@Lm)+(case when @Strict=0 then '%' else '' end))
--and (n.somaj_1>0 or p.coef_invalid<>5 and p.somaj_1<>0 and a.marca not in (select m.marca from conmed m where m.data=@DataS and m.tip_diagnostic='0-')) 
and (@unSirMarci=0 or charindex(','+rtrim(ltrim(a.marca))+',',@SirMarci)>0)
and (@TagAsigurat='' or ta.TagAsigurat=@TagAsigurat)
Group by a.Data, p.cod_numeric_personal, 
(case when a.Grupa_de_munca in ('N','D','S','C') then 1 when a.Grupa_de_munca in ('P','O') and a.Tip_colab in ('AS2','AS5') then 4 
when a.Grupa_de_munca in ('O') and a.Tip_colab in ('DAC') then 17 when a.Grupa_de_munca in ('O') and a.Tip_colab in ('CCC') then 18 
else 3 end), 
(case when a.Grupa_de_munca in ('N','D','S') then 'N' when a.Grupa_de_munca='C' then 'P'
+rtrim(convert(char(5),convert(int,isnull(pm.RegimLucru,8)))) else 'N' end)

update @DateSomaj Set Ore_Lucrate=(case when Ore_lucrate>Norma_luna then Norma_luna else Ore_lucrate end)

return
end

/*
select * from fDeclaratia112DateSomaj ('08/01/2010', '08/31/2010', 0, '', '', 0, 0, '', 'asiguratB')
*/