
create procedure  wScriuConturiBanca @sesiune varchar(50), @parXML xml  
--> procedura de scriere a conturilor in banca din detalierea Terti --> Conturi in banca
as
declare @mesajeroare varchar(2000)
select @mesajeroare=''
begin try
	declare	@utilizator char(10), @sub char(9), @cod_eroare int
	
	EXEC wIaUtilizator @sesiune=@sesiune, @utilizator=@Utilizator OUTPUT
	if @utilizator is null
		return -1

	DECLARE @tert varchar(30),@cont_in_banca varchar(35),@banca varchar(20),@update bit,@numar_pozitie int
--sp_help contbanci
	select  
		@tert= isnull(@parXML.value('(/row/@tert)[1]','varchar(13)'),''),
		@banca= upper(isnull(@parXML.value('(/row/row/@banca)[1]','varchar(20)'),'')),
		@cont_in_banca= upper(isnull(@parXML.value('(/row/row/@cont_in_banca)[1]','varchar(35)'),'')),
		@update = isnull(@parXML.value('(/row/row/@update)[1]','bit'),0),
		@numar_pozitie = isnull(@parXML.value('(/row/row/@numar_pozitie)[1]','int'),0)
 
	if exists (select 1 from sys.objects where name='wScriuConturiBancaSP' and type='P')  
		exec wScriuConturiBancaSP @sesiune, @parXML
	
	exec luare_date_par 'GE', 'SUBPRO', 0, 0, @sub output
	
	-->validari:
		--> codul iban al contului sa respecte cel putin regula includerii codului bancar:
		if substring(replace(@cont_in_banca,' ',''),5,4)<>@banca
		raiserror('Codul iban al contului bancar este invalid! (Trebuie sa contina codul bancar - BIC - si sa aiba o lungime mai mare de 8 caractere!)',16,1)
		select @cod_eroare=dbo.verificIBAN(@cont_in_banca,0)
		select @cod_eroare
		select @mesajeroare=(case when @cod_eroare=100 then ''
				when @cod_eroare in (-1,-2) then 'Codul IBAN furnizat nu are lungimea corecta!'
				when @cod_eroare in (-99,-100) then 'Codul IBAN furnizat nu este valid - a esuat la verificarea cifrei de control!'
				else 'Eroare de validare cod IBAN! ' end)
		if len(@mesajeroare)>0 raiserror(@mesajeroare,16,1)
	-->modificare	
	if @update=1
	begin	
		update ContBanci set Banca=@banca, Cont_in_banca=@cont_in_banca
		where Subunitate=@sub and tert=@tert and Numar_pozitie=@numar_pozitie
	end	
	--> scriere
	else
	begin
		set @numar_pozitie=isnull((select MAX(numar_pozitie) from ContBanci),0)+1
		insert into ContBanci(Subunitate,Tert,Numar_pozitie,Banca,Cont_in_banca)
		select @sub,@tert,@numar_pozitie,@banca,@cont_in_banca
	end	
end try
begin catch
	set @mesajeroare = ERROR_MESSAGE() + ' (' + OBJECT_NAME(@@PROCID) + ')'
	raiserror(@mesajeroare, 11, 1)
end catch
