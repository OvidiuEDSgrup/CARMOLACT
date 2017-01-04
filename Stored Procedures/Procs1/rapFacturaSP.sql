	/*
	Formular in lei

	pret_unitar =  pret_valuta*curs (daca este)
	tva_unitar= tva_fara discount(vezi mai jos)

	pret_vanzare = pret vanzare cu discount (discountat), totdeauna in LEI

	totalfaratva =cantitate*pret_vanzare
	totaltva = sum(tva_deductibil)

	total fara discount = pret_valuta*curs(daca este)*cantitate
	tva fara discount = pret_valuta*curs(daca este)*cantitate*cota_tva

	discount aplicat se ia prin diferenta (se afiseaza doar daca exista)

	Formular in valuta - daca tert = decontari in valuta (alt formular)
	- alta forma si formule
	- valorile se impart la curs



	EXEMPLU APEL 
		exec rapFacturaSP @sesiune='',@tip='AP', @numar='160018', @data='2014-09-03', @nrexemplare=1
	*/
create procedure rapFacturaSP (@sesiune varchar(50)=null, @tip varchar(2), @numar varchar(20), @data datetime)
as
begin try
	set transaction isolation level read uncommitted

	declare 
		@mesajEroare varchar(500)='',  @subunitate varchar(20),
		@nrmaxim int,	--> @nrmaxim = numarul maxim de documente pentru a evita blocarea serverului sau rularea formularului pe prea multe date,
		@idAntetBon int, @comandaSQL nvarchar(max), @dataFacturii datetime,
		@detalii xml, @data_expedierii datetime, @ora_expedierii varchar(5), @cData_expedierii varchar(30)

	exec rapFacturaSP_tabela
	exec rapFacturaSP_CB

end try
begin catch
	set @mesajEroare = ERROR_MESSAGE() + ' (' + OBJECT_NAME(@@PROCID) + ')'
end catch

if len(@mesajEroare)>0
	raiserror(@mesajEroare, 16, 1)