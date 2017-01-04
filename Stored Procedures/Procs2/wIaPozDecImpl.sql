--***
create procedure [dbo].wIaPozDecImpl @sesiune varchar(30), @parXML XML
AS    
begin
	Declare @sub varchar(9), @doc xml, @an_impl int, @luna_impl int, @mod_impl int, @data_jos datetime, @data_sus datetime, @cautare varchar(50), 
			@userASiS varchar(20), @lista_lm int

	EXEC wIaUtilizator @sesiune=@sesiune, @utilizator=@userASiS OUTPUT

	select  @data_jos=isnull(@parXML.value('(/row/@datajos)[1]', 'datetime'), '1901-01-01') ,
			@data_sus=isnull(@parXML.value('(/row/@datasus)[1]', 'datetime'), '2901-01-01')
			,@cautare=isnull(@parXML.value('(/row/@_cautare)[1]', 'varchar(50)'), '') 
		
	exec luare_date_par 'GE', 'SUBPRO', 0, 0, @sub output
	exec luare_date_par 'GE', 'ANULIMPL', 0, @an_impl output, ''
	exec luare_date_par 'GE', 'LUNAIMPL', 0, @luna_impl output, ''
	exec luare_date_par 'GE', 'IMPLEMENT', @mod_impl output, 0, ''

	if exists (select * from LMFiltrare l where l.utilizator=@userASiS)
		set @lista_lm=1
	else 
		set @lista_lm=0

	select  RTRIM(d.marca) as marca, rtrim(d.marca)+'-'+rtrim(p.nume) as densalariat, 'T' as tipdec, 
		RTRIM(d.cont) as cont, convert(varchar(10),d.Data,101) as data,
		convert(varchar(10),d.Data_scadentei,101) as data_scadentei, RTRIM(decont) as decont,
		(case when isnull(d.valuta,'')='' then convert(decimal(17,4),d.valoare) else convert(decimal(17,4),d.Valoare_valuta) end) as valoared,	--valoare afisata in grid, in valuta sau nu 
		(case when isnull(d.valuta,'')='' then convert(decimal(17,4),d.Sold) else convert(decimal(17,4),d.Sold_valuta) end) as soldd,	--sold afisat in grid, in valuta sau nu
		(case when isnull(d.valuta,'')='' then convert(decimal(17,4),d.Decontat) else convert(decimal(17,4),d.Decontat_valuta) end) as decontatd,	--decontat afisat in grid, in valuta sau nu
		(case when isnull(d.valuta,'')='' then 'RON' else RTRIM(d.Valuta) end) as valutad,--valuta afisata in grid, dc nu e completata->RON
		convert(varchar(10),d.Data_ultimei_decontari,101) as data_ultimei_decontari,
		convert(decimal(17,4),d.valoare) as valoare, convert(decimal(17,2),sold) as sold, convert(decimal(17,4),d.Decontat) as decontat, 
		convert(decimal(17,4),d.Curs) as curs, convert(decimal(17,2),Valoare_valuta) as valoare_valuta, convert(decimal(17,2),Decontat_valuta) as decontat_valuta, 
		rtrim(d.Loc_de_munca) as lm, rtrim(lm.Denumire) as denlm, RTRIM(left(d.Comanda,20)) as comanda, RTRIM(c.Descriere) as dencomanda, 
		substring(d.Comanda,21,20) as indbug, RTRIM(ib.Denumire) as denindbug, 
		RTRIM(v.Denumire_valuta) as denvaluta, RTRIM(d.Valuta) as valuta, 'DI' as subtip, 'DI'as tip,
		(case when @mod_impl=1 then 0 else 1 end) as _nemodificabil -- se pot modifica aceste deconturi daca sunt in mod implementare
	from decimpl d
		left outer join personal p on p.Marca=d.Marca
		left outer join valuta v on v.Valuta=d.Valuta
		left outer join Comenzi c on c.Subunitate=@sub and c.Comanda=left(d.Comanda,20)
		left outer join lm on lm.Cod=d.Loc_de_munca
		left outer join indbug ib on ib.Indbug=substring(d.Comanda,21,20)
	where d.Tip='T'
		and d.data between @data_jos and @data_sus
		and (@cautare='' or d.decont like @cautare+'%' or d.marca like @cautare+'%' or p.nume like '%'+@cautare+'%'
			or d.cont like @cautare+'%' or (case when d.valuta='' then 'RON' else d.Valuta end) like @cautare+'%')
		and (@lista_lm=0 or  exists (select * from LMFiltrare lu where lu.utilizator=@userASiS and lu.cod=d.Loc_de_munca))	
	order by d.Data desc
	for xml raw
end
