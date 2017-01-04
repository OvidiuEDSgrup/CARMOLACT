Create procedure sitTicheteChequeDejeunerExcel @idRulare int = 0
as
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
set nocount on
DECLARE @utilizator VARCHAR(100), @sub varchar(100), @eroare varchar(1000), @datajos datetime, @datasus datetime, @parXML xml, @debug BIT, @cTextSelect NVARCHAR(max), 
		@tipoperatie char(1), @sesiune varchar(50), @utilizatorWindows VARCHAR(100), @multiFirma int,
		@Serii int

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

	select	@datajos = @parXML.value('(/*/@datajos)[1]', 'datetime'), 
			@datasus = @parXML.value('(/*/@datasus)[1]', 'datetime'), 
			@tipoperatie = @parXML.value('(/*/@tipoperatie)[1]', 'char(1)') 
	set @Serii=(case when @tipoperatie='S' then 1 else 0 end)

	SELECT max(nume) as [Nume], cnp as [Cod numeric personal] , sum(nr_tichete) as [Nr. de tichete], convert(decimal(12,2),valoare_unitara_tichet) as [Valoare nominala], max(denumire_lm) as [Compartiment]
	FROM fTichete_de_masa (@datajos, @datasus, null, 'Tip_operatie', '1', 0, 0, @tipoperatie, null, 0, null, null, 'T', null, null, @Serii, null)
	group BY cnp, convert(decimal(12,2),valoare_unitara_tichet), (case when @tipoperatie='S' then nr_tichete else 0 end)
	having sum(nr_tichete)>0
	order by max(denumire_lm), max(nume)

end try
begin catch
	set @eroare=ERROR_MESSAGE()+ ' ('+OBJECT_NAME(@@PROCID)+')'
	raiserror(@eroare,16,1)
end catch

-- exec sitTicheteChequeDejeunerExcel 7
