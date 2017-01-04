Create procedure sitComandaCarduriTicheteExcel @idRulare int = 0
as
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
set nocount on
DECLARE @utilizator VARCHAR(100), @sub varchar(100), @eroare varchar(1000), @datajos datetime, @datasus datetime, @parXML xml, 
		@sesiune varchar(50), @utilizatorWindows VARCHAR(100), @multiFirma int, @lista_lm int, 
		@TicheteMarca int, @impozitareTichete int, @datajosTich datetime, @datasusTich datetime, @salariatiCuTichete int, @furnizorTichete varchar(100)

begin try

	select @multiFirma=0
--	daca tabela par este view inseamna ca se lucreaza cu parametrii pe locuri de munca (in aceeasi BD sunt mai multe unitati)	
	if exists (select * from sysobjects where name ='par' and xtype='V')
		set @multiFirma=1
	
	select @parXML = parXML, @sesiune=sesiune
	from asisria..ProceduriDeRulat
	where idRulare = @idRulare

	select @utilizator=utilizator
	from asisria..sesiuniRIA
	where token = @sesiune
	select @utilizatorWindows=Observatii from utilizatori where ID=@utilizator

	set @lista_lm=dbo.f_areLMFiltru(@utilizator)
	
	if @multiFirma=1
		exec as login=RTRIM(@utilizatorWindows)

	select	@datajos = @parXML.value('(/*/@datajos)[1]', 'datetime'), 
			@datasus = @parXML.value('(/*/@datasus)[1]', 'datetime'),
			@furnizorTichete = isnull(@parXML.value('(/*/@furnizortichete)[1]', 'varchar(100)'),''),
			@salariatiCuTichete = isnull(@parXML.value('(/*/@salcutichete)[1]', 'int'),0)

	set @TicheteMarca = dbo.iauParL('PS','TICHMARCA')
	set @impozitareTichete=dbo.iauParLL(@datasus,'PS','DJIMPZTIC')
	set @datajosTich=dbo.iauParLD(@datasus,'PS','DJIMPZTIC')
	set @datasusTich=dbo.iauParLD(@datasus,'PS','DSIMPZTIC')

	if object_id('tempdb..#ptichete')is not null 
		drop table #ptichete
	create table #ptichete (data datetime)
	exec CreeazaDiezSalarii @numeTabela='#ptichete'
	if @salariatiCuTichete=1
		exec pTichete @dataJos=@datajosTich, @dataSus=@datasusTich, @marca=null, @DeLaCalculLichidare=1

	SELECT left(left(p.Nume,CHARINDEX(' ',p.Nume)-1),50) as Nume, substring(p.Nume,CHARINDEX(' ',p.Nume)+1,30) as Prenume, p.Nume as nume_card, 
		rtrim(p.Cod_numeric_personal) as cnp, convert(varchar(10),p.Data_nasterii,103) as data_nasterii, 
		ip.email, p.judet, p.localitate as oras, 
		(case when p.strada<>'' then ' str. ' else '' end)+rtrim(p.strada)+(case when p.numar<>'' then ' nr. ' else '' end)+rtrim(p.numar)
			+(case when p.bloc<>'' then ' bl. ' else '' end)+rtrim(p.bloc)+(case when p.scara<>'' then ' sc. ' else '' end)+rtrim(p.scara)
			+(case when p.etaj<>'' then ' et. ' else '' end)+rtrim(p.etaj)+(case when p.apartament<>'' then ' ap. ' else '' end)+rtrim(p.apartament) as adresa,
		p.cod_postal
	FROM personal p
		left outer join infopers ip on ip.marca=p.marca
		left outer join LMFiltrare lu on lu.utilizator=@utilizator and lu.cod=p.Loc_de_munca
		left outer join #ptichete t on t.marca=p.marca
	where p.Data_angajarii_in_unitate<=@datasus and (p.loc_ramas_vacant=0 or p.Data_plec>@datajos)
		and (@lista_lm=0 or lu.cod is not null)
		and (@salariatiCuTichete=0 or t.marca is not null)
		and (@TicheteMarca=0 or convert(int,p.Loc_de_munca_din_pontaj)=1)
		and not (p.Grupa_de_munca in ('O','P') and @TicheteMarca=0 or p.Grupa_de_munca='C' and p.Tip_colab='FDP')
	order by p.nume
			
end try
begin catch
	set @eroare=ERROR_MESSAGE()+ ' ('+OBJECT_NAME(@@PROCID)+')'
	raiserror(@eroare,16,1)
end catch

-- exec sitComandaCarduriEdenredExcel 7
