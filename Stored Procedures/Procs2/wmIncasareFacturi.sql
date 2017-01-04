--***  
/* procedura care afisaza facturile neincasate pe un tert si perimite alegerea facturilor care se vor incasa. */
CREATE procedure wmIncasareFacturi @sesiune varchar(50), @parXML xml as  
set transaction isolation level READ UNCOMMITTED  
if exists(select * from sysobjects where name='wmIncasareFacturiSP' and type='P')
begin
	exec wmIncasareFacturiSP @sesiune, @parXML 
	return 0
end

declare @utilizator varchar(100),@subunitate varchar(9), @tert varchar(30), @xmlFinal varchar(max),
		@facturaDeIncasat varchar(100), @listaFacturi varchar(2000)

exec wIaUtilizator @sesiune=@sesiune, @utilizator=@utilizator output 
if @utilizator is null
	return -1

select	@listaFacturi=@parXML.value('(/row/@listaFacturi)[1]','varchar(100)'),
		@tert=@parXML.value('(/row/@tert)[1]','varchar(20)')

exec luare_date_par 'GE', 'SUBPRO', 0, 0, @subunitate output  

set @xmlfinal='<Date>'
declare @areMeniu int -- Variabila folosita pentru a vedea daca are un meniu sau nu
exec wAreMeniuMobile 'IFSelectie',@utilizator,@areMeniu output

declare @nrFacturi int,@sumaFacturi decimal(12,2)
select @nrFacturi=COUNT(*),@sumaFacturi=sum(f.Valoare+f.TVA_11+f.TVA_22-f.Achitat)
from dbo.Split(@listaFacturi,';') s 
	inner join facturi f on s.Item=f.Factura and f.Tip=0x46 and f.Tert=@tert

if @areMeniu=1
	set @xmlfinal=@xmlfinal+
	(select '<INCASAREFACTURI>' as cod, 'wmScriuIncasare' procdetalii,
		'Incaseaza facturi alese' as denumire, 'assets/Imagini/Meniu/incasari.png' as poza,
		'Nr facturi:'+ltrim(str(@nrFacturi))+', Suma:'+convert(varchar(20),@sumaFacturi) as info,
		'0x0000ff' as culoare
	 for xml raw)

exec wAreMeniuMobile 'IFSuma',@utilizator,@areMeniu output
if @areMeniu=1
begin
		declare @serie varchar(20),@numar varchar(20)
		select	@serie=(case when p.Cod_proprietate='SerieChitMobile' then rtrim(Valoare) else @serie end ),
				@numar=(case when p.Cod_proprietate='UltNumarChitMobile' then rtrim(Valoare) else @numar end )
		from proprietati p where Tip='U' and Cod=@utilizator and Cod_proprietate in ('SerieChitMobile', 'UltNumarChitMobile')

	set @xmlfinal=@xmlfinal+(select '<INCASARESUMA>' as cod, 'wmScriuIncasare' procdetalii,
		'Incaseaza suma' as denumire, 'assets/Imagini/Meniu/incasari.png' as poza,
		'' as info,@sumaFacturi as suma,@serie as serie,@numar as numar, --convert(varchar(10),getdate(),103) as data,
		'D' as tipdetalii, '0x0000ff' as culoare, dbo.f_wmIaForm('CH') form
	 for xml raw)

end


-- formez lista de facturi neachitate
set @xmlFinal=@xmlfinal+
	(select rtrim(f.Factura) as cod,
		rtrim(f.Factura)+' din '+convert(char(10),f.Data,103) as denumire,
		'Val:'+LTRIM(convert(char(20),convert(money,f.Valoare+f.TVA_22),1))+',Ach:'+LTRIM(convert(char(20),convert(money,f.Achitat),1)) as info,
		(case when s.item is not null then '0x33FF00' else '0xFFFFFF' end) as culoare
	from facturi f
	left join dbo.Split(@listaFacturi,';') s on s.Item=f.Factura
	where tip=0x46 and tert=@tert and ABS(sold)>0.05
	order by data
	for xml raw
	)

-- formez si adaug linia pentru incasare.
set @xmlfinal=@xmlfinal+'</Date>'

select convert(xml,@xmlfinal)

select 'Incasare facturi' as titlu, 'wmIncasareFacturiHandler' as detalii,0 as areSearch, '@factura' numeatr,'refresh' actiune
for xml raw,Root('Mesaje')   

--select * from tmp_facturi_de_listat