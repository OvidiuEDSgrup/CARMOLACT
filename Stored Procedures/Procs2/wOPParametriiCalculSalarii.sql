--***
create procedure wOPParametriiCalculSalarii @sesiune varchar(50), @parXML XML
as   
begin try
	set transaction isolation level read uncommitted

	declare @utilizator varchar(20), @luna int, @an int, @datalunii datetime, 
			@oreLuna decimal(6), @nrmedol decimal(7,3), @salarMinim decimal(10), @salarMediu decimal(10), @cursEuroPensii decimal(6,4), 
			@casindiv decimal(6,3), @cassindiv decimal(6,3), @somajind decimal(6,3), 
			@casgr1 decimal(6,3), @casgr2 decimal(6,3), @casgr3 decimal(6,3), @cassunit decimal(6,3), @somajunit decimal(6,3), 
			@cci decimal(6,3), @fondgar decimal(6,3), @accmunca decimal(6,3), 
			@valtichet decimal(10,2), @nrtichete int, @indReferinta decimal(10), 
			@venitBrutCuDed decimal(10), @venitBrutFaraDed decimal(10), @dataVBCuDed datetime, @dataVBFaraDed datetime, 
			@denpar varchar(100), @vallogica int, @valnum float, @valalfa varchar(1000)
	exec wIaUtilizator @sesiune=@sesiune, @utilizator=@utilizator output

	set @datalunii = ISNULL(@parXML.value('(/*/@datalunii)[1]', 'datetime'), '')
	set @luna = ISNULL(@parXML.value('(/*/@luna)[1]', 'int'), 0)
	set @an = ISNULL(@parXML.value('(/*/@an)[1]', 'int'), 0)
	if @luna<>0 and @an<>0
		set @datalunii=convert(datetime,str(@luna,2)+'/01/'+str(@an,4))
	set @datalunii=dbo.EOM(@datalunii)
	if @luna=0 
		select @luna=month(@datalunii), @an=year(@datalunii)

	select	@cursEuroPensii=@parXML.value('(/*/@curspensii)[1]','decimal(6,4)'),
			@oreLuna=@parXML.value('(/*/@oreluna)[1]','decimal(10)'),
			@nrmedol=@parXML.value('(/*/@nrmedol)[1]','decimal(7,3)'),
			@salarMinim=@parXML.value('(/*/@salarminim)[1]','decimal(10)'),
			@salarMediu=@parXML.value('(/*/@salarmediu)[1]','decimal(10)'),
			@casindiv=@parXML.value('(/*/@casindiv)[1]','decimal(6,3)'),
			@cassindiv=@parXML.value('(/*/@cassindiv)[1]','decimal(6,3)'),
			@somajind=@parXML.value('(/*/@somajind)[1]','decimal(6,3)'),
			@casgr1=@parXML.value('(/*/@casgr1)[1]','decimal(6,3)'),
			@casgr2=@parXML.value('(/*/@casgr2)[1]','decimal(6,3)'),
			@casgr3=@parXML.value('(/*/@casgr3)[1]','decimal(6,3)'),
			@cassunit=@parXML.value('(/*/@cassunit)[1]','decimal(6,3)'),
			@somajunit=@parXML.value('(/*/@somajunit)[1]','decimal(6,3)'),
			@cci=@parXML.value('(/*/@cci)[1]','decimal(6,3)'),
			@fondgar=@parXML.value('(/*/@fondgar)[1]','decimal(6,3)'),
			@accmunca=@parXML.value('(/*/@accmunca)[1]','decimal(6,3)'),
			@valtichet=@parXML.value('(/*/@valtichet)[1]','decimal(6,2)'),
			@nrtichete=@parXML.value('(/*/@nrtichete)[1]','int'),
			@indReferinta=@parXML.value('(/*/@indreferinta)[1]','decimal(10)'),
			@venitBrutCuDed=@parXML.value('(/*/@vbcuded)[1]','decimal(10)'),
			@venitBrutFaraDed=@parXML.value('(/*/@vbfaraded)[1]','decimal(10)')

	select 
		@dataVBCuDed=max(case when Parametru='VBCUDEDP' then data else 0 end),
		@dataVBFaraDed=max(case when Parametru='VBFDEDP' then data else 0 end)
	from (select data, parametru, val_numerica, RANK() over (partition by parametru order by data Desc) as ordine
		from par_lunari where tip='PS' and parametru in ('VBCUDEDP','VBFDEDP') and data<=@datalunii) p
	where Ordine=1

	select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica,@valalfa=val_alfanumerica
	from par_lunari where tip='PS' and parametru='CURSEURPF' and data=@datalunii
	if @denpar is null
		select @denpar='Curs EURO pensii facultative', @valalfa='Curs EURO pensii facultative'
	exec setare_par_lunari @data=@datalunii, @tip='PS', @par='CURSEURPF', @denp=@denpar, @val_l=@vallogica, @val_n=@cursEuroPensii, @val_a=@valalfa, @val_d='01/01/1901'

	select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica,@valalfa=val_alfanumerica
	from par_lunari where tip='PS' and parametru='VALTICHET' and data=@datalunii
	exec setare_par_lunari @data=@datalunii, @tip='PS', @par='VALTICHET', @denp=@denpar, @val_l=@vallogica, @val_n=@valtichet, @val_a=@valalfa, @val_d='01/01/1901'

	select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica,@valalfa=val_alfanumerica
	from par_lunari where tip='PS' and parametru='NRTICHETE' and data=@datalunii
	exec setare_par_lunari @data=@datalunii, @tip='PS', @par='NRTICHETE', @denp=@denpar, @val_l=@vallogica, @val_n=@nrtichete, @val_a=@valalfa, @val_d='01/01/1901'

