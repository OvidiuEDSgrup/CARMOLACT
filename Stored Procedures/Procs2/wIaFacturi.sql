
create procedure wIaFacturi @sesiune varchar(50), @parXML xml
as

declare
	@userASiS varchar(20), @mesaj varchar(max), @f_tipfact varchar(1), @f_factura varchar(20), @f_tert varchar(100), @f_lm varchar(100), @f_valuta varchar(3), @f_cont varchar(20), @f_tip binary(1),
	@f_soldmin varchar(20),@f_soldmax varchar(20),@soldmin decimal(12,2),@soldmax decimal(12,2), @lista_lm int

begin try

	select
		@f_tipfact = @parXML.value('(/row/@f_tipfact)[1]','varchar(1)'),
		@f_factura = @parXML.value('(/row/@f_factura)[1]','varchar(20)'),
		@f_tert = '%' + replace(isnull(@parXML.value('(/row/@f_tert)[1]','varchar(100)'),''),' ','%') + '%',
		@f_lm = '%' + replace(isnull(@parXML.value('(/row/@f_lm)[1]','varchar(100)'),''),' ','%') + '%',
		@f_valuta = @parXML.value('(/row/@f_valuta)[1]','varchar(50)'),
		@f_cont = @parXML.value('(/row/@f_cont)[1]','varchar(20)'),
		@f_soldmin=@parXML.value('(/row/@f_soldmin)[1]','varchar(20)'),
		@f_soldmax=@parXML.value('(/row/@f_soldmax)[1]','varchar(20)')

	begin try
		if @f_soldmin is not null and isnumeric(@f_soldmin)=1
			set @soldmin=convert(decimal(12,2),@f_soldmin)
		if @f_soldmax is not null and isnumeric(@f_soldmax)=1
			set @soldmax=convert(decimal(12,2),@f_soldmax)
	end try
	begin catch
		set @f_soldmin=null
		set @f_soldmax=null
	end catch

	exec wIaUtilizator @sesiune=@sesiune, @utilizator=@userASiS OUTPUT
	select @lista_lm = dbo.f_arelmfiltru(@userASiS)

	if @f_tipfact = 'B'
		set @f_tip = 0x46
	
	if @f_tipfact = 'F'
		set @f_tip = 0x54

	select top 100
		convert(varchar(10),f.tip) as tipfact,
		(case f.tip when 0x46 then 'Beneficiari' when 0x54 then 'Furnizori' else '' end) as dentipfact,
		rtrim(f.factura) as factura,
		rtrim(f.tert) as tert,
		rtrim(t.denumire) as dentert,
		rtrim(f.loc_de_munca) as lm,
		rtrim(lm.denumire) as denlm,
		convert(varchar(10),f.data,101) data, 
		convert(varchar(10),f.data_scadentei,101) data_scadentei,
		convert(decimal(17,2),f.valoare) as valoare,
		convert(decimal(17,2),f.tva_22) as tva,
		rtrim(f.valuta) as valuta,
		convert(decimal(17,5),f.curs) as curs,
		convert(decimal(17,2),f.valoare_valuta) as valoare_valuta,
		convert(decimal(17,2),f.achitat) as achitat,
		convert(decimal(17,2),f.sold) as sold,
		convert(decimal(17,2),f.achitat_valuta) as achitat_valuta,
		convert(decimal(17,2),f.sold_valuta) as sold_valuta,
		rtrim(f.cont_de_tert) as cont
	from facturi f
		inner join terti t on f.subunitate=t.subunitate and f.tert=t.tert
		left join lm on lm.cod=f.loc_de_munca
	where
		(@f_factura is null or f.factura like @f_factura + '%')
		and (@f_tipfact is null or f.tip = @f_tip)
		and (t.tert like @f_tert or t.denumire like @f_tert)
		and (f.loc_de_munca like @f_lm or lm.denumire like @f_lm)
		and (@f_valuta is null or f.valuta like @f_valuta + '%')
		and (@f_cont is null or f.cont_de_tert like @f_cont + '%')
		and (@f_soldmin is null or abs(f.sold)>=@soldmin)
		and (@f_soldmax is null or abs(f.sold)<=@soldmax)
		and (@lista_lm = 0 or exists (select * from LMFiltrare lu where lu.utilizator=@userASiS and lu.cod=f.Loc_de_munca))
	order by f.data desc, f.factura
	for xml raw
end try

begin catch
	set @mesaj = error_message() + ' (' + object_name(@@procid) + ')'
	raiserror(@mesaj,16,1)
end catch
