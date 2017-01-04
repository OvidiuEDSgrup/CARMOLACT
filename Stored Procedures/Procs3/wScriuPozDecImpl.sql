--***
create procedure wScriuPozDecImpl @sesiune varchar(50), @parXML xml
as
declare @Sub char(9), @mesaj varchar(2000), @update int, @lm char(9), @comanda char(20), @indbug char(20), @ComandaDeScris char(40), @utilizator varchar(30), 
		@marca varchar(6), @decont varchar(20), @cont varchar(40), @tip varchar(2), @data datetime, @data_scadentei datetime, 
		@valoare float, @valuta varchar(3), @curs float, @decontat float, @data_ultimei_decontari datetime, @sold_lei float, 
		@o_decont varchar(20), @o_marca varchar(13), @an_impl int, @luna_impl int, @mod_impl int, @valoare_valuta float, @decontat_valuta float, @valoare_lei float, @decontat_lei float,
		@sold_valuta float, @mesajEroare varchar(2000), @_cautare varchar(100), @explicatii varchar(30), @rulajelm int
	
begin try	
	select
		@update = isnull(@parXML.value('(/row/row/@update)[1]','bit'),0),
		@decont = isnull(@parXML.value('(/row/row/@decont)[1]','varchar(20)'),''),
		@marca = isnull(@parXML.value('(/row/row/@marca)[1]','varchar(6)'),''),	
		@cont=@parXML.value('(/row/row/@cont)[1]', 'varchar(40)'),			
		@tip = isnull(@parXML.value('(/row/@tip)[1]','varchar(2)'),''),
		@data=ISNULL(@parXML.value('(/row/row/@data)[1]', 'datetime'), '1901-01-01'),
		@data_scadentei=ISNULL(@parXML.value('(/row/row/@data_scadentei)[1]', 'datetime'), '1901-01-01'),
		@data_ultimei_decontari=ISNULL(@parXML.value('(/row/row/@data_ultimei_decontari)[1]', 'datetime'), '1901-01-01'),
		@valoare=ISNULL(@parXML.value('(/row/row/@valoared)[1]', 'float'), 0),
		@valuta=@parXML.value('(/row/row/@valuta)[1]', 'varchar(3)')  ,
		@curs=ISNULL(@parXML.value('(/row/row/@curs)[1]', 'float'), 0),
		@decontat=ISNULL(@parXML.value('(/row/row/@decontatd)[1]', 'float'), 0),
		@lm=@parXML.value('(/row/row/@lm)[1]', 'varchar(13)'),
		@comanda=isnull(@parXML.value('(/row/row/@comanda)[1]', 'varchar(40)'),''),
		@indbug=isnull(@parXML.value('(/row/row/@indbug)[1]', 'varchar(40)'),''),
		@_cautare=isnull(@parXML.value('(/row/@_cautare)[1]', 'varchar(50)'), ''), 
		@explicatii=isnull(@parXML.value('(/row/@explicatii)[1]', 'varchar(30)'), ''),
		
		@o_decont = isnull(@parXML.value('(/row/row/@o_decont)[1]','varchar(20)'),''),
		@o_marca = isnull(@parXML.value('(/row/row/@o_marca)[1]','varchar(13)'),'')
		
	EXEC wIaUtilizator @sesiune=@sesiune, @utilizator=@utilizator OUTPUT
		
	set @rulajelm=isnull((select top 1 val_logica from par where tip_parametru='GE' and parametru='RULAJELM'),0)
	exec luare_date_par 'GE', 'SUBPRO', 0, 0, @sub output
	exec luare_date_par 'GE', 'ANULIMPL', 0, @an_impl output, ''
	exec luare_date_par 'GE', 'LUNAIMPL', 0, @luna_impl output, ''
	exec luare_date_par 'GE', 'IMPLEMENT', @mod_impl output, 0, ''
	
	if YEAR(@data)>@an_impl or YEAR(@data)=@an_impl and MONTH(@data)>@luna_impl
		raiserror('Data decontului > data implementarii!',11,1)
		
	if @mod_impl=0
		raiserror('Modificarile pot fi efectuate doar daca sunteti in mod implementare!',11,1)	

