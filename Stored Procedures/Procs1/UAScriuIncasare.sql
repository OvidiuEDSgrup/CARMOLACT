
/****** Object:  StoredProcedure [dbo].[UAScriuIncasare]    Script Date: 01/05/2011 23:35:59 ******/
--***
create procedure UAScriuIncasare (@partip char(2),@partipinc char(3),@parnrchit char(8) output,@pardata datetime,@parabonat char(13),
	@parlm char(9),@par_id_fact int output,@parsuma decimal(12,2),@parpen decimal(12,2),@parcompen bit,@parcasier varchar(13),@parcontract char(8),@paruser char(20),@parteren bit,@parexplicatii varchar(200))
as 
begin
declare @partipdoc char(2)
set @partipdoc=(case when @partip='CP' then 'UP' else 'UI' end)
--@partip char(2)(IF-incasare factura,IA-incasare avans,CP-compensare)
--@partipinc char(2)(tipuri de incasari din tabela de incasari)
--@partipdoc char(2)(UI=incasare,UP=compensare)
Declare @nrchit char(8),@nrtemp int,@nrfact char(8),@existanumar int,@id int,@explicatii varchar(30),
@comanda char(20),@cont char(13),@mesajeroare varchar(200),@mesajBun varchar(200),@mesaj varchar(200)

begin try
	--chitanta
	if @parnrchit=''
	begin
		set @nrtemp=0
		exec wIauNrDocUA @partipdoc,@parcasier,@parlm ,@nrtemp output
		if @nrtemp>99999999 or @nrtemp=0
		begin
			set @mesaj='Eroare la obtinerea nr. de document!'
			raiserror(@mesaj,11,1)
			return -1
		end
		else
			begin
			set @nrchit=(CAST(@nrtemp as CHAR(8)))
			set @parnrchit=@nrchit
			end
		set @existanumar=(select COUNT(document) from IncasariFactAbon where document=@nrchit and data between dbo.BOY(@pardata) and dbo.EOY(@pardata) and ((@partipdoc='UP' and tip='CP') or (@partipdoc='UI' and tip in ('IF','IA') )))
	end
	else
	begin
		set @nrchit=@parnrchit
		set @existanumar=(select COUNT(document) from IncasariFactAbon where document=@nrchit and data between dbo.BOY(@pardata) and dbo.EOY(@pardata) and abonat<>@parabonat and data<>@pardata and ((@partipdoc='UP' and tip='CP') or (@partipdoc='UI' and tip in ('IF','IA') )))
	end
	if @existanumar>0
	begin
		set @mesaj='Eroare la obtinerea nr. de document!'
		raiserror(@mesaj,11,1)
		return -1
	end	
	
	--luam contul in functie de tipul de incasare
	select @cont=Cont_specific from Tipuri_de_incasare where ID=@partipinc
	
	--scrierea documentelor
	if @parlm=''
	begin
	set @parlm=isnull((select Loc_de_munca from antetfactabon where Id_factura=@par_id_fact),'') 
	end
	
	declare @pen decimal(12,2),@sum decimal(12,2),@sold_fact decimal(12,2),@sold_pen_fact decimal(12,2),
			@sold_ramas decimal(12,3),@sold_pen_ramas decimal(12,3)
		
	if @parpen=0
		if @partip='IF' or (@partip='CP' and @parcompen=1)
		begin	
			set @sold_fact=ISNULL((select convert(decimal(12,2),sold) from FactAbon where id_factura=@par_id_fact),0)
			set @sold_pen_fact=ISNULL((select convert(decimal(12,2),sold_penalizari) from FactAbon where id_factura=@par_id_fact),0)
			
			if (@parsuma>@sold_fact and @sold_fact>0) or (@parsuma<@sold_fact and @sold_fact<0)
			begin			
				set @mesajeroare='Eroare la scriere incasare: Suma incasata este mai mare decat soldul facturii'		
				raiserror(@mesajeroare,11,1)
				return -1
			end
			else
			begin
				set @sum=@parsuma
				if (select Val_logica from par where Tip_parametru='UA' and parametru='ORDINC-FP')=1--daca prima data se plateste factura si apoi penalizarile
				begin
					if @sold_fact-@sold_pen_fact>0
						if (@parsuma-(@sold_fact-@sold_pen_fact))>0 set @pen=(case when (@parsuma-(@sold_fact-@sold_pen_fact))>@sold_pen_fact then @sold_pen_fact else (@parsuma-(@sold_fact-@sold_pen_fact)) end)
						else set @pen=0
					else 
						if (@parsuma-(@sold_fact-@sold_pen_fact))<0 set @pen=(case when (@parsuma-(@sold_fact-@sold_pen_fact))<@sold_pen_fact then (@parsuma-(@sold_fact-@sold_pen_fact)) else @sold_pen_fact end)
						else set @pen=0
				end
			else
				if @sold_fact-@sold_pen_fact>0
					if (@parsuma<@sold_pen_fact) set @pen=@parsuma else set @pen=@sold_pen_fact
				else
					if (@parsuma<@sold_pen_fact) set @pen=@sold_pen_fact else set @pen=@parsuma
			end
		end
		else
		begin
			set @sum=@parsuma
			set @pen=0
		end
	else
	begin
		set @sum=@parsuma
		set @pen=@parpen
	end
	set @explicatii=(case when @partip='IA' then 'Inc.avans' when @partip='IF' then 'Inc.factura' else 'Compensare' end)+':'+(select max(rtrim(factura)+' '+tip) from antetfactabon where id_factura=@par_id_fact)
	insert into incasariFactAbon(Tip,Tip_incasare,explicatii,document,data,abonat,loc_de_munca,comanda,id_factura,suma,penalizari,
		Teren,Cont,Casier,Utilizator,Data_operarii,Val1,Val2,Val3,Alfa1,Alfa2,Alfa3,Data1,data2)
	values(@partip,@partipinc,@parexplicatii,@nrchit,@pardata,@parabonat,@parlm,'',@par_id_fact,@sum,@pen,
		@parteren,@cont,@parcasier,@paruser,GETDATE(),0,0,0,'','','','1901-01-01','1901-01-01')

end try
begin catch
	set @mesaj = ERROR_MESSAGE()
	raiserror(@mesaj, 11, 1)	
end catch

end 