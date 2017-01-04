--***
Create procedure pDenumiriD394 -- procedura populeaza tabela #denDecl394
as
begin
	if object_id ('tempdb..#tmpDen394') is not null 
		drop table #tmpDen394
	create table #tmpDen394 
		(rand_decl varchar(20),	denumire_macheta varchar(800), denumire_raport varchar(800), ordine int)

	insert into #tmpDen394 (rand_decl, denumire_macheta, denumire_raport, ordine)
	select 'C','NR.PERS. IMPOZABILE ÎNREGISTRATE ÎN SCOPURI DE TVA','NUMĂRUL TOTAL AL PERSOANELOR IMPOZABILE ÎNREGISTRATE ÎN SCOPURI DE TVA ÎN ROMÂNIA INCLUSE ÎN DECLARAŢIE', 0
	union all
	select 'C+','C. PERSOANE ÎNREGISTRATE ÎN SCOPURI DE TVA - ROMÂNIA','LISTA OPERAŢIUNILOR TAXABILE EFECTUATE PE TERITORIUL NAŢIONAL (lit. C)'+char(10)+char(13)+'(cu detaliere pe fiecare operaţiune cu TVA şi pe fiecare operaţiune cu taxarea inversă pentru cereale şi plante tehnice, deşeuri feroase şi neferoase, certificate de emisii de gaze cu efect de seră, energie electrică, certificate verzi, clădiri, aur de investiţii, microprocesoare, console de jocuri, tablete PC şi laptopuri) (lei)', 0
	union all
	select 'C.L','LIVRĂRI DE BUNURI/PRESTĂRI DE SERVICII (L) CU TVA NORMAL','LIVRĂRI DE BUNURI/PRESTĂRI DE SERVICII (L) defalcate pe fiecare cotă de TVA efectuate de către persoana impozabilă care aplică sistemul normal de TVA cu excepţia celor pentru care au fost emise facturi simplificate', 1
	union all
	select 'C.LI','LIVRĂRI DE BUNURI/PRESTĂRI DE SERVICII (L) CU TVA LA INCASARE','LIVRĂRI DE BUNURI/PRESTĂRI DE SERVICII (L) defalcate pe fiecare cotă de TVA efectuate de către persoana impozabilă care aplică sistemul de TVA la încasare cu excepţia celor pentru care au fost emise facturi simplificate', 2
	union all
	select 'C.LS','LIVRĂRI DE BUNURI/PRESTĂRI DE SERVICII (LS) CU TVA NORMAL - REGIM SPECIAL','LIVRĂRI DE BUNURI/PRESTĂRI DE SERVICII (LS) efectuate de către persoana impozabilă care aplică sistemul normal de TVA pentru operaţiunile derulate în regim special pentru agenţiile de turism, pentru bunurile secondhand, opere de artă, obiecte de colecţie şi antichităţi', 3
	union all
	select 'C.LSI','LIVRĂRI DE BUNURI/PRESTĂRI DE SERVICII (LS) CU TVA LA INCASARE - REGIM NORMAL','LIVRĂRI DE BUNURI/PRESTĂRI DE SERVICII (LS) efectuate de către persoana impozabilă care aplică sistemul de TVA la încasare pentru operaţiunile derulate în regim special, respectiv agenţiile de turism, pentru bunurile secondhand, opere de artă, obiecte de colecţie şi antichităţi', 4
	union all
	select 'C.A','ACHIZIŢII DE BUNURI ŞI SERVICII (A) CU TVA NORMAL','ACHIZIŢII DE BUNURI ŞI SERVICII (A) defalcate pe fiecare cotă de TVA de la persoane impozabile care aplică sistemul normal de TVA, cu excepţia celor pentru care s-au primit facturi simplificate', 3
	union all
	select 'C.AI','ACHIZIŢII DE BUNURI ŞI SERVICII (AÎ) CU TVA LA INCASARE','ACHIZIŢII DE BUNURI ŞI SERVICII (AÎ) defalcate pe fiecare cotă de TVA de la persoane impozabile care aplică sistemul de TVA la încasare, cu excepţia celor pentru care s-au primit facturi simplificate', 4
	union all
	select 'C.AS','ACHIZIŢII DE BUNURI ŞI SERVICII (AÎ) CU TVA NORMAL - REGIM SPECIAL','ACHIZIŢII DE BUNURI ŞI SERVICII (AS) efectuate de la persoane impozabile care aplică regimul special pentru agenţiile de turism, pentru bunurile second-hand, opere de artă, obiecte de colecţie şi antichităţi şi care aplică sistemul normal de TVA', 5
	union all
	select 'C.ASI','ACHIZIŢII DE BUNURI ŞI SERVICII (AÎ) CU TVA LA INCASARE - REGIM SPECIAL','ACHIZIŢII DE BUNURI ŞI SERVICII (AS) efectuate de la persoane impozabile care aplică regimul special pentru agenţiile de turism, pentru bunurile second-hand, opere de artă,colecţie şi antichităţi şi care aplică sistemul de TVA la încasare', 6
	union all
	select 'C.V','LIVRĂRI DE BUNURI/PRESTĂRI DE SERVICII TAXARE INVERSA','LIVRĂRI DE BUNURI/PRESTĂRI DE SERVICII EFECTUATE PENTRU CARE SE APLICĂ TAXAREA INVERSĂ (V), din care:', 7
	union all
	select 'C.C','ACHIZIŢII DE BUNURI/PRESTĂRI DE SERVICII TAXARE INVERSA','ACHIZIŢII DE BUNURI ŞI SERVICII EFECTUATE PENTRU CARE SE APLICĂ TAXAREA INVERSĂ (C), din care:', 8
	union all
	select 'D','NR.PERS. IMPOZABILE NEÎNREGISTRATE ÎN SCOPURI DE TVA','NUMĂRUL TOTAL AL PERSOANELOR NEÎNREGISTRATE ÎN SCOPURI DE TVA INCLUSE ÎN DECLARAŢIE', 0
	union all
	select 'D+','D. PERSOANE NEÎNREGISTRATE ÎN SCOPURI DE TVA - ROMÂNIA','LISTA OPERAŢIUNILOR TAXABILE EFECTUATE PE TERITORIUL NAŢIONAL (lit. D)'+char(10)+char(13)+'(cu detaliere pe operaţiuni efectuate cu persoane neînregistrate în scopuri de TVA) (lei)', 0
	union all
	select 'D.L','LIVRĂRI DE BUNURI/PRESTĂRI DE SERVICII (L) CU TVA NORMAL','LIVRĂRI DE BUNURI/PRESTĂRI DE SERVICII (L) defalcate pe fiecare cotă de TVA efectuate de către persoana impozabilă care aplică sistemul normal de TVA cu excepţia celor pentru care au fost emise facturi simplificate', 1
	union all
	select 'D.LI','LIVRĂRI DE BUNURI/PRESTĂRI DE SERVICII (L) CU TVA LA INCASARE','LIVRĂRI DE BUNURI/PRESTĂRI DE SERVICII (L) defalcate pe fiecare cotă de TVA efectuate de către persoana impozabilă care aplică sistemul de TVA la încasare cu excepţia celor pentru care au fost emise facturi simplificate', 2 
	union all
	select 'D.LS','LIVRĂRI DE BUNURI/PRESTĂRI DE SERVICII (L) CU TVA NORMAL - REGIM SPECIAL','LIVRĂRI DE BUNURI/PRESTĂRI DE SERVICII (LS) efectuate de către persoana impozabilă care aplică sistemul normal de TVA pentru operaţiunile derulate în regim special, respectiv agenţiile de turism, pentru bunurile second-hand, opere de artă, obiecte de colecţie şi antichităţi', 3
	union all
	select 'D.LSI','LIVRĂRI DE BUNURI/PRESTĂRI DE SERVICII (L) CU TVA LA INCASARE - REGIM SPECIAL','LIVRĂRI DE BUNURI/PRESTĂRI DE SERVICII (LS) efectuate de către persoana impozabilă care aplică sistemul de tva la încasare pentru operaţiunile derulate în regim special, respectiv agenţiile de turism, pentru bunurile second-hand, opere de artă, obiecte de colecţie şi antichităţi', 4
	union all
	select 'D.N','ACHIZIŢII DE BUNURI ŞI SERVICII (N)','ACHIZIŢII DE BUNURI ŞI SERVICII (N)', 5
	union all
	select 'D_EXCEPTII','FACTURI EMISE CATRE PERSOANE FIZICE CU VALOARE INDIVIDUALA MAI MICA SAU EGALA CU 10.000 LEI (L/LS)','FACTURI EMISE CATRE PERSOANE FIZICE CU VALOARE INDIVIDUALA MAI MICA SAU EGALA CU 10.000 LEI (L/LS)', 6
	union all
	select 'E','NR.PERS. IMPOZABILE NEÎNREGISTRATE ÎN SCOPURI DE TVA IN EU','NUMĂRUL TOTAL AL PERSOANELOR NESTABILITE ÎN ROMÂNIA CARE SUNT STABILITE ÎN ALT STAT MEMBRU, NEÎNREGISTRATE ŞI CARE NU SUNT OBLIGATE SĂ SE ÎNREGISTREZE ÎN SCOPURI DE TVA ÎN ROMÂNIA INCLUSE ÎN DECLARAŢIE', 0
	union all
	select 'E+','E. PERSOANE IMPOZABILE NEÎNREGISTRATE ÎN SCOPURI DE TVA IN EU','LISTA OPERAŢIUNILOR TAXABILE EFECTUATE PE TERITORIUL NAŢIONAL (lit. E)'+char(10)+char(13)+'(cu detaliere pe operaţiuni efectuate cu persoane impozabile nestabilite în România care sunt stabilite în alt stat membru, neînregistrate şi care nu sunt obligate să se înregistreze în scopuri de TVA în România) (lei)', 0
	union all
	select 'E.L','LIVRĂRI DE BUNURI/PRESTĂRI DE SERVICII (L)  CU TVA NORMAL','LIVRĂRI DE BUNURI/PRESTĂRI DE SERVICII (L) defalcate pe fiecare cotă de TVA efectuate de către persoana impozabilă care aplică sistemul normal de TVA cu excepţia celor pentru care au fost emise facturi simplificate', 1
	union all
	select 'E.LI','LIVRĂRI DE BUNURI/PRESTĂRI DE SERVICII (L)  CU TVA LA INCASARE','LIVRĂRI DE BUNURI/PRESTĂRI DE SERVICII (L) defalcate pe fiecare cotă de TVA efectuate de către persoana impozabilă care aplică sistemul de TVA la încasare cu excepţia celor pentru care au fost emise facturi simplificate', 2
	union all
	select 'E.LS','LIVRĂRI DE BUNURI/PRESTĂRI DE SERVICII (L)  CU TVA NORMAL - REGIM SPECIAL','LIVRĂRI DE BUNURI/PRESTĂRI DE SERVICII (LS) efectuate de către persoana impozabilă care aplică sistemul normal de TVA pentru operaţiunile derulate în regim special, respectiv agenţiile de turism, pentru bunurile secondhand, opere de artă, obiecte de colecţie şi antichităţi', 3
	union all
	select 'E.LSI','LIVRĂRI DE BUNURI/PRESTĂRI DE SERVICII (L)  CU TVA LA INCASARE - REGIM SPECIAL','LIVRĂRI DE BUNURI/PRESTĂRI DE SERVICII (LS) efectuate de către persoana impozabilă care aplică sistemul de tva la încasare pentru operaţiunile derulate în regim special, respectiv agenţiile de turism, pentru bunurile secondhand, opere de artă, obiecte de colecţie şi antichităţi', 4
	union all
	select 'E.C','ACHIZIŢII DE BUNURI ŞI SERVICII EFECTUATE - TAXAREA INVERSĂ (C)','ACHIZIŢII DE BUNURI ŞI SERVICII EFECTUATE PENTRU CARE SE APLICĂ TAXAREA INVERSĂ (C)', 5
	union all
	select 'E.A','ACHIZIŢII DE BUNURI ŞI SERVICII EFECTUATE - FARA TAXAREA INVERSĂ (A)','ACHIZIŢII DE BUNURI ŞI SERVICII EFECTUATE PENTRU CARE NU SE APLICĂ TAXAREA INVERSĂ (C)', 6
	union all
	select 'F','NR.PERS. IMPOZABILE NEÎNREGISTRATE ÎN SCOPURI DE TVA EX EU','NUMĂRUL TOTAL AL PERSOANELOR IMPOZABILE NEÎNREGISTRATE ŞI CARE NU SUNT OBLIGATE SĂ SE ÎNREGISTREZE ÎN SCOPURI DE TVA ÎN ROMÂNIA, NESTABILITE PE TERITORIUL UNIUNII EUROPENE INCLUSE ÎN DECLARAŢIE', 0
	union all
	select 'F+','F. PERSOANE IMPOZABILE NEÎNREGISTRATE ÎN SCOPURI DE TVA EX EU','LISTA OPERAŢIUNILOR TAXABILE EFECTUATE PE TERITORIUL NAŢIONAL (lit. F)'+char(10)+char(13)+'(cu detaliere pe operaţiuni efectuate cu persoane impozabile neînregistrate şi care nu sunt obligate să se înregistreze în scopuri de TVA în România, nestabilite pe teritoriul Uniunii Europene)(lei)', 0
	union all
	select 'F.L','LIVRĂRI DE BUNURI/PRESTĂRI DE SERVICII (L)  CU TVA NORMAL','LIVRĂRI DE BUNURI/PRESTĂRI DE SERVICII (L) defalcate pe fiecare cotă de TVA efectuate de către persoana impozabilă care aplică sistemul normal de TVA cu excepţia celor pentru care au fost emise facturi simplificate', 1
	union all
	select 'F.LI','LIVRĂRI DE BUNURI/PRESTĂRI DE SERVICII (L)  CU TVA LA INCASARE','LIVRĂRI DE BUNURI/PRESTĂRI DE SERVICII (L) defalcate pe fiecare cotă de TVA efectuate de către persoana impozabilă care aplică sistemul de TVA la încasare cu excepţia celor pentru care au fost emise facturi simplificate', 2
	union all
	select 'F.LS','LIVRĂRI DE BUNURI/PRESTĂRI DE SERVICII (L)  CU TVA NORMAL - REGIM SPECIAL','LIVRĂRI DE BUNURI/PRESTĂRI DE SERVICII (LS) efectuate de către persoana impozabilă care aplică sistemul normal de TVA pentru operaţiunile derulate în regim special, respectiv agenţiile de turism, pentru bunurile secondhand, opere de artă, obiecte de colecţie şi antichităţi', 3
	union all
	select 'F.LSI','LIVRĂRI DE BUNURI/PRESTĂRI DE SERVICII (L)  CU TVA LA INCASARE - REGIM SPECIAL','LIVRĂRI DE BUNURI/PRESTĂRI DE SERVICII (LS) efectuate de către persoana impozabilă care aplică sistemul de TVA la încasare pentru operaţiunile derulate în regim special, respectiv agenţiile de turism, pentru bunurile secondhand, opere de artă, obiecte de colecţie şi antichităţi', 4
	union all
	select 'F.A','ACHIZIŢII DE BUNURI ŞI SERVICII EFECTUATE - TAXAREA INVERSĂ (C)','ACHIZIŢII DE BUNURI ŞI SERVICII EFECTUATE PENTRU CARE SE APLICĂ TAXAREA INVERSĂ (C)', 5
	union all
	select 'G.1','ÎNCASĂRI ÎN PERIOADA DE RAPORTARE PRIN INTERMEDIUL AMEF (Î1)','ÎNCASĂRI ÎN PERIOADA DE RAPORTARE PRIN INTERMEDIUL AMEF***) INCLUSIV ÎNCASĂRILE PRIN INTERMEDIUL BONURILOR FISCALE CARE ÎNDEPLINESC CONDIŢIILE UNEI FACTURI SIMPLIFICATE INDIFERENT DACĂ AU/NU AU ÎNSCRIS CODUL DE ÎNREGISTRARE ÎN SCOPURI DE TVA AL BENEFICIARULUI (Î1)', 0
	union all
	select 'G.2','ÎNCASĂRI ÎN PERIOADA DE RAPORTARE EFECTUATE DIN ACTIVITĂŢI EXCEPTATE DE LA OBLIGAŢIA UTILIZĂRII AMEF (Î2)','ÎNCASĂRI ÎN PERIOADA DE RAPORTARE EFECTUATE DIN ACTIVITĂŢI EXCEPTATE DE LA OBLIGAŢIA UTILIZĂRII AMEF***) (Î2) CONFORM PREVEDERILOR LEGALE ÎN VIGOARE**)', 0
	union all
	select 'H.L','LIVRĂRI DE BUNURI/PRESTĂRI DE SERVICII (L)','LIVRĂRI DE BUNURI/PRESTĂRI DE SERVICII (L)', 0
	union all
	select 'H.LV','LIVRĂRI DE BUNURI/PRESTĂRI DE SERVICII (L+V)','LIVRĂRI DE BUNURI/PRESTĂRI DE SERVICII (L+V)', 0
	union all
	select 'H.AC','ACHIZIŢII DE BUNURI ŞI SERVICII (A+C)','ACHIZIŢII DE BUNURI ŞI SERVICII (A+C)', 0
	union all
	select 'H.AI','ACHIZIŢII DE BUNURI ŞI SERVICII (AÎ)','ACHIZIŢII DE BUNURI ŞI SERVICII (AÎ)', 0
	union all
	select 'I.1.1','Livrări de bunuri/prestări de servicii defalcate pe fiecare cotă de TVA pentru care s-au emis facturi simplificate care au înscris codul de înregistrare în scopuri de TVA al beneficiarului','1.1 Livrări de bunuri/prestări de servicii defalcate pe fiecare cotă de TVA pentru care s-au emis facturi simplificate care au înscris codul de înregistrare în scopuri de TVA al beneficiarului', 0
	union all
	select 'I.1.2','Livrări de bunuri/prestări de servicii defalcate pe fiecare cotă de TVA pentru care s-au emis facturi simplificate fără a avea înscris codul de înregistrare în scopuri de TVA al beneficiarului şi pentru care nu s-au emis bonuri fiscale','1.2 Livrări de bunuri/prestări de servicii defalcate pe fiecare cotă de TVA pentru care s-au emis facturi simplificate fără a avea înscris codul de înregistrare în scopuri de TVA al beneficiarului şi pentru care nu s-au emis bonuri fiscale', 0
	union all
	select 'I.1.3','Achiziţii de bunuri şi servicii defalcate pe fiecare cotă de TVA pentru care s-au primit facturi simplificate de la persoane impozabile care aplică sistemul normal de TVA şi care au înscris codul de înregistrare în scopuri de TVA al beneficiarului','1.3 Achiziţii de bunuri şi servicii defalcate pe fiecare cotă de TVA pentru care s-au primit facturi simplificate de la persoane impozabile care aplică sistemul normal de TVA şi care au înscris codul de înregistrare în scopuri de TVA al beneficiarului', 0
	union all
	select 'I.1.4','Achiziţii de bunuri şi servicii defalcate pe fiecare cotă de TVA pentru care s-au primit facturi simplificate de la persoane impozabile care aplică sistemul de TVA la încasare şi care au înscris codul de înregistrare în scopuri de TVA al beneficiarului','1.4 Achiziţii de bunuri şi servicii defalcate pe fiecare cotă de TVA pentru care s-au primit facturi simplificate de la persoane impozabile care aplică sistemul de TVA la încasare şi care au înscris codul de înregistrare în scopuri de TVA al beneficiarului', 0
	union all
	select 'I.1.5','Achiziţii de bunuri şi servicii defalcate pe fiecare cotă de TVA pentru care s-au primit bonuri fiscale care îndeplinesc condiţiile unei facturi simplificate şi care au înscris codul de înregistrare în scopuri de TVA al beneficiarului','1.5 Achiziţii de bunuri şi servicii defalcate pe fiecare cotă de TVA pentru care s-au primit bonuri fiscale care îndeplinesc condiţiile unei facturi simplificate şi care au înscris codul de înregistrare în scopuri de TVA al beneficiarului', 0
	union all
	select 'I.2.1','Plaja de facturi alocate în perioada de raportare','Plaja de facturi alocate în perioada de raportare', 1
	union all
	select 'I.2.2','Număr total de facturi emise, în perioada de raportare, din plaja de facturi alocate:','Număr total de facturi emise, în perioada de raportare, din plaja de facturi alocate:', 2
	union all
	select 'I.2.3','Număr total de facturi emise, în perioada de raportare, de beneficiari în numele persoanei impozabile:','Număr total de facturi emise, în perioada de raportare, de beneficiari în numele persoanei impozabile:', 3
	union all
	select 'I.2.4','Număr total de facturi emise, în perioada de raportare, de terţi în numele persoanei impozabile:','Număr total de facturi emise, în perioada de raportare, de terţi în numele persoanei impozabile:', 4
	union all
	select 'I.3','În cazul în care soldul sumei negative înregistrate în decontul de TVA aferent perioadei de raportare este solicitat la rambursare se vor selecta datele cu privire la natura operaţiunilor din care provine acesta:','3. În cazul în care soldul sumei negative înregistrate în decontul de TVA aferent perioadei de raportare este solicitat la rambursare se vor selecta datele cu privire la natura operaţiunilor din care provine acesta:', 0
	union all
	select 'I.3.A','Achiziţii de bunuri şi servicii legate direct de bunurile imobile din următoarele categorii:','Achiziţii de bunuri şi servicii legate direct de bunurile imobile din următoarele categorii:', 1
	union all
	select 'I.3.A.PE','a) parcuri eoliene','a) parcuri eoliene', 2
	union all
	select 'I.3.A.CR','b) construcţii rezidenţiale','b) construcţii rezidenţiale', 3
	union all
	select 'I.3.A.CB','c) clădiri de birouri','c) clădiri de birouri', 4
	union all
	select 'I.3.A.CI','d) construcţii industriale','d) construcţii industriale', 5
	union all
	select 'I.3.A.A','e) altele','e) altele', 6
	union all
	select 'I.3.A.B','Achiziţii de bunuri, cu excepţia celor legate direct de bunuri imobile:','Achiziţii de bunuri, cu excepţia celor legate direct de bunuri imobile:', 7
	union all
	select 'I.3.A.B24','a) cu cota de TVA 24%','a) cu cota de TVA 24%', 8
	union all
	select 'I.3.A.B20','b) cu cota standard de TVA 20%','b) cu cota standard de TVA 20%', 9
	union all
	select 'I.3.A.B19','c) cu cota de TVA 19%','c) cu cota de TVA 19%', 10
	union all
	select 'I.3.A.B9','d) cu cota redusa de TVA 9%','b) cu cota redusa de TVA 9%', 11
	union all
	select 'I.3.A.B5','e) cu cota redusa de TVA 5%','c) cu cota redusa de TVA 5%', 12
	union all
	select 'I.3.A.S','Achiziţii de servicii, cu excepţia celor legate direct de bunuri imobile:','Achiziţii de servicii, cu excepţia celor legate direct de bunuri imobile:', 13
	union all
	select 'I.3.A.S24','a) cu cota de TVA 24%','a) cu cota de TVA 24%', 14
	union all
	select 'I.3.A.S20','b) cu cota standard de TVA 20%','b) cu cota standard de TVA 20%', 15
	union all
	select 'I.3.A.S19','c) cu cota de TVA 19%','c) cu cota de TVA 19%', 16
	union all
	select 'I.3.A.S9','d) cu cota redusa de TVA 9%','b) cu cota redusa de TVA 9%', 17
	union all
	select 'I.3.A.S5','e) cu cota redusa de TVA 5%','c) cu cota redusa de TVA 5%', 18
	union all
	select 'I.3.A.IB','Importuri de bunuri','Importuri de bunuri', 19
	union all
	select 'I.3.A.IN','Achiziţii imobilizări necorporale','Achiziţii imobilizări necorporale', 20
	union all
	select 'I.3.L','Livrări de bunuri imobile','Livrări de bunuri imobile', 21
	union all
	select 'I.3.L.BUN','Livrări de bunuri imobile','Livrări de bunuri imobile', 22
	union all
	select 'I.3.L.BUNX','Livrări de bunuri, cu excepţia bunurilor imobile:','Livrări de bunuri, cu excepţia bunurilor imobile:', 23
	union all
	select 'I.3.A.BUN24','a) cu cota de TVA 24%','a) cu cota de TVA 24%', 24
	union all
	select 'I.3.A.BUN20','b) cu cota standard de TVA 20%','b) cu cota standard de TVA 20%', 25
	union all
	select 'I.3.A.BUN19','c) cu cota de TVA 19%','c) cu cota de TVA 19%', 26
	union all
	select 'I.3.A.BUN9','d) cu cota redusa de TVA 9%','b) cu cota redusa de TVA 9%', 27
	union all
	select 'I.3.A.BUN5','e) cu cota redusa de TVA 5%','c) cu cota redusa de TVA 5%', 28
	union all
	select 'I.3.L.BS','Livrări de bunuri scutite de TVA','Livrări de bunuri scutite de TVA', 29
	union all
	select 'I.3.L.BUNTI','Livrări de bunuri/prestări de servicii pentru care se aplică taxarea inversă','Livrări de bunuri/prestări de servicii pentru care se aplică taxarea inversă', 30
	union all
	select 'I.3.L.PP','Prestări de servicii:','Prestări de servicii:', 31
	union all
	select 'I.3.A.P24','a) cu cota de TVA 24%','a) cu cota de TVA 24%', 32
	union all
	select 'I.3.A.P20','b) cu cota standard de TVA 20%','b) cu cota standard de TVA 20%', 33
	union all
	select 'I.3.A.P19','c) cu cota de TVA 19%','c) cu cota de TVA 19%', 34
	union all
	select 'I.3.A.P9','d) cu cota redusa de TVA 9%','b) cu cota redusa de TVA 9%', 35
	union all
	select 'I.3.A.P5','e) cu cota redusa de TVA 5%','c) cu cota redusa de TVA 5%', 36
	union all
	select 'I.3.L.PS','Prestări de servicii scutite de TVA','Prestări de servicii scutite de TVA', 37
	union all
	select 'I.3.L.Intra','Livrări intracomunitare de bunuri','Livrări intracomunitare de bunuri', 38
	union all
	select 'I.3.L.PIntra','Prestări intracomunitare de servicii','Prestări intracomunitare de servicii', 39
	union all
	select 'I.3.L.Export','Exporturi de bunuri','Exporturi de bunuri', 40
	union all
	select 'I.3.L.IN','Livrări imobilizări necorporale','Livrări imobilizări necorporale', 41
	union all
	select 'I.3.L.P','Persoana impozabilă nu a efectuat livrări de bunuri/prestări servicii în perioada de raportare','Persoana impozabilă nu a efectuat livrări de bunuri/prestări servicii în perioada de raportare', 42
	union all
	select 'I.4','Date aferente operaţiunilor desfăşurate de către persoana impozabilă care aplică sistemul normal de TVA','4. Date aferente operaţiunilor desfăşurate de către persoana impozabilă care aplică sistemul normal de TVA', 0
	union all
	select 'I.4.1','TVA deductibilă aferentă facturilor achitate în perioada de raportare indiferent de data în care acestea au fost primite de la persoane impozabile care aplică sistemul de TVA la încasare defalcate pe fiecare cotă de TVA','4.1 TVA deductibilă aferentă facturilor achitate în perioada de raportare indiferent de data în care acestea au fost primite de la persoane impozabile care aplică sistemul de TVA la încasare defalcate pe fiecare cotă de TVA', 0
	union all
	select 'I.5','Date aferente operaţiunilor desfăşurate de către persoana impozabilă care aplică sistemul de TVA la încasare','5. Date aferente operaţiunilor desfăşurate de către persoana impozabilă care aplică sistemul de TVA la încasare', 0
	union all
	select 'I.5.1','TVA colectată aferentă facturilor încasate în perioada de raportare indiferent de data la care acestea au fost emise de către persoana impozabilă care aplică sistemul TVA la încasare defalcate pe fiecare cotă de TVA','5.1 TVA colectată aferentă facturilor încasate în perioada de raportare indiferent de data la care acestea au fost emise de către persoana impozabilă care aplică sistemul TVA la încasare defalcate pe fiecare cotă de TVA', 0
	union all
	select 'I.5.2','TVA deductibilă aferentă facturilor achitate în perioada de raportare indiferent de data în care acestea au fost primite de la persoane impozabile care aplică sistemul normal de TVA defalcate pe fiecare cotă de TVA','5.2 TVA deductibilă aferentă facturilor achitate în perioada de raportare indiferent de data în care acestea au fost primite de la persoane impozabile care aplică sistemul normal de TVA defalcate pe fiecare cotă de TVA', 0
	union all
	select 'I.5.3','TVA deductibilă aferentă facturilor achitate în perioada de raportare indiferent de data în care acestea au fost primite de la persoane impozabile care aplică sistemul de TVA la încasare defalcate pe fiecare cotă de TVA','5.3 TVA deductibilă aferentă facturilor achitate în perioada de raportare indiferent de data în care acestea au fost primite de la persoane impozabile care aplică sistemul de TVA la încasare defalcate pe fiecare cotă de TVA', 0
	union all
	select 'I.6','În situaţia în care aţi desfăşurat, în perioada de raportare, activităţi dintre cele înscrise în listă veţi selecta activitatea corespunzătoare şi veţi înscrie valoarea livrărilor/prestărilor precum şi TVA aferentă','6. În situaţia în care aţi desfăşurat, în perioada de raportare, activităţi dintre cele înscrise în listă veţi selecta activitatea corespunzătoare şi veţi înscrie valoarea livrărilor/prestărilor precum şi TVA aferentă', 0
	union all
	select 'I.6.1','Persoanele impozabile care aplică regimul special pentru agenţiile de turism, vor completa:','6.1. Persoanele impozabile care aplică regimul special pentru agenţiile de turism, vor completa:', 0
	union all
	select 'I.6.2','Persoanele impozabile care aplică regimul special pentru bunurile second-hand, opere de artă, obiecte de colecţie şi antichităţi vor completa:','6.2 Persoanele impozabile care aplică regimul special pentru bunurile second-hand, opere de artă, obiecte de colecţie şi antichităţi vor completa:', 0
	union all
	select 'I.7.CAEN','În situaţia în care aţi desfăşurat, în perioada de raportare, activităţi dintre cele înscrise în listă veţi selecta activitatea corespunzătoare şi veţi înscrie valoarea livrărilor/prestărilor, precum şi TVA aferentă','7. În situaţia în care aţi desfăşurat, în perioada de raportare, activităţi dintre cele înscrise în listă veţi selecta activitatea corespunzătoare şi veţi înscrie valoarea livrărilor/prestărilor, precum şi TVA aferentă', 0


	if object_id('tempdb..#denDecl394') is not null
		insert into #denDecl394 (rand_decl, denumire_macheta, denumire_raport, ordine)
		select rand_decl, denumire_macheta, denumire_raport, ordine
		from #tmpDen394
	else 
		select rand_decl, denumire_macheta, denumire_raport, ordine from #tmpDen394
end
