Create procedure sitTicheteExcel @idRulare int = 0
as
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
set nocount on
DECLARE @utilizator VARCHAR(100), @sub varchar(100), @eroare varchar(1000), @datajos datetime, @datasus datetime, @tipoperatie char(1), 
		@parXML xml, @debug BIT, @cTextSelect NVARCHAR(max), @sesiune varchar(50), @utilizatorWindows VARCHAR(100), @multiFirma int

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
	
	if @multiFirma=1
		exec as login=RTRIM(@utilizatorWindows)

	if @parXML is null 
		raiserror('Eroare la citirea filtrelor. Detalii tehnice: parametrul XML nu exista!', 11, 1)
	
	select @datajos = @parXML.value('(/*/@datajos)[1]', 'datetime'), 
		@datasus = @parXML.value('(/*/@datasus)[1]', 'datetime'), 
		@tipoperatie = @parXML.value('(/*/@tipoperatie)[1]', 'char(1)') 

	select left(left(t.Nume,CHARINDEX(' ',t.Nume)-1),13) as Nume, substring(t.Nume,CHARINDEX(' ',t.Nume)+1,30) as Prenume, rtrim(CNP) CNP, 
		Zile_lucrate*(case when p.Salar_lunar_de_baza<>0 then p.Salar_lunar_de_baza else 8 end) as Ore,
		convert(int,Nr_tichete) as [Numar de tichete], Valoare_unitara_tichet as [Valoare nominala], Valoare_tichete as [Valoare totala], 
		left(rtrim(Denumire_lm),15) Departament, rtrim(isnull(p.tip_stat,ip.Religia)) as [Centru de cost]
	from dbo.fTichete_de_masa (@datajos, @datasus, null, '', '3', 0, 0, @tipoperatie, null, 0, null, null, 'T', null, null, 0, null) t
		left outer join personal p on p.Marca=t.Marca
		left outer join infoPers ip on ip.Marca=t.Marca
	where Nr_tichete>0
			
end try
begin catch
	set @eroare=ERROR_MESSAGE() + ' (sitTicheteExcel)'
	raiserror(@eroare,16,1)
end catch

-- exec sitComandaAprovizionare 7
