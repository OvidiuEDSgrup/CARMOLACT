--***
create procedure wOPModificarePretRM_p @sesiune varchar(50), @parXML xml 
as  
/*
	Populare grid cu datele din categorii de preturi.
	
*/
declare @idpozdoc int,@codProdus varchar(20),@lista_categpret int,@cotatva decimal(5,2),@pretstoc float, @curs float
set @lista_categpret=(case when exists (select 1 from fPropUtiliz(@sesiune) where cod_proprietate='CATEGPRET' and valoare<>'')then 1 else 0 end)

select @idpozdoc=isnull(@parXML.value('(/row/row/@idpozdoc)[1]','int'),0)
if @idpozdoc=0
	select top 1 @idpozdoc=idpozdoc from pozdoc where tip='RM' and cod=isnull(@parXML.value('(//@cod)[1]','varchar(40)'),'') order by idPozDoc desc 

if @idpozdoc=0
begin
	select 1 as 'inchideFereastra' for xml raw,root('Mesaje')
	raiserror('Nu a fost selectata nicio pozitie sau aveti varianta veche a procedurii wIaPozdoc',16,1)
	return
end

select @codProdus=pd.cod,@pretstoc=isnull(nullif(pd.Pret_de_stoc,0),n.Pret_stoc),@cotatva=n.Cota_TVA, @curs=pd.curs
	from pozdoc pd 
	inner join nomencl n on pd.cod=n.cod
	where idPozDoc=@idpozdoc

select rtrim(pd.cod) as '@cod',rtrim(n.denumire) as '@denumire',convert(decimal(5,2),n.Cota_TVA) as '@cotatva',
	convert(decimal(12,2),pd.Pret_de_stoc) as '@pretstoc',convert(varchar(10),getdate(),101) as '@data',isnull(@idpozdoc,0) as '@idpozdoc'
from pozdoc pd
inner join nomencl n on pd.cod=n.cod
where pd.idpozdoc=@idpozdoc
for xml path,root('Date')

select rtrim(categorie) as catpret,
rtrim(cp.Denumire)+' '+(case when p.Tip_pret=9 then '(impus)' when p.Tip_pret=2 then '(promo)' else '' end) as 'dencategpret',
rtrim(p.tip_pret) as tippret,
dtp.denumire as dentippret,
convert(char(10),data_inferioara,101) as data_inferioara,
convert(char(10),data_superioara,101) as data_superioara,
convert(decimal(12,3),Pret_vanzare) as pret_vanzare,
convert(decimal(12,3),Pret_cu_amanuntul) as pret_cu_amanuntul,
rank() over (partition by categorie,Tip_pret order by data_inferioara desc) as ranc
into #pret
from preturi p
left outer join categpret cp on p.UM=cp.Categorie
inner join dbo.fTipPret() dtp on p.tip_pret=dtp.tipPret
left outer join fPropUtiliz(@sesiune) fp on cod_proprietate='CATEGPRET' and categorie=fp.valoare
where p.Cod_produs=@codProdus
and (@lista_categpret=0 OR fp.valoare is not null)
and getdate() between data_inferioara and data_superioara

delete from #pret where ranc>1

insert into #pret
select rtrim(cp.categorie) as catpret,
isnull(p.dencategpret,rtrim(cp.Denumire)) as 'dencategpret',
1 as tippret,
'Pret standard' as dentippret,
'01/01/1901' as data_inferioara,
'12/31/2999' as data_superioara,
convert(decimal(12,3),0) as pret_vanzare,
convert(decimal(12,3),0) as pret_cu_amanuntul,
1 as ranc
from categpret cp
left outer join #pret p on p.catpret=cp.categorie
where p.catpret is null


SELECT (   
	SELECT *,
	pret_vanzare as pretvanzare,
	pret_cu_amanuntul as pretamanunt,
	convert(decimal(12,3),@pretstoc/(case when cp.In_valuta=1 and @curs>0 then @curs else 1 end)) as pretstoc,
	@cotatva as cotatva,
	convert(decimal(12,3),round((pret_cu_amanuntul/(1.00+@cotatva/100)-@pretstoc/(case when cp.In_valuta=1 and @curs>0 then @curs else 1 end))/(@pretstoc/(case when cp.In_valuta=1 and @curs>0 then @curs else 1 end))*100,2)) as adaos
	FROM  #pret
	inner join categpret cp on cp.Categorie=#pret.catpret
	order by convert(int,catpret)
	FOR XML RAW, TYPE  
	)  
FOR XML PATH('DateGrid'), ROOT('Mesaje')

/*
select @tert=RTRIM(d.tert), @docsursa=RTRIM(d.Numar), @datadocsursa=convert(varchar(20),d.Data,103),  
	   @cantitate=-1*@cantitate
from pozdoc d  where d.Numar=@factura and d.Data=@datadoc and d.tert=@tert and (cod=@cod or @cod='') and 
					(Cod_intrare=@codi or @codi='') and (Numar_pozitie=@numarpoz or @numarpoz='')

select @tert tert_p , @docsursa docsursa, convert(varchar(10),@datadocsursa,103) datasursa, @cod articol, @codi codintrare, @cantitate cantitate
for xml raw*/
