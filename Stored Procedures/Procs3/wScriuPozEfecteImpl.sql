/****** Object:  StoredProcedure [dbo].[wScriuPozEfecteImpl]    Script Date: 01/05/2011 22:59:01 ******/

--***
create procedure wScriuPozEfecteImpl  @sesiune varchar(50), @parXML xml
as
declare @iDoc int,@Sub char(9),@mesaj varchar(200),@update int,@lm char(8),@comanda char(20),@indbug char(20),@ComandaDeScris char(40),@utilizator varchar(30),@efect varchar(20),
		@tip varchar(2),@data datetime,@data_scadentei datetime	,@tert varchar(13),@valoare float,@tva_11 float,@tva_22 float,@valuta varchar(3),
		@curs float,@decontat float,@cont varchar(40),@data_decontarii datetime,@tiptert varchar(1),@sold_lei float,@o_tiptert varchar(1),@o_efect varchar(20),
		@o_tert varchar(13),@an_impl int,@luna_impl int,@mod_impl int,@valoare_valuta float,@decontat_valuta float,@valoare_lei float,@decontat_lei float,
		@sold_valuta float,@valtva_lei float,@valtva_valuta float,@mesajEroare varchar(200),@_cautare varchar(100), @explicatii varchar(30), @rulajelm int

begin try	
	select
		@update = isnull(@parXML.value('(/row/row/@update)[1]','bit'),0),
		@efect = isnull(@parXML.value('(/row/row/@efect)[1]','varchar(20)'),''),
		@tert = isnull(@parXML.value('(/row/row/@tert)[1]','varchar(13)'),''),	
		@tip = isnull(@parXML.value('(/row/@tip)[1]','varchar(2)'),''),
		@tiptert = isnull(@parXML.value('(/row/@tiptert)[1]','varchar(1)'),''),
		@data=ISNULL(@parXML.value('(/row/row/@data)[1]', 'datetime'), '1901-01-01'),
		@data_scadentei=ISNULL(@parXML.value('(/row/row/@data_scadentei)[1]', 'datetime'), '1901-01-01'),
		@data_decontarii=ISNULL(@parXML.value('(/row/row/@data_decontarii)[1]', 'datetime'), '1901-01-01'),
		@valoare=ISNULL(@parXML.value('(/row/row/@valoaree)[1]', 'float'), 0),
		@valuta=@parXML.value('(/row/row/@valuta)[1]', 'varchar(3)')  ,
		@curs=ISNULL(@parXML.value('(/row/row/@curs)[1]', 'float'), 0),
		@decontat=ISNULL(@parXML.value('(/row/row/@decontate)[1]', 'float'), 0),
		@cont=@parXML.value('(/row/row/@cont_efect)[1]', 'varchar(40)'),			
		@lm=@parXML.value('(/row/row/@lm)[1]', 'varchar(13)'),
		@comanda=isnull(@parXML.value('(/row/row/@comanda)[1]', 'varchar(40)'),''),
		@indbug=isnull(@parXML.value('(/row/row/@indbug)[1]', 'varchar(40)'),''),
		@explicatii=isnull(@parXML.value('(/row/row/@explicatii)[1]', 'varchar(30)'),''),
		@_cautare=isnull(@parXML.value('(/row/@_cautare)[1]', 'varchar(50)'), ''), 
		
		@o_tiptert = isnull(@parXML.value('(/row/row/@o_tiptert)[1]','varchar(1)'),''),
		@o_efect = isnull(@parXML.value('(/row/row/@o_efect)[1]','varchar(20)'),''),
		@o_tert = isnull(@parXML.value('(/row/row/@o_tert)[1]','varchar(13)'),'')
		
	set @rulajelm=isnull((select top 1 val_logica from par where tip_parametru='GE' and parametru='RULAJELM'),0)

	EXEC wIaUtilizator @sesiune=@sesiune, @utilizator=@utilizator OUTPUT
		
	exec luare_date_par 'GE', 'SUBPRO', 0, 0, @sub output
	exec luare_date_par 'GE', 'ANULIMPL', 0, @an_impl output, ''
	exec luare_date_par 'GE', 'LUNAIMPL', 0, @luna_impl output, ''
	exec luare_date_par 'GE', 'IMPLEMENT', @mod_impl output, 0, ''
	
	if YEAR(@data)>@an_impl or YEAR(@data)=@an_impl and MONTH(@data)>@luna_impl
		raiserror('Data efectului > data implementarii!',11,1)
		
	if @mod_impl=0
		raiserror('Modificarile pot fi efectuate doar daca sunteti in mod implementare!',11,1)	
	--rulaj pe lm
	if @rulajelm=1 and @lm=''
		raiserror('Loc de munca necompletat!',11,1)
	

