create procedure CreazaDiezPreturiAmanunt
AS
	
	alter table #preturiam
		add cota_tva decimal(5,2),pret_vanzare decimal(12,5), discount decimal(12,5), pret_amanunt decimal(12,5)