/*
	select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica,@valalfa=val_alfanumerica
	from par_lunari where tip='PS' and parametru='ORE_LUNA' and data=@datalunii
	exec setare_par_lunari @data=@datalunii, @tip='PS', @par='ORE_LUNA', @denp=@denpar, @val_l=@vallogica, @val_n=@oreLuna, @val_a=@valalfa, @val_d='01/01/1901'

	select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica,@valalfa=val_alfanumerica
	from par_lunari where tip='PS' and parametru='NRMEDOL' and data=@datalunii
	exec setare_par_lunari @data=@datalunii, @tip='PS', @par='NRMEDOL', @denp=@denpar, @val_l=@vallogica, @val_n=@nrmedol, @val_a=@valalfa, @val_d='01/01/1901'

	select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica,@valalfa=val_alfanumerica
	from par_lunari where tip='PS' and parametru='S-MIN-BR' and data=@datalunii
	exec setare_par_lunari @data=@datalunii, @tip='PS', @par='S-MIN-BR', @denp=@denpar, @val_l=@vallogica, @val_n=@salarMinim, @val_a=@valalfa, @val_d='01/01/1901'

	select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica,@valalfa=val_alfanumerica
	from par_lunari where tip='PS' and parametru='SALMBRUT' and data=@datalunii
	exec setare_par_lunari @data=@datalunii, @tip='PS', @par='SALMBRUT', @denp=@denpar, @val_l=@vallogica, @val_n=@salarMediu, @val_a=@valalfa, @val_d='01/01/1901'

	select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica,@valalfa=val_alfanumerica
	from par_lunari where tip='PS' and parametru='CASINDIV' and data=@datalunii
	exec setare_par_lunari @data=@datalunii, @tip='PS', @par='CASINDIV', @denp=@denpar, @val_l=@vallogica, @val_n=@casindiv, @val_a=@valalfa, @val_d='01/01/1901'

	select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica,@valalfa=val_alfanumerica
	from par_lunari where tip='PS' and parametru='CASSIND' and data=@datalunii
	exec setare_par_lunari @data=@datalunii, @tip='PS', @par='CASSIND', @denp=@denpar, @val_l=@vallogica, @val_n=@cassindiv, @val_a=@valalfa, @val_d='01/01/1901'

	select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica,@valalfa=val_alfanumerica
	from par_lunari where tip='PS' and parametru='SOMAJIND' and data=@datalunii
	exec setare_par_lunari @data=@datalunii, @tip='PS', @par='SOMAJIND', @denp=@denpar, @val_l=@vallogica, @val_n=@somajind, @val_a=@valalfa, @val_d='01/01/1901'

	select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica,@valalfa=val_alfanumerica
	from par_lunari where tip='PS' and parametru='CASGRUPA1' and data=@datalunii
	exec setare_par_lunari @data=@datalunii, @tip='PS', @par='CASGRUPA1', @denp=@denpar, @val_l=@vallogica, @val_n=@casgr1, @val_a=@valalfa, @val_d='01/01/1901'

	select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica,@valalfa=val_alfanumerica
	from par_lunari where tip='PS' and parametru='CASGRUPA2' and data=@datalunii
	exec setare_par_lunari @data=@datalunii, @tip='PS', @par='CASGRUPA2', @denp=@denpar, @val_l=@vallogica, @val_n=@casgr2, @val_a=@valalfa, @val_d='01/01/1901'

	select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica,@valalfa=val_alfanumerica
	from par_lunari where tip='PS' and parametru='CASGRUPA3' and data=@datalunii
	exec setare_par_lunari @data=@datalunii, @tip='PS', @par='CASGRUPA3', @denp=@denpar, @val_l=@vallogica, @val_n=@casgr3, @val_a=@valalfa, @val_d='01/01/1901'

	select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica,@valalfa=val_alfanumerica
	from par_lunari where tip='PS' and parametru='CASSUNIT' and data=@datalunii
	exec setare_par_lunari @data=@datalunii, @tip='PS', @par='CASSUNIT', @denp=@denpar, @val_l=@vallogica, @val_n=@cassunit, @val_a=@valalfa, @val_d='01/01/1901'

	select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica,@valalfa=val_alfanumerica
	from par_lunari where tip='PS' and parametru='3.5%SOMAJ' and data=@datalunii
	exec setare_par_lunari @data=@datalunii, @tip='PS', @par='3.5%SOMAJ', @denp=@denpar, @val_l=@vallogica, @val_n=@somajunit, @val_a=@valalfa, @val_d='01/01/1901'

	select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica,@valalfa=val_alfanumerica
	from par_lunari where tip='PS' and parametru='COTACCI' and data=@datalunii
	exec setare_par_lunari @data=@datalunii, @tip='PS', @par='COTACCI', @denp=@denpar, @val_l=@vallogica, @val_n=@cci, @val_a=@valalfa, @val_d='01/01/1901'

	select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica,@valalfa=val_alfanumerica
	from par_lunari where tip='PS' and parametru='COTACCI' and data=@datalunii
	exec setare_par_lunari @data=@datalunii, @tip='PS', @par='COTACCI', @denp=@denpar, @val_l=@vallogica, @val_n=@cci, @val_a=@valalfa, @val_d='01/01/1901'

	select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica,@valalfa=val_alfanumerica
	from par_lunari where tip='PS' and parametru='FONDGAR' and data=@datalunii
	exec setare_par_lunari @data=@datalunii, @tip='PS', @par='FONDGAR', @denp=@denpar, @val_l=@vallogica, @val_n=@fondgar, @val_a=@valalfa, @val_d='01/01/1901'

	select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica,@valalfa=val_alfanumerica
	from par_lunari where tip='PS' and parametru='0.5%ACCM' and data=@datalunii
	exec setare_par_lunari @data=@datalunii, @tip='PS', @par='0.5%ACCM', @denp=@denpar, @val_l=@vallogica, @val_n=@accmunca, @val_a=@valalfa, @val_d='01/01/1901'

	select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica,@valalfa=val_alfanumerica
	from par_lunari where tip='PS' and parametru='SOMAJ-ISR' and data=@datalunii
	exec setare_par_lunari @data=@datalunii, @tip='PS', @par='SOMAJ-ISR', @denp=@denpar, @val_l=@vallogica, @val_n=@indReferinta, @val_a=@valalfa, @val_d='01/01/1901'

	select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica,@valalfa=val_alfanumerica
	from par_lunari where tip='PS' and parametru='VBCUDEDP' and data=@datalunii
	exec setare_par_lunari @data=@dataVBCuDed, @tip='PS', @par='VBCUDEDP', @denp=@denpar, @val_l=@vallogica, @val_n=@venitBrutCuDed, @val_a=@valalfa, @val_d='01/01/1901'

	select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica,@valalfa=val_alfanumerica
	from par_lunari where tip='PS' and parametru='VBFDEDP' and data=@datalunii
	exec setare_par_lunari @data=@dataVBFaraDed, @tip='PS', @par='VBFDEDP', @denp=@denpar, @val_l=@vallogica, @val_n=@venitBrutFaraDed, @val_a=@valalfa, @val_d='01/01/1901'
*/  
end try

begin catch
	declare @mesajeroare varchar(500)
	set @mesajeroare='wOPParametriiCalculSalarii (linia '+convert(varchar(20),ERROR_LINE())+') :'+char(10)+ERROR_MESSAGE()
	raiserror(@mesajeroare, 16, 1)
end catch
