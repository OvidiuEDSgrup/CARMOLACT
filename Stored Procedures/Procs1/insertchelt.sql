--***
create procedure insertchelt @dDataJos datetime,@dDataSus datetime
as
declare @cArtC char(13),@cArtS char(13),@cArtX char(13),@dDataLT datetime
declare @cArtD char(13),@cArtA char(13),@lCuPct int,@lArd int,@subunitate char(9)
declare @nLM int,@nFetch int,@cCod char(20),@nStocInit float,@nCantitate float,@nConsCurent float,@lmT int
declare @cLm char(13),@cCom char(13),@cLMI char(13),@cComI char(13),@nPretLT float,@bucla int, @cContVenExcept char(20)
select @cArtC=isnull((select val_alfanumerica from par where tip_parametru='PC' and parametru='ARTCALC'),'FT'),
@cArtS=isnull((select val_alfanumerica from par where tip_parametru='PC' and parametru='ARTCALS'),'FX'),
@cArtX=isnull((select val_alfanumerica from par where tip_parametru='PC' and parametru='ARTCALX'),'FX'),
@cArtD=isnull((select val_alfanumerica from par where tip_parametru='PC' and parametru='CHADMIN'),''),
@cArtA=isnull((select val_alfanumerica from par where tip_parametru='PC' and parametru='CHDESFAC'),''),
@lCuPct=isnull((select val_logica from par where tip_parametru='PC' and parametru='COMPCT'),0),
@lmT=isnull((select val_logica from par where tip_parametru='PC' and parametru='INLOCLMT'),0),
@nLm=isnull((select max(lungime) from strlm where costuri=1),0),
@lArd=isnull((select val_logica from par where tip_parametru='SP' and parametru='ARDEALUL'),0),
@dDataLT=dateadd(day,-1,@dDataJos),
@subunitate=(select val_alfanumerica from par where tip_parametru='GE' and parametru='SUBPRO'), 
@cContVenExcept=isnull((select val_alfanumerica from par where tip_parametru='PC' and parametru='CVENEXCEP'),'')

	exec fainregistraricontabile @dinTabela=1,@dataSus=@dDataSus

truncate table costtmp
--Temp pt com specif
select * into ##tmppincon 
from pozincon
WHERE data between @dDataJos and @dDataSus and (exists (select 1 from conturi where POZINCON.CONT_DEBITOR=CONTURI.CONT and CONTURI.LOGIC=1 AND CONTURI.ARTICOL_DE_CALCULATIE NOT IN (rtrim(@cArtA),rtrim(@cArtD))) or explicatii like 'Costuri: %' and cont_debitor like '711%')
delete from ##tmppincon where exists (select * from ##tmppincon t where t.loc_de_munca=##tmppincon.loc_de_munca and t.comanda=##tmppincon.comanda and t.data between @dDataJos and @dDataSus group by t.loc_de_munca,t.comanda having abs(sum(t.suma))<=0.01)

--Comanda asociata lm 
if 1=1 -- de regula se completeaza automat daca nu este completata
	update ##tmppincon set comanda=left(speciflm.comanda,20)
	from speciflm where ##tmppincon.loc_de_munca=speciflm.LOC_DE_MUNCA and ##tmppincon.comanda=''
else --la G7 se suprascrie
	update ##tmppincon set comanda=left(speciflm.comanda,20)
	from speciflm where ##tmppincon.loc_de_munca=speciflm.LOC_DE_MUNCA and speciflm.comanda<>'' --and ##tmppincon.comanda=''

--CHELT DIR
insert into costtmp (DATA,LM_SUP,COMANDA_SUP,ART_SUP,LM_INF,COMANDA_INF,ART_INF,CANTITATE,VALOARE,PARCURS,Tip,Numar)
SELECT DATA,LEFT(LOC_DE_MUNCA,@nLm) AS LM_SUP,(case when patindex('%/%/%',comanda)>0 and 1=0 then '' else COMANDA end) AS COMANDA_SUP,'T' AS ART_SUP,' ' AS LM_INF,CONT_DEBITOR AS COMANDA_INF,
(case when explicatii like 'Costuri: %' and cont_debitor like '711%' then '98' else CONTURI.ARTICOL_DE_CALCULATIE end) AS ART_INF,1 AS CANTITATE,sum(SUMA) AS VALOARE,0 AS PARCURS,TIP_DOCUMENT,NUMAR_DOCUMENT
FROM ##tmpPINCON,CONTURI
where CONT_DEBITOR=CONTURI.CONT
group by DATA,LEFT(LOC_DE_MUNCA,@nLm),(case when patindex('%/%/%',comanda)>0 and 1=0 then '' else COMANDA end),
CONT_DEBITOR,(case when explicatii like 'Costuri: %' and cont_debitor like '711%' then '98' else CONTURI.ARTICOL_DE_CALCULATIE end),TIP_DOCUMENT,NUMAR_DOCUMENT
having ABS(sum(suma))>=0.01

