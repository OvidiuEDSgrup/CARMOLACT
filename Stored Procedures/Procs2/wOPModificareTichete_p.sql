Create procedure wOPModificareTichete_p (@sesiune varchar(50), @parXML xml='<row/>')
as
begin try
	set transaction isolation level read uncommitted
	declare @datalunii datetime, @utilizatorASiS varchar(50), @lmantet varchar(9), @denlmantet varchar(50), @luna varchar(100), @mesaj varchar(1000)

	set @lmantet = @parXML.value('(/row/@lmantet)[1]', 'varchar(9)')
	set @denlmantet = @parXML.value('(/row/@denlmantet)[1]', 'varchar(50)')
	set @luna = @parXML.value('(/row/@luna)[1]', 'varchar(100)')
	set @datalunii = @parXML.value('(/row/@data)[1]', 'datetime')

	exec wIaUtilizator @sesiune=@sesiune, @utilizator=@utilizatorASiS output

	select convert(varchar(10),@datalunii,101) as data, rtrim(@luna) as luna, rtrim(@lmantet) as lmantet, rtrim(@denlmantet) as denlmantet
	for xml raw, root('Date')
	
	select 
		(select convert(varchar(10),t.data_lunii,101) as data, t.marca, max(rtrim(isnull(i.nume,p.nume))) as densalariat,
			sum(convert(decimal(12,2),(case when t.Tip_operatie in ('C','P','S') then t.Nr_tichete else -t.Nr_tichete end)*t.Valoare_tichet)) as valtichete, 
			sum(convert(decimal(12),(case when t.Tip_operatie='C' then t.Nr_tichete else 0 end))) as nrtichetecuv, 
			sum(convert(decimal(12),(case when t.Tip_operatie='S' then t.Nr_tichete else 0 end))) as nrtichetesupl, 
			sum(convert(decimal(12),(case when t.Tip_operatie='P' then t.Nr_tichete else 0 end))) as nrtichetestoc, 
			sum(convert(decimal(12),(case when t.Tip_operatie='R' then t.Nr_tichete else 0 end))) as nrticheteret, 
			sum(convert(decimal(12),t.Nr_tichete*(case when t.Tip_operatie in ('C','P','S') then 1 else -1 end))) as nrticheteprimite
		from Tichete t
			left outer join istpers i on i.Marca=t.Marca and i.Data=t.Data_lunii
			left outer join personal p on p.Marca=t.Marca 
		where t.Data_lunii=@datalunii and isnull(i.Loc_de_munca,p.loc_de_munca) like rtrim(@lmantet)+'%' 
		group by t.data_lunii, t.marca
		order by max(rtrim(isnull(i.nume,p.nume)))
		for xml raw, type
		)
	for xml path('DateGrid'), ROOT('Mesaje')
end try

begin catch
	SET @mesaj = ERROR_MESSAGE() + ' (' + object_name(@@PROCID) + ')'
	select 1 as inchideFereastra for xml raw,root('Mesaje')
	raiserror (@mesaj, 11, 1)
end catch