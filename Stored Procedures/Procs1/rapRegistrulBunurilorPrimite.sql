--***
create procedure rapRegistrulBunurilorPrimite
	@sesiune varchar(50)=null,
	@dataJos datetime,
	@dataSus datetime,
	@refacere bit=0,
	@tert varchar(50)=null,
	@cod_material varchar(50)=null,
	@gestiune varchar(10)=null,
	@cont varchar(50)='%',
	@parXML xml=null
as
declare @eroare varchar(max)
select @eroare=''
begin try
	/*
		codul anterior:
			if @refacere=1 exec pregbun @dataj,@datas,@Tert,@cod_material
			select *
			from regbunuri where data_primirii between @dataj and @datas and (rtrim(tert)=rtrim(@Tert) or isnull(@Tert,'')='') 
							and (rtrim(@cod_material)=rtrim(cod_bun) or rtrim(@cod_material)='')
	*/

	
--> jucarie pt raport:
select  p.cod, p.numar, p.tip, p.data as data_primirii, p.Cantitate cantitate_bun, p.pret_de_stoc*p.Cantitate valoare_bun, d.detalii.value('(row/@tert)[1]','varchar(100)') tert, 
		t.Denumire denumire_tert, rtrim(isnull(p.detalii.value('(/row/@explicatii)[1]', 'varchar(50)'),'')) as explicatii, 
		pp.cod cod_e, pp.tip tip_e, pp.data data_tr, pp.cantitate cantitate_ret, pp.Pret_de_stoc*pp.cantitate valoare_ret, pp.tert tert_e, 
		rtrim(isnull(pp.detalii.value('(/row/@explicatii)[1]', 'varchar(50)'),'')) as denumire_serv, n.Denumire denumire_bun, 
		rtrim(upper(t.localitate))+(case when rtrim(t.adresa)='' or t.adresa is null then ', ' else '' end)+rtrim(upper(t.adresa)) as adresa, t.cod_fiscal, 
		n1.Denumire denumire_ret, '01/01/1901' data_serv, '' nr_ordine
from pozdoc p
	left outer join pozdoc pp on p.idpozdoc=pp.idIntrareFirma and pp.gestiune=p.gestiune and pp.tip in ('AE','AP')
	left outer join nomencl n on p.cod=n.cod
	left outer join nomencl n1 on pp.cod=n1.cod
	left outer join doc d on d.cod_gestiune=p.gestiune and d.Subunitate='1' and d.tip=p.Tip and d.numar=p.numar and d.data=p.data
	left join terti t on t.tert=d.detalii.value('(row/@tert)[1]','varchar(100)')
where (@gestiune is null or p.gestiune=@gestiune)
	and (@cod_material is null or p.cod=@cod_material)
	and p.Cont_de_stoc like @cont
	and (@tert is null or d.detalii.value('(row/@tert)[1]','varchar(100)')=@tert)
	and p.data between @dataJos and @dataSus
	and p.tip in ('AI','RM') 
	and pp.idIntrareFirma is not null
order by p.data, p.numar

end try
begin catch
	set @eroare=ERROR_MESSAGE()+' (rapRegistrulBunurilorPrimite '+convert(varchar(20),ERROR_LINE())+')'
end catch

	
if len(@eroare)>0 raiserror(@eroare, 16,1)
