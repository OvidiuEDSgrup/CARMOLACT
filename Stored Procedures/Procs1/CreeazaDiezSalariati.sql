create procedure CreeazaDiezSalariati @numeTabela varchar(100)
AS
--	tabela utilizata in procedurile pentru calcule lunare (concedii de odihna, medicale, acord, lichidare).
if @numeTabela='#salariati'
Begin
	alter table #salariati
	add nume varchar(50) not null, cod_functie varchar(6) not null, loc_de_munca varchar(9) not null, 
		categoria_de_salarizare varchar(4) not null, grupa_de_munca varchar(1) not null, salar_de_incadrare float not null, salar_de_baza float not null,
		tip_salarizare varchar(1) not null, tip_impozitare varchar(1) not null, somaj_1 smallint not null,
		as_sanatate smallint not null, indemnizatia_de_conducere float not null, spor_vechime real not null,
		spor_de_noapte real not null, spor_sistematic_peste_program real not null, spor_de_functie_suplimentara float not null,
		spor_specific float not null, spor_conditii_1 float not null, spor_conditii_2 float not null, spor_conditii_3 float not null,
		spor_conditii_4 float not null, spor_conditii_5 float not null, spor_conditii_6 float not null,
		sindicalist bit not null, salar_lunar_de_baza float not null, 
		localitate varchar(30) not null, judet varchar(15) not null, strada varchar(25) not null, numar varchar(5) not null,
		cod_postal int not null, bloc varchar(10) not null, scara varchar(2) not null, etaj varchar(2) not null, apartament varchar(5) not null, sector smallint not null,
		zile_concediu_de_odihna_an smallint not null, vechime_totala datetime not null, mod_angajare varchar(1) not null, data_plec datetime not null, tip_colab varchar(3) not null
end
