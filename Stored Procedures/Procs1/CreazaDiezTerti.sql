create procedure CreazaDiezTerti @numeTabela varchar(50)
AS
begin	
	if 	@numeTabela='#tertiVies'
		alter table #tertiVies
		add tara varchar(20), cod_fiscal varchar(20), valid varchar(50), requestIdentifier varchar(50)
	/*      pentru cereri informare TVA de la ANAF    */
	if 	@numeTabela='#informTVA'
		alter table #informTVA
		add denumire varchar(250), data_ora datetime, data_raportare datetime, tip varchar(4), is_tva INT, is_tli int, adresa varchar(200), valid int, dela datetime
	if 	@numeTabela='#validCUI'
		alter table #validCUI
		add den_eroare varchar(250), cod_eroare int, den_tert varchar(250)
end
