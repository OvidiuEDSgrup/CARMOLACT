
/*
	exec rapContracte_test '', '2013-01-01', '2014-08-31', '2013-08-01', '2014-08-31', 'CB', null, null, null, null, 1, 1

*/
create procedure rapContracte_test @sesiune varchar(50), @datajos datetime, @datasus datetime, @datafjos datetime, @datafsus datetime,
	@tip_contract varchar(2), @grupa_tert varchar(300), @tert varchar(100), @contract varchar(100), @cont_factura varchar(300),
	@valTva bit, @pozGrupe bit
as
begin try
	declare
		@utilizator varchar(20), @eLmUtiliz int

	select @utilizator = dbo.fIaUtilizator('')
	
	declare @LmUtiliz table(valoare varchar(200))
	insert into @LmUtiliz(valoare)
	select cod from lmfiltrare where utilizator = @utilizator
	
	set @eLmUtiliz = isnull((select max(1) from @LmUtiliz), 0)

	if object_id('tempdb..#pozContracteFiltrate') is not null drop table #pozContracteFiltrate
	if object_id('tempdb..#contractatComandat') is not null drop table #contractatComandat
	if object_id('tempdb..#facturat') is not null drop table #facturat
	if object_id('tempdb..#incasat') is not null drop table #incasat

	/** Aducem doar contractele cu care vom lucra si pozitiile lor, in urma aplicarii filtrelor. */
	select
		pc.idPozContract as idPozContract, rtrim(c.tert) as tert, rtrim(t.denumire) as dentert,
		pc.termen as termen, isnull(rtrim(pc.cod), rtrim(g.grupa)) as cod,
		isnull(rtrim(n.Denumire), rtrim(g.Denumire) + ' (grupa)') as dencod, c.data as data, rtrim(c.numar) as [contract],
		isnull(pc.cantitate, 0) as cantitate, isnull(pc.pret, 0) as pret, isnull(n.Cota_TVA, 0) as cota_tva,
		isnull(n.UM, '') as um, isnull(pc.subtip, '') as subtip
	into #pozContracteFiltrate
	from PozContracte pc
	inner join Contracte c on pc.idContract = c.idContract
	left join terti t on t.Tert = c.tert and (@grupa_tert is null or t.grupa = @grupa_tert)
	left join nomencl n on n.Cod = pc.cod
	left join grupe g on g.Grupa = pc.grupa
	where c.data between @datajos and @datasus
		and c.tip = @tip_contract and (@tert is null or c.tert = @tert)
		and (@contract is null or c.numar = @contract)
		and (@grupa_tert is null or t.grupa is not null)
		and (@eLmUtiliz = 0 or exists (select 1 from @LmUtiliz u where u.valoare = c.Loc_de_munca))
		and (@pozGrupe = 1 or pc.grupa is null)

	/** Cantitatile contractate si comandate*/
	select
		pcf.idPozContract, isnull(pcf.cantitate, 0) as cant_contractata, isnull(pc.cantitate, 0) as cant_comandata,
		isnull(pcf.cantitate * pcf.pret, 0) as valoare_contractata, isnull(pc.cantitate * pc.pret, 0) as val_comandata
	into #contractatComandat
	from #pozContracteFiltrate pcf
	left join LegaturiContracte lc on lc.idPozContract = pcf.idPozContract
	left join PozContracte pc on pc.idPozContract = lc.idPozContractCorespondent
	where @tip_contract in ('CB', 'CF')
	union all
	select
		pcf.idPozContract, isnull(pcf.cantitate, 0) as cant_contractata, 0 as cant_comandata,
		isnull(pcf.cantitate * pcf.pret, 0) as valoare_contractata, 0 as val_comandata
	from #pozContracteFiltrate pcf
	where @tip_contract = 'CS'
	--select * from #contractatComandat

	/** Cantitatile facturate */
	select
		pc.idPozContract, isnull(poz.Cantitate * poz.Pret_vanzare, 0) as val_facturata,
		isnull(poz.Cantitate, 0) as cant_facturata, rtrim(poz.tert) as tert, rtrim(poz.Numar) as factura,
		poz.Data_facturii as data_facturii
	into #facturat
	from #pozContracteFiltrate pcf
	inner join LegaturiContracte lc on lc.idPozContract = pcf.idPozContract
	inner join PozContracte pc on pc.idPozContract = lc.idPozContractCorespondent
	inner join pozdoc poz on poz.idPozDoc = lc.idPozDoc
	where poz.Tip = 'AP'
		and @tip_contract in ('CB', 'CF')
	union all
	select
		pcf.idPozContract, isnull(poz.Cantitate * poz.Pret_vanzare, 0) as val_facturata,
		isnull(poz.Cantitate, 0) as cant_facturata, rtrim(poz.tert) as tert, rtrim(poz.Numar) as factura,
		poz.Data_facturii as data_facturii
	from #pozContracteFiltrate pcf
	inner join LegaturiContracte lc on lc.idPozContract = pcf.idPozContract
	inner join pozdoc poz on poz.idPozDoc = lc.idPozDoc
	where poz.Tip = 'AP'
		and @tip_contract = 'CS'

	/** Cantitatile incasate */
	select
		f.idPozContract as idPozContract, isnull(p.Suma, 0) as val_incasata
	into #incasat
	from pozplin p
	inner join #facturat f on p.Subunitate = '1' and f.tert = p.Tert and f.factura = p.Factura
	where p.Plata_incasare = 'IB'

	/** Select-ul principal */
	select
		pcf.tert as tert, pcf.dentert as dentert, convert(varchar(10), pcf.data, 103) as data,
		pcf.contract as [contract], convert(varchar(10), pcf.termen, 103) as termen, convert(decimal(17,5), pcf.pret) as pret,
		pcf.cod as cod, pcf.dencod as dencod, isnull(pcf.um, '') as um, cc.cant_contractata as cant_contractata,
		cc.valoare_contractata + isnull((case when @valTVA = 1 then cc.valoare_contractata * pcf.cota_tva/100 else 0 end), 0) as val_contractata,
		isnull(cc.cant_comandata, 0) as cant_comandata, isnull(cc.val_comandata, 0) as val_comandata,
		isnull(f.cant_facturata, 0) as cant_facturata, isnull(f.val_facturata, 0) as val_facturata, isnull(i.val_incasata, 0) as val_incasata
	from #pozContracteFiltrate pcf
	inner join #contractatComandat cc on pcf.idPozContract = cc.idPozContract
	left join #facturat f on f.idPozContract = cc.idPozContract and (f.data_facturii is null or f.data_facturii between @datafjos and @datafsus)
	left join #incasat i on i.idPozContract = pcf.idPozContract

end try
begin catch
	declare @mesajEroare varchar(500)
	set @mesajEroare = ERROR_MESSAGE() + ' (' + OBJECT_NAME(@@PROCID) + ')'
	raiserror(@mesajEroare, 16, 1)
end catch
