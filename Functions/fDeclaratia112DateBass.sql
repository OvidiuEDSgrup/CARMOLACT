--***
Create
function  fDeclaratia112DateBass (@DataJ datetime, @DataS datetime, @oMarca int, @Marca char(6), @Lm char(9), @Strict int, @unSirMarci int, @SirMarci char(200), 
@TagAsigurat char(20))
returns @DateBass table 
(Data datetime, TagAsigurat char(20), Marca char(6), Nume char(50), CNP char(13), Tip_asigurat int, Pensionar int, Tip_contract char(2), 
Total_zile int, Zile_CN int, Zile_CD int, Zile_CS int, TV decimal (10), TVN decimal (10), TVD decimal (10), TVS decimal (10), 
Ore_norma int, IND_CS int, NRZ_CFP int, Venit_fara_CM decimal(10), Venit_total decimal(10), 
Baza_CAS decimal(10), CAS_individual decimal (10), Baza_somaj decimal(10), Somaj_individual decimal(7), Baza_CASS decimal(10), CASS_individual decimal(7))
as
begin
declare @Elite int, @Somesana int, @Pasmatex int, @Salubris int, @Colas int, @STOUG28 int, @ScadOSRN int, @ScadO100RN int, 
@NuCAS_H int, @NuCASS_H int, @ASSImpS_K int, @OreLuna int, @pCASIndiv decimal(4,2), @SalMin decimal(7)
set @Elite=dbo.iauParL('SP','ELITE')
set @Somesana=dbo.iauParL('SP','SOMESANA')
set @Pasmatex=dbo.iauParL('SP','PASMATEX')
set @Salubris=dbo.iauParL('SP','SALUBRIS')
set @Colas=dbo.iauParL('SP','COLAS')
set @STOUG28=dbo.iauParL('PS','STOUG28')
set @ScadOSRN=dbo.iauParL('PS','OSNRN')
set @ScadO100RN=dbo.iauParL('PS','O100NRN')
set @NuCAS_H=dbo.iauParL('PS','NUCAS-H')
set @NuCAS_H=(case when @NuCAS_H=1 and 1=0 then 1 else 0 end)
set @NuCASS_H=dbo.iauParL('PS','NUASS-H')
set @ASSImpS_K=dbo.iauParL('PS','ASSIMPS-K')
set @OreLuna=dbo.iauParLN(@DataS,'PS','ORE_LUNA')
set @pCASIndiv=dbo.iauParLN(@DataS,'PS','CASINDIV')
set @SalMin=dbo.iauParLN(@DataS,'PS','S-MIN-BR')

declare @tmpBass table (Data datetime, TagAsigurat char(20), Marca char(6), Nume char(50), CNP char(13), Tip_asigurat int, Pensionar int, Tip_contract char(2), 
Total_zile int, Zile_CN int, Zile_CD int, Zile_CS int, TV decimal (10), TVN decimal (10), TVD decimal (10), TVS decimal (10), 
Ore_norma int, IND_CS int, NRZ_CFP int, Venit_fara_CM decimal(10), Venit_total decimal(10), 
Baza_CAS decimal(10), CAS_individual decimal (10), Baza_somaj decimal(10), Somaj_individual decimal(7), Baza_CASS decimal(10), CASS_individual decimal(7))

declare @pontajGrpM table
(Data datetime, Marca char(6), Loc_de_munca char(9), Grupa_de_munca char(1), Zile_asigurate int, Zile_CM int)
insert into @pontajGrpM
select dbo.eom(a.data) as Data, a.Marca, a.Loc_de_munca, a.Grupa_de_munca, 
sum(round((a.ore_regie+(case when @Somesana=1 then 0 else a.ore_acord end)+a.ore_concediu_de_odihna+a.ore_obligatii_cetatenesti+
(case when @Pasmatex=0 then a.ore_intrerupere_tehnologica+(case when @Elite=0 and @STOUG28=0 then a.ore else 0 end) else 0 end)-@ScadOSRN*(a.ore_suplimentare_1+a.ore_suplimentare_2+a.ore_suplimentare_3+a.ore_suplimentare_4)
-@ScadO100RN*(a.ore_spor_100)+(case when @Colas=1 then a.spor_cond_8 else 0 end))/a.regim_de_lucru,2)+
(case when @Salubris=1 then round((a.ore_suplimentare_1+a.ore_suplimentare_2-a.ore_suplimentare_3)/a.regim_de_lucru,2) else 0 end)) as Zile_asigurate, 
sum(a.ore_concediu_medical/a.regim_de_lucru) as Zile_CM
from pontaj a
left outer join istpers b on b.Data=@DataS and b.Marca=a.Marca
where a.data between @DataJ and @DataS and (@oMarca=0 or a.Marca=@Marca) and b.grupa_de_munca<>'O' 
and (b.loc_de_munca like rtrim(@Lm)+(case when @Strict=0 then '%' else '' end)) 
and (@unSirMarci=0 or charindex(','+rtrim(ltrim(a.marca))+',',@SirMarci)>0)
group by dbo.eom(a.data), a.Marca, a.Loc_de_munca, a.grupa_de_munca

