
CREATE procedure [dbo].[Declaratia394SP1] --*/ declare 
	@parXML xml
/*
select @parXML='<row datajos="2016-10-01T00:00:00" datasus="2016-10-31T00:00:00" pecoduri="1" />'
--*/as

declare @tipCump int, @cotaTVA int, @DataJ datetime, @DataS datetime

set @tipCump=@parXML.value('(row/@tipCump)[1]','int')
set @DataJ=@parXML.value('(row/@datajos)[1]','datetime')
set @DataS=@parXML.value('(row/@datasus)[1]','datetime')

select @cotatva=isnull(val_numerica,24) from par where tip_parametru='GE' and parametru='COTATVA'


if object_id('tempdb.dbo.#D394det') is null
	begin
		create table #D394det (subunitate varchar(20),
			--> trunchi comun d390 si d394:
			tert varchar(100), codfisc varchar(100), dentert varchar(1000), tipop varchar(100), baza decimal(15,3),
			numar varchar(100), numarD varchar(100), tipD varchar(100),	data datetime, factura varchar(100), valoare_factura decimal(15,3), explicatii varchar(1000), tip varchar(100),
			cota_tva int, discFaraTVA decimal(15,3), discTVA decimal(15,3),
			data_doc datetime, ordonare varchar(100), drept_ded varchar(100),
			cont_TVA varchar(100), cont_coresp varchar(100), exonerat int, vanzcump varchar(100), numar_pozitie int, tipDoc varchar(100), cod varchar(100), factadoc  varchar(100), contf varchar(100)
			--> suplimentare pentru d390
			--, tara varchar(100), baza_22 decimal(15,3) default 0, tva_22 decimal(15,3) default 0, cont_de_stoc varchar(40)
			--> suplimentare pentru d394
			, idpozitie int, tva decimal(15,3) default 0, codNomenclator varchar(100) default '', invers int default 0
			, setdate int default 0
			, tip_partener int
			, tli int default 0
			, tip_tva int
			, fsimplificata int
			, tip_nom char(1)
			, nrbonuri decimal(12,2)
			, bunimob varchar(20)	
			, tertPF int
			, bun varchar(20)
			, regimspec394 int default 0
			, codcaen varchar(6)
			, codNomenclatura varchar(20) default '' 
			, marjaprofit int
			, tipDocNepl char(1)
			, idplaja int 
			, modemitfact char(1))	-->setdate e nivelul: 0=facturi, 1=terti, 2=totaluri
									-->tertPF indica ca acea operatiune apartine unui tert care este persoana fizica
	end

/***
Idpozitie – se poate pune 0 (inseamna idpozitie din tabela de unde provin datele. Ex. idpozdoc
tip_partener – in cazul dat ar trebui pus 4 (persoane neinregistrate in scopuri de TVA)
tip_tva=0     -- cred la documentele din SP1 nu se aplica taxare aplica
fsimplificata=0 
tip_nom = tipul din nomenclator al codului
nrbonuri=0 
tli=0 – cred ca tertii din SP1 nu sunt cu TVA la incasare
regimspec394=0
codcaen=null
marjaprofit=0
tipDocNepl=1,2,3,4 (tipul de document pentru persoane neinregistrate in scopuri de TVA 
			– 1=Factura, 2=Borderou, 3=File carnet comercializare, 4=Contract)
idplaja=null
modemitfact=null
tertPF = 1 daca tertul este o persoana fizica, 0 altfel
*/
--/*
insert into #D394det
	(subunitate, numar, numarD, tipD, data, factura, tert, valoare_factura, baza, tva, explicatii,
	tip, cota_tva, discFaraTVA, discTVA, data_doc, ordonare, drept_ded, cont_TVA, cont_coresp, exonerat, 
	vanzcump, numar_pozitie, tipDoc, cod, factadoc, contf, codfisc, dentert, tipop, codNomenclator, invers,
	idpozitie, tip_partener, tip_tva, fsimplificata, tip_nom, nrbonuri, tli, regimspec394, codcaen, marjaprofit, 
	tipDocNepl, idplaja, modemitfact, tertPF)
select subunitate='1', numar=b.Nr_doc,numarD =b.Nr_doc,tipD ='AL', data =(case when b.Data_doc>'1901-01-01' then b.Data_doc else b.Data_lunii end)
	,factura =b.Nr_doc,tert =isnull(t.Tert,''), valoare_factura =convert(decimal(17,5),b.Valoare_STAS/*g.Pret*b.Cant_STAS*/),baza=convert(decimal(17,5),b.Valoare_STAS/*g.Pret*b.Cant_STAS*/)
	,tva=0,
	explicatii =space(50),tip ='',cota_tva =0,discFaraTVA =0,discTVA =0,data_doc =b.Data_lunii,ordonare ='',drept_ded ='',
	cont_TVA ='',cont_coresp ='',exonerat =0,vanzcump ='C',numar_pozitie =0,tipDoc='AL',cod=rtrim(l.Val_alfanumerica),factadoc='',contf='', --codfisc, dentert, tipop, codNomenclator, coloana
	replace(replace(replace(isnull(t.cod_fiscal, p.CNP_CUI), 'RO', ''), 'R', ''), ' ','') as codfisc, 
	isnull(t.denumire, p.Denumire) as dentert, 'N' as tipop, cod=rtrim(l.Val_alfanumerica),invers=0,
	Idpozitie=0, tip_partener=case when t.detalii.value('(/row/@_persfizica)[1]','int')=1 or isnull(tt.tip_tva,(case when tu.tip_tva='I' then 'I' else 'N' end))='N' then 2 else 4 end, tip_tva=0, fsimplificata=0, tip_nom=n.Tip, nrbonuri=0, tli=0, regimspec394=0, codcaen=null, marjaprofit=0,
	tipDocNepl=3--(CASE p.Tip_pers WHEN 'J' THEN 1 ELSE 3 END)
	, idplaja=NULL, modemitfact=null, tertPF=(CASE p.Tip_pers WHEN 'F' THEN 1 ELSE 0 END)
--*/select *
from BordAchizLapteVW b join prodlapte p on p.Cod_producator=b.Producator 
	join CentrColectLapte c on c.Cod_centru_colectare=b.Centru_colectare
	join TipLapte tl on tl.Cod=b.Tip_lapte join nomencl n on n.Cod=tl.Cod
	left join GrilaPretCentrColectLapte g on g.Centru_colectare=b.Centru_colectare and g.Tip_lapte=b.Tip_lapte and g.Data_lunii=b.Data_lunii 
	cross join (select top (1) tip_tva from TvaPeTerti v where v.TipF='B' and v.Tert is null and v.dela<=getdate() order by dela desc) tu
	cross join (select top (1) val_alfanumerica from par p where p.Tip_parametru='AL' and p.Parametru='CODLAPTEN') l
	left join terti t on t.Tert=p.CNP_CUI and t.Subunitate='1'
	left join infotert i on i.Identificator='' and i.Tert=t.Tert and i.Subunitate=t.Subunitate 
	outer apply (select top (1) tip_tva from TvaPeTerti v where v.tipf='F' and isnull(v.factura,'')='' and v.dela<=b.Data_doc and t.tert=v.tert order by dela desc) tt
where b.Data_lunii between @DataJ and @DataS and b.Nr_doc<>''
	and isnull(i.Zile_inc,0)=0 
	and (t.Tert is null or isnull(tt.tip_tva,(case when tu.tip_tva='I' then 'I' else 'N' end))='N')
