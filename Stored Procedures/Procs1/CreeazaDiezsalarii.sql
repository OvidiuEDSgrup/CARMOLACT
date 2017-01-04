create procedure CreeazaDiezsalarii @numeTabela varchar(100)
As
if @numeTabela='#rapCOAn'
begin
	alter table #rapCOAn
	add marca char(6), nume char(50), lm char(9), den_lm char(30), grupa_de_munca char(1), vechime_totala datetime, 
	vechime_in_ani int, data_angajarii datetime, loc_ramas_vacant int, data_plecarii datetime, 
	zile_co_an int, zile_co_suplim_an int, zile_co_neefectuat_an_ant int, zile_co_efectuat_in_luna int, zile_co_efectuat_din_an_ant int, zile_co_efectuat_an int, 
	prima_de_concediu float, indemnizatie_co_an int, indemnizatie_co_luna_curenta float, co_incasat float, zile_co_cuvenite_an int, zile_co_cuvenite_la_luna int, 
	zile_co_cuvenite int, zile_co_ramase int, grupare char(50)
end
--  tabela utilizata in procedura de istoric CO
if @numeTabela='#IstoricCO'
begin
	alter table #IstoricCO
	add marca char(6), nume char(50), lm char(9), den_lm char(30), zile_CO int, indemnizatie_co float, indemnizatie_co_an float, 
	baza_calcul_3 decimal(10), baza_calcul_2 decimal(10), baza_calcul_1 decimal(10), zile_calcul_3 decimal(6,2), zile_calcul_2 decimal(6,2), zile_calcul_1 decimal(6,2), zile_3luni float, 
	baza_calcul_luna decimal(10), zile_calcul_luna decimal(6), media_luna_curenta float, media_ultimelor_3_luni float, media_zilnica_co float, taxe_unitate float, total_chelt float, provizion float,
	Ordonare char(100)
end

--  tabela utilizata in procedurile de validare Revisal
if @numeTabela='#vRevisal'
begin
	alter table #vRevisal
	add marca char(6), Nume char(50), TipValidare char(100)
end

--	tabela utilizata in procedurile de calcul concediu de odihna
if @numeTabela='#tempCO'
Begin
	alter table #tempCO
	add marca varchar(6), tip_CO char(1), Data_inceput datetime, Data_sfarsit datetime, 
	    Zile_CO int, Introd_manual int, Indemnizatie_CO decimal(10), Zile_prima_vacanta float,
		nDataInreg float, dDataInreg datetime, Tip_sal char(1), RL decimal(6,2), 
		Loc_de_munca varchar(9), Grupa_de_munca char(1), Salar_de_incadrare float, 
		Salar_de_baza float, Tip_salarizare char(1), Somaj_1 decimal(10,2), CASS decimal(10,2), 
		Zile_concediu_de_odihna int, Data_angajarii_in_unitate datetime, 
		Tip_colab char(3), Funct_public int, Salar_de_baza_istpers float, 
		Data_primei datetime, Prima_vacanta float, Data_inceput_CO datetime, 
		Data_primei_datainc datetime, Prima_vacanta_datainc float, Gasit_prima_ant int,
		Ore_luna float, media_zilnica decimal(12,3), DataModifSalar datetime, Suma_CO float,
		ordine int, Ore_CO int, venit_net float, deducere_pers float, venit_baza float, impozit float, retineri_CO float, vPrimaVacanta float, 
		baza_stagiu_luna decimal(10), zile_stagiu_luna decimal(6),
		baza_stagiu1 decimal(10), zile_stagiu1 decimal(6,2), baza_stagiu2 decimal(10), zile_stagiu2 decimal(6,2), baza_stagiu3 decimal(10), zile_stagiu3 decimal(6,2), 
		condCalcul int, condCalculNet int
end

--	tabela utilizata in procedurile de calcul CO si lichidare pentru calculul deducerii personale
if @numeTabela='#deduceri'
Begin
	alter table #deduceri
	add data datetime, deducere_pers decimal(12,3), venitBrut decimal(10), oreJustificate int not null default 0, grupaMunca char(1), regimLucru float, calculLaOrePontaj int
end

--	tabela utilizata in procedurile ce apeleaza datele din tabela de tichete
if @numeTabela='#ptichete'
Begin
	alter table #ptichete
	add marca varchar(20), loc_de_munca varchar(20), comanda varchar(20), tip_tichete char(1), numar_tichete decimal(10,2), valoare_tichete decimal(10,2), ordonare char(50)
end

--	tabela utilizata in procedura GenNCTichete
if @numeTabela='#NCtichete'
Begin
	alter table #NCtichete
	add marca varchar(20), loc_de_munca varchar(20), comanda varchar(20), tip_tichete char(1), numar_tichete decimal(10,2), valoare_tichete decimal(10,2), 
		cont_debitor varchar(40), cont_creditor varchar(40), suma decimal(10,2), explicatii varchar(200)
end

--	tabela utilizata in procedura psCalculTichete
if @numeTabela='#calcTichete'
Begin
	alter table #calcTichete
	add data_lunii datetime not null, tip_operatie varchar(1) not null, serie_inceput varchar(13) not null, serie_sfarsit varchar(13) not null,
		nr_tichete real not null, valoare_tichet float not null, valoare_imprimat float not null, TVA_imprimat float not null
