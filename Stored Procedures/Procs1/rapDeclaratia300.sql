--***
Create procedure rapDeclaratia300 @sesiune varchar(50)=null, @datajos datetime, @datasus datetime='2999-1-1', @dataSet varchar(3)
as
begin try
	declare @utilizator varchar(20), @multiFirma int, @lmFiltru varchar(9), @lmUtilizator varchar(9)

	exec wIaUtilizator @sesiune = @sesiune, @utilizator = @utilizator output

	set @multiFirma=0
	if exists (select * from sysobjects where name ='par' and xtype='V')
		set @multiFirma=1
	select @lmFiltru=isnull(min(Cod),'') from LMfiltrare where utilizator=@utilizator and cod in (select cod from lm where Nivel=1)
	if @multiFirma=1
		set @lmUtilizator=@lmFiltru

	if @dataSet='R'	--	Date\valori raportare
	begin
		select	left(capitol,1) as capitol, 
				capitol as subcapitol,
				rtrim(rand_decont) as rand_decont, 
				rtrim(denumire_indicator) as denumire_indicator, 
				valoare, tva
		from deconttva 
		where data between @datajos and @datasus 
			and Rand_decont not in ('NREVIDPL','CEREALE','INTERNE','RAMBURSTVA','CONSOLE','DISPOZITIV','TELEFOANE','50','51','52','53','54','53.1','54.1','55','56','57')
			and (@multiFirma=0 or Loc_de_munca=@lmUtilizator)
		order by capitol, 
			convert(int,(case when CHARINDEX('.',Rand_decont)<>0 then LEFT(Rand_decont,CHARINDEX('.',Rand_decont)-1) else Rand_decont end))	
	end

	if @dataSet='F'	--	Facturi
	begin
		select	max(case when rand_decont='50' then rtrim(convert(char(10),Valoare)) else '' end) as rand1,  
				max(case when rand_decont='51' then rtrim(convert(char(10),Valoare)) else '' end) as rand2,  
				max(case when rand_decont='52' then rtrim(convert(char(10),TVA)) else '' end) as rand3,
				max(case when rand_decont='55' then rtrim(convert(char(10),Valoare)) else '' end) as rand4,  
				max(case when rand_decont='56' then rtrim(convert(char(10),Valoare)) else '' end) as rand5,  
				max(case when rand_decont='57' then rtrim(convert(char(10),TVA)) else '' end) as rand6
		from deconttva
		where data between @datajos and @datasus 
			and rand_decont in ('50','51','52','55','56','57')
			and (@multiFirma=0 or Loc_de_munca=@lmUtilizator)
		group by data
	end

	if @dataSet='TLI'	--sold TVA la incasare
	begin
		select left(capitol,1) as capitol, capitol as subcapitol,
			rtrim(rand_decont) as rand_decont, 
			rtrim(denumire_indicator) as denumire_indicator, 
			valoare, tva
		from deconttva 
		where data between @datajos and @datasus 
			and Rand_decont in ('53','53.1','54','54.1')
			and (@multiFirma=0 or Loc_de_munca=@lmUtilizator)
		order by capitol, Rand_decont
	end
end try

begin catch
	declare @eroare varchar(8000)
	set @eroare=ERROR_MESSAGE() + ' ('+object_name(@@procid)+', linia '+convert(varchar(20),ERROR_LINE())+')'
	raiserror(@eroare, 16, 1)
end catch
