create procedure wOPModificareDateSalariati_p (@sesiune varchar(50), @parXML xml='<row/>')
as
begin
	set transaction isolation level read uncommitted
	declare @marca varchar(6), @dataJos datetime, @dataSus datetime, @utilizatorASiS varchar(50)

	set @marca = @parXML.value('(/row/@marca)[1]', 'varchar(6)')
	select @dataJos = dbo.BOM(convert(varchar(10),getdate(),101))
	select @dataSus = dbo.EOM(@dataJos)

	exec wIaUtilizator @sesiune=@sesiune, @utilizator=@utilizatorASiS output

	if object_id('tempdb..#salariati') is not null
		drop table #salariati

	Create table #salariati (marca varchar(6) not null)
	exec CreeazaDiezSalariati @numeTabela='#salariati'

	exec pSalariati @dataJos=@dataJos, @dataSus=@dataSus, @marca=@marca, @locm=''

	select rtrim(p.marca) as marca, rtrim(p.nume) as nume, rtrim(p.loc_de_munca) as lm, rtrim(lm.denumire) as denlm, rtrim(p.cod_functie) as functie, rtrim(f.denumire) as denfunctie,
		p.Grupa_de_munca as grupamunca, convert(decimal(10),p.Salar_de_incadrare) as salinc, convert(decimal(10,2),p.salar_lunar_de_baza) as reglucr, 
		p.mod_angajare as modangaj, convert(varchar(10),p.data_plec,101) as datasf
	from #salariati p
		left outer join lm on lm.cod=p.loc_de_munca
		left outer join functii f on f.cod_functie=p.cod_functie
	for xml raw
end