insert into @tmpBass
select a.Data, ta.TagAsigurat, a.Marca as Marca, a.Nume as Nume, p.cod_numeric_personal as CNP, 
(case when a.Grupa_de_munca in ('N','D','S','C') then 1 when a.Grupa_de_munca in ('P','O') and a.Tip_colab in ('AS2','AS5') then 4 
when a.Grupa_de_munca in ('O') and a.Tip_colab in ('DAC') then 17 when a.Grupa_de_munca in ('O') and a.Tip_colab in ('CCC') then 18 
else 3 end) as Tip_asigurat, 
(case when p.coef_invalid=5 then 1 else 0 end) as Pensionar,
(case when a.Grupa_de_munca in ('N','D','S') then 'N' when a.Grupa_de_munca='C' then 'P'+
rtrim(convert(char(10),isnull((select max(d.spor_cond_10) from brut d where d.data=@DataS and d.marca=a.marca),8))) 
else 'N' end) as Tip_contract, 
isnull((select sum(b.Zile_asigurate+b.Zile_CM) from @pontajGrpM b where b.data=a.Data and b.marca=a.marca),0) as TT, 
isnull((select sum(b.Zile_asigurate) from @pontajGrpM b where b.data=a.Data and b.Grupa_de_munca='N' and b.marca=a.marca),0) as NN,
isnull((select sum(b.Zile_asigurate) from @pontajGrpM b where b.data=a.Data and b.Grupa_de_munca='D' and b.marca=a.marca),0) as DD,
isnull((select sum(b.Zile_asigurate) from @pontajGrpM b where b.data=a.Data and b.Grupa_de_munca='S' and b.marca=a.marca),0) as SS,
isnull((select sum(c.venit_cond_normale+c.venit_cond_deosebite+c.venit_cond_speciale- @NuCAS_H*c.suma_impozabila-(case when i.grupa_de_munca<>'P' then @ASSImpS_K*c.cons_admin else 0 end)-(c.ind_c_medical_unitate+c.ind_c_medical_cas+c.CMCAS+c.CMunitate+ c.spor_cond_9)-@STOUG28*round(c.Ind_invoiri,0)) from brut c, istpers i where c.data=@DataS and c.marca=a.marca and c.data=i.data and c.marca=i.marca),0) as TV, 
isnull((select sum(c.venit_cond_normale) from brut c where c.data=@DataS and c.marca=a.marca),0)-isnull((select sum(g.ind_c_medical_unitate+g.ind_c_medical_cas+g.CMCAS+g.CMunitate-@NuCAS_H*g.suma_impozabila+(case when i.grupa_de_munca<>'P' then @ASSImpS_K*g.cons_admin else 0 end)+g.spor_cond_9+@STOUG28*round(g.Ind_invoiri,0)) 
from brut g
left outer join @pontajGrpM f on g.data=f.data and g.marca=f.marca and g.loc_de_munca = f.loc_de_munca and f.grupa_de_munca='N'
left outer join istpers i on g.data=i.data and g.marca=i.marca
where g.data=@DataS and g.marca=a.marca and f.grupa_de_munca='N'),0) - isnull((select sum(g.ind_c_medical_unitate+g.ind_c_medical_cas+g.CMCAS+g.CMunitate+g.spor_cond_9-@NuCAS_H*g.suma_impozabila+@ASSImpS_K*g.cons_admin+ @STOUG28*round(g.Ind_invoiri,0)) from brut g where g.data=@DataS and g.marca=a.marca and a.grupa_de_munca='N' and g.loc_de_munca not in (select loc_de_munca from pontaj t where g.marca=t.marca and t.data between @DataJ and @DataS)),0) as TVN, 
isnull((select sum (c.venit_cond_deosebite) from brut c where c.data=@DataS and c.marca=a.marca),0)-isnull((select sum(g.ind_c_medical_unitate+ g.ind_c_medical_cas+g.CMCAS+g.CMunitate-@NuCAS_H*g.suma_impozabila+@ASSImpS_K*g.cons_admin+g.spor_cond_9+ @STOUG28*round(g.Ind_invoiri,0)) 
from brut g 
left outer join @pontajGrpM f on g.data=f.data and g.marca=f.marca and g.loc_de_munca=f.loc_de_munca and f.grupa_de_munca='D' 
where g.data=@DataS and g.marca=a.marca and f.grupa_de_munca='D'),0) - isnull((select sum(g.ind_c_medical_unitate+g.ind_c_medical_cas+g.CMCAS+g.CMunitate-@NuCAS_H*g.suma_impozabila +@ASSImpS_K*g.cons_admin+g.spor_cond_9+ @STOUG28*round(g.Ind_invoiri,0)) from brut g where g.data=@DataS and g.marca=a.marca and a.grupa_de_munca='D' and g.loc_de_munca not in (select loc_de_munca from pontaj t where g.marca=t.marca and t.data between @DataJ and @DataS)),0) as TVD, 
isnull((select sum(c.venit_cond_speciale) from brut c where c.data=@DataS and c.marca=a.marca),0) - isnull((select sum(g.ind_c_medical_unitate+g.ind_c_medical_cas+g.CMCAS+g.CMunitate-@NuCAS_H*g.suma_impozabila+@ASSImpS_K*g.cons_admin+g.spor_cond_9+ @STOUG28*round(g.Ind_invoiri,0)) 
from brut g 
left outer join @pontajGrpM f on g.data=f.data and g.marca=f.marca and g.loc_de_munca=f.loc_de_munca and f.grupa_de_munca='S'
where g.data=@DataS and g.marca=a.marca and f.grupa_de_munca='S'),0)-isnull((select sum(g.ind_c_medical_unitate+g.ind_c_medical_cas+g.CMCAS+g.CMunitate- @NuCAS_H*g.suma_impozabila+@ASSImpS_K*g.cons_admin +g.spor_cond_9+ @STOUG28*round(g.Ind_invoiri,0)) from brut g where g.data=@DataS and g.marca=a.marca and a.grupa_de_munca='S' and g.loc_de_munca not in (select loc_de_munca from pontaj t where g.marca=t.marca and t.data between @DataJ and @DataS)),0) as TVS, 
(case when a.Grupa_de_munca in ('C','O') then 8 else isnull((select (case when max(d.spor_cond_10)>8 or max(d.spor_cond_10)=0 or a.grupa_de_munca='P' then 8 else max(d.spor_cond_10) end) from brut d where d.data=@DataS and d.marca=a.marca),8) end) as NORMA, 
(case when a.grupa_de_munca='S' then isnull((select top 1 convert(int,val_inf) from extinfop x where x.marca=a.marca and x.cod_inf='INDCS' and x.data_inf<=@DataS order by x.data_inf desc),0) else 0 end) as IND_CS, 0 as NRZ_CFP, 
b.Venit_total, b.Venit_total-(b.Indemniz_angajator+b.Indemniz_fnuass+b.Indemniz_faambp), 
n.Baza_CAS, n.pensie_suplimentara_3 - isnull((select round(convert(float,@SalMin)*sum(m.zile_lucratoare)/max(m.zile_lucratoare_in_luna)*@pCASIndiv/100,0) from conmed m where year(m.data)>=2006 and m.data=@DataS and m.data_inceput<@DataJ and m.marca=a.marca and (m.tip_diagnostic not in ('2-','3-','4-','0-') and (m.tip_diagnostic<>'10' and m.tip_diagnostic<>'11' or m.suma<>1))),0) as CAS_individual, 
n.Asig_sanatate_din_cas, n.Somaj_1, (case when n.asig_sanatate_pl_unitate<>0 then b.venit_total-(b.Indemniz_Fnuass+b.Indemniz_Faambp+b.CMCAS)-1*(b.Indemniz_angajator+b.CMunitate)-@NuCASS_H*b.suma_impozabila-(case when @STOUG28=1 then b.Somaj_tehnic else 0 end) else 0 end) as Baza_CASS, 
n.Asig_sanatate_din_net
from istpers a 
left outer join personal p on a.marca=p.marca 
left outer join infopers i on i.marca=a.marca 
left outer join net n on n.data=a.data and n.marca=a.marca
left outer join (select data, marca, sum(venit_total) as venit_total, sum(ind_c_medical_unitate) as Indemniz_angajator, 
sum(ind_c_medical_cas) as Indemniz_fnuass, sum(spor_cond_9) as Indemniz_faambp, sum(Ind_invoiri) as Somaj_tehnic, 
sum(CMCas) as CMCas, sum(CMunitate) as CMunitate, sum(suma_impozabila) as suma_impozabila, max(spor_cond_10) as RegimL 
from brut where data=@DataS group by data, marca) b on a.data=b.data and a.marca=b.marca
left outer join dbo.fDeclaratia112TagAsigurat (@DataJ, @DataS) ta on a.data=ta.data and a.marca=ta.marca
where a.data=@DataS and (@oMarca=0 or a.Marca=@Marca) and a.grupa_de_munca<>'O' 
and (@Lm='' or a.loc_de_munca like rtrim(@Lm)+(case when @Strict=0 then '%' else '' end)) 
and (@unSirMarci=0 or charindex(','+rtrim(ltrim(a.marca))+',',@SirMarci)>0)
and (@TagAsigurat='' or @TagAsigurat like rtrim(ta.TagAsigurat)+'%')
order by Marca

insert into @DateBass
select Data, max(TagAsigurat), max(Marca), max(Nume), CNP, max(Tip_asigurat), max(Pensionar), max(Tip_contract), 
max(Total_zile), max(Zile_CN), max(Zile_CD), max(Zile_CS), sum(TV), sum(TVN), sum(TVD), sum(TVS), max(Ore_norma), 
max(IND_CS), max(NRZ_CFP), sum(Venit_fara_CM), sum(Venit_total), sum(Baza_CAS), sum(CAS_individual), sum(Baza_somaj), 
sum(Somaj_individual), sum(Baza_CASS), sum(CASS_individual)
from @tmpBass
group by Data, CNP

return
end

/*
select * from fDeclaratia112DateBass ('12/01/2009', '12/31/2009', 0, '', '', 0, 0, '', '')
*/