if @lmT=1 update costtmp set lm_sup=left(comenzi.loc_de_munca,@nLm) from comenzi where costtmp.comanda_sup=comenzi.comanda and comenzi.tip_comanda='T' and comenzi.loc_de_munca<>'' and lm_sup<>left(comenzi.loc_de_munca,@nLm)
and comenzi.subunitate = @subunitate
drop table ##tmppincon
--Neterminata
insert into costtmp (DATA,LM_SUP,COMANDA_SUP,ART_SUP,LM_INF,COMANDA_INF,ART_INF,CANTITATE,VALOARE,PARCURS,Tip,Numar)
SELECT @dDataJos,LEFT(LOC_DE_MUNCA,@nLm),COMANDA,'T',LEFT(LOC_DE_MUNCA,@nLm),comanda,'N'
,1,sum(VALOARE),0,'SI','0'
FROM cost WHERE data_lunii=dateadd(day,-1,@dDataJos) and tip_inregistrare='SI'
group by LEFT(LOC_DE_MUNCA,@nLm),comanda
--DECONTARI AUXILIARE din tabela de decontari
INSERT INTO COSTTMP (DATA,LM_SUP,COMANDA_SUP,ART_SUP,LM_INF,COMANDA_INF,ART_INF,CANTITATE,VALOARE,PARCURS,Tip,Numar)
SELECT DATA,LEFT(LOC_DE_MUNCA_BENEFICIAR,@nLm),COMANDA_BENEFICIAR,ARTICOL_DE_CALCULATIE_BENEF,LEFT(L_M_FURNIZOR,@nLm),COMANDA_FURNIZOR,'T',CANTITATE,0,0,'DX',NUMAR_DOCUMENT
 FROM DECAUX where data between @dDataJos and @dDataSus
--Trebuie buclate auxiliarele deoarece directele pot veni tot de aici
set @bucla=1
while @bucla>0
begin
 insert into costtmp (DATA,LM_SUP,COMANDA_SUP,ART_SUP,LM_INF,COMANDA_INF,ART_INF,CANTITATE,VALOARE,PARCURS,Tip,Numar)
 select distinct @dDataSus,LEFT(LOC_DE_MUNCA_beneficiar,@nLm),comanda_beneficiar,(case when art_calc_benef='' then @cArtX else art_calc_benef end), lm_sup,comanda_sup,'T',1,0,0,'DA','' 
 from costtmp t1,comenzi
 where t1.COMANDA_inf<>'' and (comenzi.tip_comanda='X' or LOC_DE_MUNCA_beneficiar<>'' /*and comanda_beneficiar<>''*/) and t1.comanda_sup=comenzi.comanda and comenzi.tip_comanda in ('T','X') 
	and comenzi.subunitate = @subunitate and not exists (select * from costtmp t2 where t1.lm_sup=t2.lm_inf and t1.comanda_sup=t2.comanda_inf and t2.art_inf<>'N')
 set @bucla=@@rowcount