end

--	tabela utilizata in procedura rapFluturasCentralizat sau in proceduri ce apeleaza rapFluturasCentralizat
if @numeTabela='#flutcent'
Begin
	alter table #flutcent
	add total_ore_lucrate int, ore_lucrate__regie int, realizat__regie float, ore_lucrate_acord float, realizat_acord float, 
		ore_suplimentare_1 int, indemnizatie_ore_supl_1 float, ore_suplimentare_2 int, indemnizatie_ore_supl_2 float, ore_suplimentare_3 float, indemnizatie_ore_supl_3 float,
		ore_suplimentare_4 int, indemnizatie_ore_supl_4 float, ore_spor_100 int, indemnizatie_ore_spor_100 float, ore_de_noapte int,ind_ore_de_noapte float,
		ore_lucrate_regim_normal int,ind_regim_normal float,ore_intrerupere_tehnologica int, ind_intrerupere_tehnologica float, ore_obligatii_cetatenesti int, ind_obligatii_cetatenesti float,
		ore_concediu_fara_salar int, ind_concediu_fara_salar float, ore_concediu_de_odihna int, ind_concediu_de_odihna float,
		ore_concediu_medical int, ore_ingr_copil int, ind_c_medical_unitate float, ind_c_medical_CAS float, CMFAMBP float, CMUnit30Z float,
		ore_invoiri int, ind_intrerupere_tehnologica_2 float, ore_nemotivate int, ind_conducere float, salar_categoria_lucrarii float,
		CMCAS float, CMunitate float, CO float, restituiri float, diminuari float, suma_impozabila float, premiu float, diurna float, 
		cons_admin float, sp_salar_realizat float, suma_imp_separat float, premiu2 float, diurna2 float, CO2 float, avantaje_materiale float, avantaje_impozabile float, 
		spor_vechime float, spor_de_noapte float, spor_sistematic_peste_program float, spor_de_functie_suplimentara float, spor_specific float,  
		spor_cond_1 float, spor_cond_2 float, spor_cond_3 float, spor_cond_4 float, spor_cond_5 float, spor_cond_6 float, Aj_deces float,  
		Venit_total float, spor_cond_7 float, spor_cond_8 float, CM_incasat float, CO_incasat float, suma_incasata float, suma_neimpozabila float,  
		diferenta_impozit float, impozit float, impozit_ipotetic float, impozit_de_virat float, pensie_suplimentara_3 float, baza_somaj_1 float, somaj_1 float, 
		asig_sanatate_din_impozit float, asig_sanatate_din_net float, asig_sanatate_din_CAS float, 
		VENIT_NET float, avans float, premiu_la_avans float, debite_externe float, rate float, debite_interne float, cont_curent float, Cor_U float, Cor_W float, REST_DE_PLATA float, 
		CAS_unitate float, somaj_5 float, Fond_de_risc_1 float,  Camera_de_Munca_1 float, Asig_sanatate_pl_unitate float, CCi float, VEN_NET_iN_iMP float, Ded_personala float, 
		ded_pensie_facultativa float, venit_baza_impozit float, venit_baza_impozit_scutit float, baza_CAS_ind float, baza_CAS_CN float, baza_CAS_CD float, baza_CAS_CS float, 
		subventii_somaj_art8076 float, subventii_somaj_art8576 float, subventii_somaj_art172 float,  subventii_somaj_legea116 float,  
		total_angajati int, ore_intrerupere_tehnologica_1 int, ore_intrerupere_tehnologica_2 int,ore_intr_tehn_3 int,
		baza_somaj_5 float, baza_somaj_5_FP float, baza_CASS_unitate float, baza_CCi float, baza_Camera_de_munca_1 float, venit_pensionari_scutiri_somaj float, CCI_Fambp float, 
		Baza_CAS_cond_norm_CM float,  Baza_CAS_cond_deoseb_CM float, Baza_CAS_cond_spec_CM float, CAS_CM float, baza_fond_garantare float, fond_garantare float,  
		venit_ocazO float, venit_ocazP float, deplasari_RN float, 
		nr_tichete float, val_tichete float, nrTichsupl float, ValTichsupl float, nr_tichete_acordate float, val_tichete_acordate float,  
		ajutor_ridicat_dafora float, ajutor_cuvenit_dafora float, prime_avans_dafora float, avans_CO_dafora float,  
		nr_sal_per_nedeterminata int, nr_sal_per_determinata int, nr_ocazionali int, nr_ocazP int, nr_ocazP_As2 int, nr_cm_t_part int, nr_pers_handicap float, 
		ingr_copil int, nr_salariati_inceput_luna int, nr_angajati int, nr_plecati int, nr_plecati_01 int, salariati_finalul_lunii int,
		numar_mediu_salariati float, cas_de_virat float, scut_art_80 float, scut_art_85 float, Cotiz_hand float, baza_CASS_AMBP float, 
		CASS_AMBP float, Baza_Fambp float, Baza_Fambp_CM float, Total_contributii float, Total_viramente float, Marca char(6), salar_de_incadrare float, 
		VenitZilieri float, impozitZilieri float, RestPlataZilieri float
end
