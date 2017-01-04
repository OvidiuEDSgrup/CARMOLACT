--***
create procedure [dbo].wIaPozEfecteImpl @sesiune varchar(30), @parXML XML
AS    
	Declare @sub varchar(9),@tiptert varchar(1),@doc xml,@an_impl int,@luna_impl int,@mod_impl int,@data_jos datetime,@data_sus datetime,@cautare varchar(50),@userASiS varchar(20),
		@lista_lm int

	EXEC wIaUtilizator @sesiune=@sesiune, @utilizator=@userASiS OUTPUT

select  --@cod_gestiune=isnull(@parXML.value('(/row/@cod_gestiune)[1]', 'varchar(13)'), '') , 
		@tiptert=isnull(@parXML.value('(/row/@tiptert)[1]', 'varchar(1)'), ''),
		@data_jos=isnull(@parXML.value('(/row/@datajos)[1]', 'datetime'), '1901-01-01') ,
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
--select * from efimpl


select  RTRIM(a.tert) as tert, rtrim(a.tert)+'-'+rtrim(t.Denumire) as dentert, (case a.tip when 'I' then 'B' when 'P' then 'F' else '' end) as tiptert, 
	RTRIM(a.Cont) as cont_efect, convert(varchar(10),a.Data,101) as data,
	convert(varchar(10),a.Data_scadentei,101) as data_scadentei, convert(decimal(17,4),a.valoare) as valoare, RTRIM(nr_efect)as efect,
	(case when isnull(a.valuta,'')='' then convert(decimal(17,4),a.valoare) else convert(decimal(17,4),a.Valoare_valuta) end) as valoaree,--valoare afisata in grid, in valuta sau nu 
	(case when isnull(a.valuta,'')='' then convert(decimal(17,4),a.Sold) else convert(decimal(17,4),a.Sold_valuta) end) as solde,--sold afisat in grid, in valuta sau nu
	(case when isnull(a.valuta,'')='' then convert(decimal(17,4),a.decontat) else convert(decimal(17,4),a.Decontat_valuta) end) as decontate,--decontat afisat in grid, in valuta sau nu
	(case when isnull(a.valuta,'')='' then 'RON' else RTRIM(a.Valuta) end) as valutaf,--valuta afisata in grid, dc nu e completata->RON
	
	convert(varchar(10),a.Data_decontarii,101) as data_decontarii,
	convert(decimal(17,4),a.Curs) as curs, convert(decimal(17,2),Valoare_valuta) as valoare_valuta, convert(decimal(17,2),sold) as sold, convert(decimal(17,4),a.decontat) as decontat, 
	rtrim(a.Loc_de_munca) as lm, rtrim(lm.Denumire) as denlm, RTRIM(left(a.Comanda,20)) as comanda, RTRIM(c.Descriere) as dencomanda, 
	substring(a.Comanda,21,20) as indbug, RTRIM(ib.Denumire) as denindbug, 
	RTRIM(v.Denumire_valuta) as denvaluta, RTRIM(a.Valuta) as valuta, 'EI' as subtip,'EI'as tip,
	--(case when YEAR(a.data)<>@an_impl and MONTH(a.data)<>@luna_impl then 1 else 0 end) as _nemodificabil
	(case when @mod_impl=1 then 0 else 1 end) as _nemodificabil -- se pot modifica aceste facturi daca sunt in mod implementare
from efimpl a 
	left outer join terti t on t.Subunitate=@sub and t.Tert=a.Tert
	left outer join valuta v on v.Valuta=a.Valuta
	left outer join Comenzi c on c.Subunitate=@sub and c.Comanda=left(a.Comanda,20)
	left outer join lm on lm.Cod=a.Loc_de_munca
	left outer join indbug ib on ib.Indbug=substring(a.Comanda,21,20)
where a.Tip=(case @tiptert when 'B' then 'I' when 'F' then 'P' else '' end)
	and a.data between @data_jos and @data_sus
	and (@cautare='' or a.nr_efect like @cautare+'%' or a.Tert like @cautare+'%' or t.Denumire like '%'+@cautare+'%'
		or a.Cont like @cautare+'%' or (case when a.valuta='' then 'RON' else a.Valuta end) like @cautare+'%')
	and (@lista_lm=0 or  exists (select * from LMFiltrare lu where lu.utilizator=@userASiS and lu.cod=a.Loc_de_munca))	
order by a.Data desc
for xml raw
--select * from serii
--select * from factimpl
--sp_help factimpl