end
--Completare comenzi atasate locuri de munca
--PP PROD FIN SI SEMIFABR
INSERT INTO COSTTMP (DATA,LM_SUP,COMANDA_SUP,ART_SUP,LM_INF,COMANDA_INF,ART_INF,CANTITATE,VALOARE,PARCURS,Tip,Numar)
SELECT DATA,(CASE WHEN @lArd=1 and CONT_DE_STOC='346' THEN POZDOC.LOC_DE_MUNCA ELSE '' END),(CASE WHEN @lArd=1 and CONT_DE_STOC='346' THEN POZDOC.COMANDA ELSE '' END),
(case when @lArd=1 and CONT_DE_STOC='346' THEN '6' when comenzi.tip_comanda='S' then 'S' else 'P' end),(CASE WHEN @lArd=1 and CONT_DE_STOC='346' THEN '' ELSE LEFT(pozdoc.LOC_DE_MUNCA,@nLm) END),(CASE WHEN @lArd=1 and CONT_DE_STOC='346' THEN '711' ELSE pozdoc.COMANDA END),'T',sum(pozdoc.CANTITATE),
(CASE WHEN @lArd=1 and CONT_DE_STOC='346' THEN -1*sum(cantitate*pret_de_stoc)/sum(cantitate) ELSE 0 END),0,'PP',NUMAR
FROM POZDOC,comenzi WHERE comenzi.comanda=pozdoc.comanda and comenzi.tip_comanda in ('P','R','S','A') and
comenzi.subunitate = @subunitate and TIP='PP' and data between @dDataJos and @dDataSus
group by DATA,(CASE WHEN @lArd=1 and CONT_DE_STOC='346' THEN POZDOC.LOC_DE_MUNCA ELSE '' END),
(CASE WHEN @lArd=1 and CONT_DE_STOC='346' THEN POZDOC.COMANDA ELSE '' END),
(case when @lArd=1 and CONT_DE_STOC='346' THEN '6' when comenzi.tip_comanda='S' then 'S' else 'P' end),
(CASE WHEN @lArd=1 and CONT_DE_STOC='346' THEN '' ELSE LEFT(pozdoc.LOC_DE_MUNCA,@nLm) END),
(CASE WHEN @lArd=1 and CONT_DE_STOC='346' THEN '711' ELSE pozdoc.COMANDA END),pozdoc.cont_de_Stoc,NUMAR
--PP PROD PT PROD CUPLATA
INSERT INTO COSTTMP (DATA,LM_SUP,COMANDA_SUP,ART_SUP,LM_INF,COMANDA_INF,ART_INF,CANTITATE,VALOARE,PARCURS,Tip,Numar)
SELECT DATA,'','',
(case when cont_de_stoc like '345%' then 'P' else 'S' end),LEFT(POZDOC.LOC_DE_MUNCA,@nLm),left(pozdoc.COD,13),'T',pozdoc.CANTITATE,0,0,'PC',NUMAR
FROM POZDOC,comenzi WHERE comenzi.comanda=pozdoc.comanda and comenzi.tip_comanda='C' and
comenzi.subunitate = @subunitate and TIP='PP' and data between @dDataJos and @dDataSus
--Dec.pond.
INSERT INTO COSTTMP (DATA,LM_SUP,COMANDA_SUP,ART_SUP,LM_INF,COMANDA_INF,ART_INF,CANTITATE,VALOARE,PARCURS,Tip,Numar)
SELECT DATA,loc_benef,comanda_benef,
@cArtC,loc_furn,comanda_furn,'T',pozdoc.CANTITATE*ponderi.pondere,0,0,'DP',NUMAR
FROM POZDOC,comenzi,ponderi WHERE comenzi.comanda=pozdoc.comanda and comenzi.tip_comanda='C' and
LEFT(pozdoc.LOC_DE_MUNCA,@nLm)=ponderi.loc_furn and pozdoc.comanda=ponderi.comanda_furn and pozdoc.cod=ponderi.comanda_benef and pozdoc.TIP='PP' and data between @dDataJos and @dDataSus and comenzi.subunitate = @subunitate

exec insertSemif @dDataJos,@dDataSus

INSERT INTO COSTTMP (DATA,LM_SUP,COMANDA_SUP,ART_SUP,LM_INF,COMANDA_INF,ART_INF,CANTITATE,VALOARE,PARCURS,Tip,Numar)
SELECT pozdoc.DATA,'','','R',LEFT(POZDOC.LOC_DE_MUNCA,@nLm),POZDOC.COMANDA,'T',sum(abs(POZDOC.CANTITATE)),0,0,'AS',NUMAR
FROM POZDOC,COMENZI WHERE
POZDOC.TIP='AS' and LEFT(POZDOC.LOC_DE_MUNCA,@nLm)<>'' and pozdoc.comanda<>'' and POZDOC.COMANDA=COMENZI.COMANDA AND COMENZI.TIP_COMANDA='R' AND POZDOC.data between @dDataJos and @dDataSus and comenzi.subunitate = @subunitate
group by lefT(pozdoc.loc_de_munca,@nLm),pozdoc.comanda,pozdoc.data,NUMAR

