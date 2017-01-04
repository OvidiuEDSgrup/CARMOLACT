
--***
create procedure rapComparativaCombustibili(@DataJos datetime,@DataSus datetime,@locm varchar(20)=null, @masina varchar(20)=null,
		@tip_masina varchar(20)=null, @GrupaMasina varchar(20)=null, @combustibil int=null, @marca varchar(20)=null)
as
begin
	set transaction isolation level read uncommitted
	select element,max(rtrim(left(et.element,len(et.element)-(case when et.tip_masina='Auto' then 0 else 1 end)))) as element_tip 
			, tip_masina into #elemt from elemtipm et 
	where (tip_masina=@tip_masina or @tip_masina is null)
			group by element,tip_masina

	select m.cod_masina, m.denumire as nume_masina, m.nr_inmatriculare as nr_inmatriculare, lower(et.element_tip) as element, ea.Valoare Valoare,
		a.Fisa as Numar_document,ea.Numar_pozitie,a.Tip, 
		(case et.element_tip when 'AlimComb' then 'Alimentare '
			  else 'Consum ' end)+a.tip
		--e.Denumire
		as denumire_element, a.loc_de_munca,lm.denumire as numelm,a.data
		--e.*
	from masini m inner join #elemt et on m.tip_masina=et.tip_masina
	inner join elemente e on et.element=e.cod 
	left outer join activitati a on a.masina=m.cod_masina
	left outer join elemactivitati ea on ea.tip=a.tip and ea.fisa=a.fisa and ea.data=a.data and ea.element=et.element 
	left join lm on lm.cod=a.loc_de_munca
	where et.element_tip in ('AlimComb', 'ConsComb', 'ConsEf'/*, 'TotalAlim', 'KmEf','RestEst'*/) and 
		(ea.data between @DataJos and @DataSus)
		and (@locm is null or m.loc_de_munca like @locm+'%')
		and (@masina is null or m.cod_masina=@masina)
		and (@combustibil is null or m.benzina_sau_motorina=@combustibil)
		and (@GrupaMasina is null or m.grupa=@GrupaMasina)
		and ea.valoare<>0
		and (@marca is null or a.marca=@marca)
	union all
	select substring(p.Comanda,2,40), m.denumire as nume_masina, m.nr_inmatriculare as nr_inmatriculare, 'conspozdoc' as element, 
			p.cantitate Valoare,
		p.Numar,p.Numar_pozitie,p.Tip, 'Document consum' as denumire_element, p.Loc_de_munca,lm.denumire as numelm,p.data
				from masini m inner join pozdoc p on m.cod_masina=substring(p.Comanda,2,40)
				inner join nomencl n on p.cod=n.cod
				inner join grupe g on g.Grupa=n.Grupa
				left join lm on lm.cod=p.Loc_de_munca
				where left(p.comanda,1) in ('A','U')
		and p.Cont_de_stoc like '3022%'
		and (p.data between @DataJos and @DataSus)
		and (@locm is null or p.loc_de_munca like @locm+'%')
		and (@masina is null or substring(p.Comanda,2,40)=@masina)
		and (@combustibil is null or m.benzina_sau_motorina=@combustibil)
		and (@GrupaMasina is null or m.grupa=@GrupaMasina)
		and p.Cantitate<>0
		and g.Denumire in ('motorina','benzina','petrol')
		and exists( select 1 from activitati a where a.masina=m.cod_masina and (@marca is null or a.marca=@marca))
		--*/
	order by a.loc_de_munca,m.cod_masina, a.data, a.fisa, ea.numar_pozitie

	drop table #elemt
end