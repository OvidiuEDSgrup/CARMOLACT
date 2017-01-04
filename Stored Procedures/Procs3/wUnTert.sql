--***
create procedure wUnTert @sesiune varchar(50),@parXML xml
as
if exists(select * from sysobjects where name='wUnTertSP' and type='P')      
begin
	exec wUnTertSP @sesiune=@sesiune,@parXML=@parXML
	return 0
end

declare @eroare varchar(max), @tert varchar(50), @starebkfact varchar(10), @nrcomenzi int--, @valoarePunct decimal(12,5), @puncteTert int

set @starebkfact=isnull((select rtrim(val_alfanumerica) from par where par.Tip_parametru='UC' and par.Parametru='STBKFACT'),'')
	
select @tert=ISNULL(@parXML.value('(/row/@tert)[1]', 'varchar(80)'), '')

set @nrcomenzi= isnull((select COUNT(*) from con where subunitate='1' and tip='BK' and tert=@tert and Stare=@starebkfact),0) 
		
if exists (select 1 from sysobjects where name='pozdevauto') 
	set @nrcomenzi=@nrcomenzi+isnull((select count(*) from devauto d where d.Stare='2' and d.Beneficiar=@tert),0)

select 
rtrim(t.Tert) as cod,rtrim(t.Denumire) as denumire,rtrim(t.Cod_fiscal) as cod_fiscal,
rtrim(it.Banca3) as NrORC,
rtrim(t.Localitate) as localitate,rtrim(t.Judet) as judet,rtrim(t.Adresa) as adresa,
rtrim(t.Telefon_fax) as telefon_fax,
rtrim(t.Banca) as banca,rtrim(t.Cont_in_banca) as cont_in_banca, RTRIM(CONVERT(varchar,it.discount)) as zileScad,
convert(int,Sold_ca_beneficiar) as categorie_pret, @eroare as eroare, '0' as cautaCoduriNomencl,
@nrcomenzi as nrcomenzi
--, @valoarePunct valoarePunct, @puncteTert as puncteTert
from terti t
left join infotert it on  it.Subunitate='1' and it.Tert=t.Tert and it.Identificator=''
where t.subunitate='1' and t.Tert = @tert
for xml raw