INSERT INTO COSTTMP (DATA,LM_SUP,COMANDA_SUP,ART_SUP,LM_INF,COMANDA_INF,ART_INF,CANTITATE,VALOARE,PARCURS,Tip,Numar)
SELECT pozincon.DATA,'','','R',LEFT(pozincon.LOC_de_MUNCA,@nLm),pozincon.COMANDA,'T',1,0,0,pozincon.tip_document,NUMAR_document
FROM pozincon,COMENZI 
WHERE
pozincon.tip_document in ('NC','PI') and LEFT(pozincon.LOC_de_MUNCA,@nLm)<>'' and pozincon.comanda<>'' 
and pozincon.COMANDA=COMENZI.COMANDA AND COMENZI.TIP_COMANDA='R' and pozincon.cont_creditor like '70%' and pozincon.cont_creditor not like rtrim(@cContVenExcept)+'%' 
and comenzi.subunitate = @subunitate
AND pozincon.data between @dDataJos and @dDataSus
group by lefT(pozincon.loc_de_munca,@nLm),pozincon.comanda,pozincon.data,pozincon.tip_document,NUMAR_document

INSERT INTO COSTTMP (DATA,LM_SUP,COMANDA_SUP,ART_SUP,LM_INF,COMANDA_INF,ART_INF,CANTITATE,VALOARE,PARCURS,Tip,Numar)
SELECT DATA,'','','N',LEFT(nete.LOC_DE_MUNCA,@nLm),
(case when isnull(c.tip_comanda,'')='X' and c.comanda_beneficiar<>'' then c.comanda_beneficiar else nete.comanda end),
'T',CANTITATE*procent/100,VALOARE*procent/100,0,'NI',
(case when isnull(c.tip_comanda,'')='X' and c.comanda_beneficiar<>'' then left(nete.comanda,13) else '' end)
FROM nete
left join comenzi c on c.subunitate=@subunitate and c.comanda=nete.comanda
where data between @dDataJos and @dDataSus and abs(cantitate)>0.001
-- Pentru neterm cu cantitate=0 -> procent echivalent
INSERT INTO COSTTMP (DATA,LM_SUP,COMANDA_SUP,ART_SUP,LM_INF,COMANDA_INF,ART_INF,CANTITATE,VALOARE,PARCURS,Tip,Numar)
SELECT @dDataSus,'','','N',tblsumanete.lm,tblsumanete.COMANDA,'T',tblsumanete.CANTITATE*(100/procent-1),0,0,'NI',(case when isnull(c.tip_comanda,'')='X' and c.comanda_beneficiar<>'' then left(nete.comanda,13) else '' end)
FROM nete
left join comenzi c on c.subunitate=@subunitate and c.comanda=nete.comanda
inner join
(select lm_inf as lm,comanda_inf as comanda,sum(cantitate) as cantitate from costtmp
where lm_sup='' and comanda_sup='' and art_sup<>'N'
	and exists (select 1 from nete ne left join comenzi cn on cn.subunitate=@subunitate and cn.comanda=ne.comanda
	where lm_inf=ne.loc_de_munca and comanda_inf=(case when isnull(cn.tip_comanda,'')='X' and cn.comanda_beneficiar<>'' then cn.comanda_beneficiar else ne.comanda end) and ne.cantitate=0)
group by lm_inf,comanda_inf) as tblsumanete on tblsumanete.lm=nete.loc_de_munca and tblsumanete.comanda=(case when isnull(c.tip_comanda,'')='X' and c.comanda_beneficiar<>'' then c.comanda_beneficiar else nete.comanda end)
where nete.data between @dDataJos and @dDataSus

if @lCuPct=1
begin
 update costtmp set comanda_inf=left(comanda_inf,charindex('.',comanda_inf)-1)
 where charindex('.',comanda_inf)>0
 update costtmp set comanda_sup=left(comanda_sup,charindex('.',comanda_sup)-1)
 where charindex('.',comanda_sup)>0
end
