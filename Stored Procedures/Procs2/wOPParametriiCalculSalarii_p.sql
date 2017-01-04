--***
create procedure wOPParametriiCalculSalarii_p @sesiune varchar(50), @parXML XML
as   
begin try
	set transaction isolation level read uncommitted

	declare @utilizator varchar(20), @luna int, @an int, @datalunii datetime, @nLunaInch int, @nAnulInch int, 
			@oreLuna decimal(6), @nrmedol decimal(7,3), @salarMinim decimal(10), @salarMediu decimal(10), @cursEuroPensii decimal(6,4), 
			@casindiv decimal(6,3), @cassindiv decimal(6,3), @somajind decimal(6,3), 
			@casgr1 decimal(6,3), @casgr2 decimal(6,3), @casgr3 decimal(6,3), @cassunit decimal(6,3), @somajunit decimal(6,3), 
			@cci decimal(6,3), @fondgar decimal(6,3), @accmunca decimal(6,3), 
			@valtichet decimal(10,2), @nrtichete int, @indReferinta decimal(10), 
			@venitBrutCuDed decimal(10), @venitBrutFaraDed decimal(10), @dataVBCuDed datetime, @dataVBFaraDed datetime 
	exec wIaUtilizator @sesiune=@sesiune, @utilizator=@utilizator output

	set @nLunaInch=isnull((select max(val_numerica) from par where tip_parametru='PS' and parametru='LUNA-INCH'), 1)
	set @nAnulInch=isnull((select max(val_numerica) from par where tip_parametru='PS' and parametru='ANUL-INCH'), 1901)

	set @datalunii = ISNULL(@parXML.value('(/*/@datalunii)[1]', 'datetime'), '01/01/1901')
	set @luna = ISNULL(@parXML.value('(/*/@luna)[1]', 'int'), 0)
	set @an = ISNULL(@parXML.value('(/*/@an)[1]', 'int'), 0)

--	Daca exista linie cu luna de calcul salarii in grid, citim luna/anul din data lunii de calcul salarii.
	if @datalunii<>'01/01/1901'
		select @luna=month(@datalunii), @an=year(@datalunii)

--	Daca nu exista linie cu luna de calcul salarii in grid, citim luna urmatoare lunii inchise
	if @luna=0 and @nAnulInch>1901
		Select @luna=(case when @nLunaInch=12 then 1 else @nLunaInch+1 end),
			@An=(case when @nLunaInch=12 then @nAnulInch+1 else @nAnulInch end)

--	Daca nu este setat luna/an inchis, citim luna/anul curent
	if @luna=0
		select @luna=month(@datalunii), @an=year(@datalunii)

	set @datalunii=convert(datetime,str(@luna,2)+'/01/'+str(@an,4))
	set @datalunii=dbo.EOM(@datalunii)

	select	@oreLuna=max(case when parametru='ORE_LUNA' then val_numerica else 0 end),
			@nrmedol=max(case when parametru='NRMEDOL' then val_numerica else 0 end),
			@salarMinim=max(case when parametru='S-MIN-BR' then val_numerica else 0 end),
			@salarMediu=max(case when parametru='SALMBRUT' then val_numerica else 0 end),
			@cursEuroPensii=max(case when parametru='CURSEURPF' then val_numerica else 0 end),
			@casindiv=max(case when parametru='CASINDIV' then val_numerica else 0 end),
			@cassindiv=max(case when parametru='CASSIND' then val_numerica else 0 end),
			@somajind=max(case when parametru='SOMAJIND' then val_numerica else 0 end),
			@casgr1=max(case when parametru='CASGRUPA1' then val_numerica else 0 end),
			@casgr2=max(case when parametru='CASGRUPA2' then val_numerica else 0 end),
			@casgr3=max(case when parametru='CASGRUPA3' then val_numerica else 0 end),
			@cassunit=max(case when parametru='CASSUNIT' then val_numerica else 0 end),
			@somajunit=max(case when parametru='3.5%SOMAJ' then val_numerica else 0 end),
			@cci=max(case when parametru='COTACCI' then val_numerica else 0 end),
			@fondgar=max(case when parametru='FONDGAR' then val_numerica else 0 end),
			@accmunca=max(case when parametru='0.5%ACCM' then val_numerica else 0 end),
			@valtichet=max(case when parametru='VALTICHET' then val_numerica else 0 end),
			@nrtichete=max(case when parametru='NRTICHETE' then val_numerica else 0 end),
			@indReferinta=max(case when parametru='SOMAJ-ISR' then val_numerica else 0 end)
	from par_lunari where tip='PS' and data=@datalunii 
		and parametru in ('ORE_LUNA','NRMEDOL','S-MIN-BR','SALMBRUT',
			'CASINDIV','CASSIND','SOMAJIND','CASGRUPA1','CASGRUPA2','CASGRUPA3','CASSUNIT','3.5%SOMAJ','COTACCI','FONDGAR','0.5%ACCM',
			'VALTICHET','NRTICHETE','SOMAJ-ISR','VBCUDEDP','VBFDEDP','CURSEURPF')

	select 
		@venitBrutCuDed=max(case when Parametru='VBCUDEDP' then Val_numerica else 0 end),
		@venitBrutFaraDed=max(case when Parametru='VBFDEDP' then Val_numerica else 0 end),
		@dataVBCuDed=max(case when Parametru='VBCUDEDP' then data else 0 end),
		@dataVBFaraDed=max(case when Parametru='VBFDEDP' then data else 0 end)
	from (select data, parametru, val_numerica, RANK() over (partition by parametru order by data Desc) as ordine
		from par_lunari where tip='PS' and parametru in ('VBCUDEDP','VBFDEDP') and data<=@datalunii) p
	where Ordine=1
		
    select	@luna as luna, @an as an, @oreLuna as oreluna, @nrmedol as nrmedol, @salarMinim as salarminim, @salarMediu as salarmediu, @cursEuroPensii as curspensii,
			@casindiv as casindiv, @cassindiv as cassindiv, @casgr1 as casgr1, @casgr2 as casgr2, @casgr3 as casgr3, 
			@cassunit as cassunit, @somajunit as somajunit, @cci as cci, @fondgar as fondgar, @accmunca as accmunca,
			@valtichet as valtichet, @nrtichete as nrtichete, @indReferinta as indreferinta, 
			@venitBrutCuDed as vbcuded, @venitBrutFaraDed as vbfaraded, @dataVBCuDed as datavbcuded, @dataVBFaraDed as datavbfaraded
	for xml raw
    
end try

begin catch
	declare @mesajeroare varchar(500)
	set @mesajeroare='wOPParametriiCalculSalarii_p (linia '+convert(varchar(20),ERROR_LINE())+') :'+char(10)+ERROR_MESSAGE()
	raiserror(@mesajeroare, 16, 1)
end catch