--	validare campuri
	if @efect='' 
		raiserror('Introduceti numarul efectului!',11,1)
	if not exists (select 1 from Terti where Subunitate=@sub and Tert=@tert) 
		raiserror('Tert inexistent!',11,1)
	if @indbug<>'' and not exists (select 1 from indbug where Indbug=@indbug) 
		raiserror('Indicator bugetar inexistent!',11,1)
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
	if not exists (select 1 from conturi where Subunitate=@sub and Cont=@Cont and Sold_credit=8) 
	Begin
		set @mesajEroare='Contul trebuie sa fie atribuit '+'8 - Efecte'+'!'
		raiserror(@mesajEroare,11,1)
	End
	if @valuta<>'' and not exists (select 1 from valuta where Valuta=@valuta) 
		raiserror('Valuta inexistenta!',11,1)

	set @ComandaDeScris=@comanda+@indbug
		
	exec luare_date_par 'GE', 'SUBPRO', 0, 0, @sub output		
	set @valoare_lei=round((case when isnull(@valuta,'')='' then @valoare when isnull(@valuta,'')<>'' and isnull(@curs,0)<>0 then @valoare*@curs else 0 end),4)
	set @valoare_valuta=round((case when isnull(@valuta,'')='' then 0 when isnull(@valuta,'')<>'' and isnull(@curs,0)<>0 then @valoare else 0 end),4)
	set @decontat_lei=round((case when isnull(@valuta,'')='' then @decontat when isnull(@valuta,'')<>'' and isnull(@curs,0)<>0 then @decontat*@curs else 0 end),4)
	set @decontat_valuta=round((case when isnull(@valuta,'')='' then 0 when isnull(@valuta,'')<>'' and isnull(@curs,0)<>0 then @decontat else 0 end),4)
	
		
	set @sold_lei=round(@valoare_lei-@decontat_lei,4)
	set @sold_valuta=round(case when ISNULL(@valuta,'')<>'' and ISNULL(@curs,0)<>0 then @valoare_valuta-@decontat_valuta else 0 end,4)
		
	if @update=1
	begin
	select @decontat,@tiptert,@o_efect,@o_tert
		UPDATE efimpl set Nr_efect=(case when ISNULL(@efect,'')<>'' then @efect else Nr_efect end),
			Loc_de_munca=(case when @lm is not null then @lm else Loc_de_munca end),
			Tip=(case @tiptert when  'B' then 'I' when 'F' then 'P' else tip end),
			Tert=(case when ISNULL(@tert,'')<>'' then @tert else tert end),
			Data=@data,
			Data_scadentei=@data_scadentei,
			Valoare=@valoare_lei,
			Valuta=(case when @valuta is not null then @valuta else valuta end),
			Curs=(case when isnull(@valuta,'')<>'' then @curs else 0 end),
			Valoare_valuta=@valoare_valuta,
			decontat=@decontat_lei,
			Sold=@sold_lei,
			Cont=(case when @cont is not null then @cont else Cont end),
			decontat_valuta=@decontat_valuta,
			Sold_valuta=@sold_valuta,
			Comanda=(case when @ComandaDeScris is not null then @ComandaDeScris else Comanda end),
			data_decontarii=@data_decontarii,
			explicatii=@explicatii
		WHERE Subunitate=@Sub and tip=(case @tiptert when 'B' then 'I' when 'F' then 'P' else '' end)
			and Nr_efect=@o_efect and tert=@o_tert
	end
	else
	begin
	

		INSERT INTO efimpl(Subunitate, Tip, Tert, Nr_efect, Cont, Data, Data_scadentei, Valoare, Valuta, Curs, Valoare_valuta, Decontat, Sold, Decontat_valuta, Sold_valuta, Loc_de_munca, Comanda, 
							Data_decontarii,Explicatii)
		SELECT
			@sub,(case @tiptert when 'B' then 'I' when 'F' then 'P' else '' end), @Tert, @efect,@Cont,@Data,@Data_scadentei,
			@valoare_lei, isnull(@Valuta,''),@Curs,@valoare_valuta,
			@decontat_lei,@sold_lei,@decontat_valuta,
			@sold_valuta,isnull(@lm,''),@ComandaDeScris,@data_decontarii,@explicatii
	end
	declare @docXML xml
	set @docXML='<row tiptert="'+RTRIM(@tiptert)+'" _cautare="'+isnull(@_cautare,'')+'"/>'
	exec wIaPozEfecteImpl @sesiune=@sesiune, @parXML=@docXML
end try
begin catch
	set @mesaj = '(wScriuPozEfecteImpl): '+ERROR_MESSAGE()
	raiserror(@mesaj, 11, 1)	
end catch
--select * from factimpl
--sp_help factimpl