--	validare campuri
	if @decont='' 
		raiserror('Introduceti numarul decontului!',11,1)
	if not exists (select 1 from personal where Marca=@marca) 
		raiserror('Marca inexistenta!',11,1)
	if @indbug<>'' and not exists (select 1 from indbug where Indbug=@indbug) 
		raiserror('Indicator bugetar inexistent!',11,1)
	if @rulajelm=1 and @lm=''
	begin
		select @lm=loc_de_munca from personal where marca=@marca
		if @lm=''
			raiserror('Loc de munca necompletat!',11,1)
	end
	if @lm<>'' and not exists (select 1 from lm where Cod=@lm) 
		raiserror('Loc de munca inexistent!',11,1)
	if @comanda<>'' and not exists (select 1 from Comenzi where Subunitate=@sub and Comanda=@comanda) 
		raiserror('Comanda inexistenta!',11,1)
	if @Cont='' 
		raiserror('Cont necompletat!',11,1)
	if not exists (select 1 from conturi where Subunitate=@sub and Cont=@Cont) 
		raiserror('Cont inexistent!',11,1)
	if exists (select 1 from conturi where Subunitate=@sub and Cont=@Cont and Are_analitice=1) 
		raiserror('Contul are analitice!',11,1)
	if not exists (select 1 from conturi where Subunitate=@sub and Cont=@Cont and Sold_credit=9) 
	Begin
		set @mesajEroare='Contul trebuie sa fie atribuit 9-Deconturi!'
		raiserror(@mesajEroare,11,1)
	End
	if @valuta<>'' and not exists (select 1 from valuta where Valuta=@valuta) 
		raiserror('Valuta inexistenta!',11,1)

	set @ComandaDeScris=@comanda+@indbug
		
	set @valoare_lei=round((case when isnull(@valuta,'')='' then @valoare when isnull(@valuta,'')<>'' and isnull(@curs,0)<>0 then @valoare*@curs else 0 end),4)
	set @valoare_valuta=round((case when isnull(@valuta,'')='' then 0 when isnull(@valuta,'')<>'' and isnull(@curs,0)<>0 then @valoare else 0 end),4)
	set @decontat_lei=round((case when isnull(@valuta,'')='' then @decontat when isnull(@valuta,'')<>'' and isnull(@curs,0)<>0 then @decontat*@curs else 0 end),4)
	set @decontat_valuta=round((case when isnull(@valuta,'')='' then 0 when isnull(@valuta,'')<>'' and isnull(@curs,0)<>0 then @decontat else 0 end),4)
		
	set @sold_lei=round(@valoare_lei-@decontat_lei,4)
	set @sold_valuta=round(case when ISNULL(@valuta,'')<>'' and ISNULL(@curs,0)<>0 then @valoare_valuta-@decontat_valuta else 0 end,4)
		
	if @update=1
	begin
		UPDATE decimpl set Tip='T',
			Marca=(case when ISNULL(@marca,'')<>'' then @marca else marca end),
			Decont=(case when ISNULL(@decont,'')<>'' then @decont else decont end),
			Cont=(case when @cont is not null then @cont else cont end),
			Data=@data,
			Data_scadentei=@data_scadentei,
			Valoare=@valoare_lei,
			Valuta=(case when @valuta is not null then @valuta else valuta end),
			Curs=(case when isnull(@valuta,'')<>'' then @curs else 0 end),
			Valoare_valuta=@valoare_valuta,
			Decontat=@decontat_lei,
			Sold=@sold_lei,
			Decontat_valuta=@decontat_valuta,
			Sold_valuta=@sold_valuta,
			Loc_de_munca=(case when @lm is not null then @lm else Loc_de_munca end),
			Comanda=(case when @ComandaDeScris is not null then @ComandaDeScris else Comanda end),
			Data_ultimei_decontari=@data_ultimei_decontari,
			Explicatii=@explicatii
		WHERE Subunitate=@Sub and tip='T' and decont=@o_decont and marca=@o_marca
	end
	else
	begin
		INSERT INTO decimpl (Subunitate, Tip, Marca, Decont, Cont, Data, Data_scadentei,
			Valoare, Valuta, Curs, Valoare_valuta, Decontat, Sold, Decontat_valuta,
			Sold_valuta, Loc_de_munca, Comanda, Data_ultimei_decontari, Explicatii)
		SELECT
			@sub, 'T', @marca, @decont, @Cont, @Data, @Data_scadentei,
			@valoare_lei, isnull(@Valuta,''), @Curs, @valoare_valuta,
			@decontat_lei, @sold_lei, @decontat_valuta, @sold_valuta, isnull(@lm,''), @ComandaDeScris, @data_ultimei_decontari, @explicatii
	end

	declare @docXML xml
	set @docXML='<row _cautare="'+isnull(@_cautare,'')+'"/>'
	exec wIaPozDecImpl @sesiune=@sesiune, @parXML=@docXML
end try
begin catch
	set @mesaj = '(wScriuPozDecImpl): '+ERROR_MESSAGE()
	raiserror(@mesaj, 11, 1)	
end catch
--select * from decimpl
--sp_help decimpl
