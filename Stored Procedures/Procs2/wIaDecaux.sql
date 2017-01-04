
create procedure wIaDecaux @sesiune varchar(50), @parXML xml
as
	declare @utilizator varchar(20), @Sub char(9),@iDoc int
	
	exec wIaUtilizator @sesiune=@sesiune, @utilizator=@utilizator output
	exec luare_date_par 'GE', 'SUBPRO', 0, 0, @Sub output
	exec sp_xml_preparedocument @iDoc output, @parXML

	select top 100 
		rtrim(d.subunitate) as subunitate,'DX' as tip,convert(char(10),d.data,101) as data, RTRIM(d.L_m_furnizor) as l_m_furnizor,
		max(lmf.denumire) as denl_m_furnizor,RTRIM(d.Comanda_furnizor) as comanda_furnizor,max(cf.descriere) as dencomanda_furnizor,
		convert(decimal(15,2),SUM(d.Cantitate)) as totalCantitate,COUNT(1) as numarpozitii
	from decaux d
	cross join OPENXML(@iDoc, '/row')
	WITH
		(
			 data_jos datetime '@datajos'
			,data_sus datetime '@datasus'
			,data datetime '@data'
			,denl_m_furnizor varchar(30) '@f_denl_m_furnizor'
			,dencomanda_furnizor varchar(80) '@f_dencomanda_furnizor'
			,comanda_furnizor varchar(80) '@comanda_furnizor'
			,l_m_furnizor varchar(30) '@l_m_furnizor'
		) as fx
	left outer join lm lmf on lmf.Cod=d.L_m_furnizor 
	left outer join comenzi cf on cf.Comanda=d.Comanda_furnizor
	left outer join LMFiltrare lu on lu.utilizator=@utilizator and lu.cod=d.L_m_furnizor 
	where d.subunitate=@Sub 
		and (dbo.f_areLMFiltru(@utilizator)=0 or lu.cod is not null)
		and (fx.data is null or d.data=fx.data)
		and d.data between isnull(fx.data_jos, '01/01/1901') and (case when isnull(fx.data_sus, '01/01/1901')<='01/01/1901' then '12/31/2999' else fx.data_sus end)
		and (lmf.denumire like '%'+isnull(fx.denl_m_furnizor, '')+'%' or d.L_m_furnizor like isnull(fx.denl_m_furnizor, '')+'%')
		and (cf.descriere like '%'+isnull(fx.dencomanda_furnizor, '')+'%' or d.Comanda_furnizor like isnull(fx.dencomanda_furnizor, '') + '%')
		/** Pentru identificarea antetului la scriere pozitii si refresh taburi*/
		and (isnull(fx.l_m_furnizor,'')='' OR d.L_m_furnizor=fx.l_m_furnizor)
		and (isnull(fx.comanda_furnizor,'')='' OR d.Comanda_furnizor=fx.comanda_furnizor)
	group by d.Subunitate, d.Data, d.L_m_furnizor, d.Comanda_furnizor  
	order by d.data, d.L_m_furnizor, d.Comanda_furnizor   
	for xml raw, ROOT('Date')

	exec sp_xml_removedocument @iDoc 

