--***
Create procedure wScriuDateD394 @sesiune varchar(50)=null	-->	parametrul sesiune nu va avea efect pana ce nu-l vom trimite catre ftert
		,@data datetime=null, @tert varchar(1000)=''
		,@parxml xml='<row/>'
as
declare @facturi varchar(1000), @expandare int, @tert_generare varchar(100),
		@raport bit, @codMeniu varchar(10), @tip varchar(10), @update int, @subtip varchar(2), @locm varchar(9),
		@nrfact int, @incasari decimal(15,2), @baza float, @tva float, @cotatva int, @tipop char(2), @cdecl varchar(9)

select	--> filtre:
		 @data=isnull(@parxml.value('(row/@datalunii)[1]','datetime'),@data)
		,@codMeniu=isnull(@parxml.value('(row/@codMeniu)[1]','varchar(10)'),'')
		,@subtip=isnull(@parxml.value('(row/linie/@subtip)[1]','varchar(2)'),'')
		,@tip=isnull(@parxml.value('(row/@tip)[1]','varchar(10)'),'')
		,@update=isnull(@parxml.value('(row/@update)[1]','int'),0)
		,@locm=@parxml.value('(row/@lm)[1]','varchar(9)')
		--> specifice machetei:
		,@expandare=(case left(isnull(@parxml.value('(row/@expandare)[1]','varchar(2)'),'2'),1) when 'd' then 10 when 'n' then 1 when '' then 2 else isnull(@parxml.value('(row/@expandare)[1]','varchar(2)'),2) end)
begin
	declare @eroare varchar(1000), @utilizator varchar(10), @lista_lm int, @multiFirma int, @lmFiltru varchar(9), @lmUtilizator varchar(9), @nrLMFiltru int, @denlmUtilizator varchar(9)
	
	set @utilizator=dbo.fIaUtilizator(null)
	set @lista_lm=dbo.f_areLMFiltru(@utilizator)

	set @multiFirma=0
	if exists (select * from sysobjects where name ='par' and xtype='V')
		set @multiFirma=1
	select @lmFiltru=isnull(min(Cod),''), @nrLMFiltru=count(1) from LMfiltrare where utilizator=@utilizator and cod in (select cod from lm where Nivel=1)
	if @multiFirma=1 or @nrLMFiltru=1
		set @lmUtilizator=@lmFiltru

	if @multiFirma=1 
	begin
		select @denlmUtilizator=isnull(min(Denumire),'') from lm where cod=@lmUtilizator
	end

	-- diez provizoriu filtrat
	if object_id('tempdb..#Decl394') is not null drop table #Decl394
	select d.* 
	into #Decl394
	from d394 d
		left outer join LMFiltrare lu on lu.utilizator=@utilizator and lu.cod=d.lm
	where d.data=dbo.eom(@data)
		and (@lista_lm=0 or lu.cod is not null) 
	
	select @locm=isnull(cod,@locm) from lmfiltrare where utilizator=@utilizator

	-- tabela de denumiri declaratie 394
	if object_id('tempdb..#denDecl394') is null 
		create table #denDecl394 (rand_decl varchar(20), denumire_macheta varchar(800),	denumire_raport varchar(800), ordine int)
	exec pDenumiriD394
	-- tabela nomenclator declaratie 394
	if object_id('tempdb..#codnc394') is null 
		create table #CodNC394 (codnc varchar(20), Denumire varchar(100))
	exec pCoduriNC394
	
-->	date pentru macheta - ierarhie:
	if @codMeniu='DTG' -- tab date generale
	begin
		update d394 set denumire=isnull(@parxml.value('(/row/@calitate)[1]','varchar(75)'),'') where rand_decl='A_calitate_intocmit' 
			and data=dbo.eom(@data) and ((@multifirma=0 and lm is null) or (@multiFirma=1 and lm=@lmUtilizator))
		update d394 set denumire=isnull(@parxml.value('(/row/@intocmit)[1]','varchar(50)'),'') where rand_decl='A_cif_intocmit' 
			and data=dbo.eom(@data) and ((@multifirma=0 and lm is null) or (@multiFirma=1 and lm=@lmUtilizator))
		update d394 set denumire=isnull(@parxml.value('(/row/@den_intocmit)[1]','varchar(75)'),'') where rand_decl='A_den_intocmit' 
			and data=dbo.eom(@data) and ((@multifirma=0 and lm is null) or (@multiFirma=1 and lm=@lmUtilizator))
		update d394 set denumire=isnull(@parxml.value('(/row/@functie_intocmit)[1]','varchar(75)'),'') where rand_decl='A_functie_intocmit' 
			and data=dbo.eom(@data) and ((@multifirma=0 and lm is null) or (@multiFirma=1 and lm=@lmUtilizator))
		update d394 set denumire=isnull(@parxml.value('(/row/@optiune)[1]','int'),0) where rand_decl='A_optiune' 
			and data=dbo.eom(@data) and ((@multifirma=0 and lm is null) or (@multiFirma=1 and lm=@lmUtilizator))
		update d394 set denumire=isnull(nullif(isnull(@parxml.value('(/row/@schimb_optiune)[1]','char(1)'),'0'),'0'),'') where rand_decl='A_schimb_optiune' 
			and data=dbo.eom(@data) and ((@multifirma=0 and lm is null) or (@multiFirma=1 and lm=@lmUtilizator))
		update d394 set denumire=isnull(@parxml.value('(/row/@solicit_ramb)[1]','int'),0) where rand_decl='A_solicit_ramb' 
			and data=dbo.eom(@data) and ((@multifirma=0 and lm is null) or (@multiFirma=1 and lm=@lmUtilizator))
		update d394 set denumire=isnull(@parxml.value('(/row/@tip_intocmit)[1]','int'),'1') where rand_decl='A_tip_intocmit' 
			and data=dbo.eom(@data) and ((@multifirma=0 and lm is null) or (@multiFirma=1 and lm=@lmUtilizator))
		update d394 set denumire=isnull(@parxml.value('(/row/@adresaR)[1]','varchar(1000)'),'') where rand_decl='A_adresaR' 
			and data=dbo.eom(@data) and ((@multifirma=0 and lm is null) or (@multiFirma=1 and lm=@lmUtilizator))
		update d394 set denumire=isnull(@parxml.value('(/row/@cifR)[1]','varchar(50)'),'') where rand_decl='A_cifR' 
			and data=dbo.eom(@data) and ((@multifirma=0 and lm is null) or (@multiFirma=1 and lm=@lmUtilizator))
		update d394 set denumire=isnull(@parxml.value('(/row/@denR)[1]','varchar(50)'),'') where rand_decl='A_denR' 
			and data=dbo.eom(@data) and ((@multifirma=0 and lm is null) or (@multiFirma=1 and lm=@lmUtilizator))
		update d394 set denumire=isnull(@parxml.value('(/row/@functieR)[1]','varchar(100)'),'') where rand_decl='A_functieR' 
			and data=dbo.eom(@data) and ((@multifirma=0 and lm is null) or (@multiFirma=1 and lm=@lmUtilizator))
		update d394 set denumire=isnull(@parxml.value('(/row/@telefonR)[1]','varchar(50)'),'') where rand_decl='A_telefonR' 
			and data=dbo.eom(@data) and ((@multifirma=0 and lm is null) or (@multiFirma=1 and lm=@lmUtilizator))
		update d394 set denumire=isnull(@parxml.value('(/row/@faxR)[1]','varchar(50)'),'') where rand_decl='A_faxR' 
			and data=dbo.eom(@data) and ((@multifirma=0 and lm is null) or (@multiFirma=1 and lm=@lmUtilizator))
		update d394 set denumire=isnull(@parxml.value('(/row/@mailR)[1]','varchar(100)'),'') where rand_decl='A_mailR' 
			and data=dbo.eom(@data) and ((@multifirma=0 and lm is null) or (@multiFirma=1 and lm=@lmUtilizator))
		update d394 set nrCui=isnull(@parxml.value('(/row/@nrcasemarcat)[1]','int'),0) where rand_decl='A_nrcasemarcat' 
			and data=dbo.eom(@data) and ((@multifirma=0 and lm is null) or (@multiFirma=1 and lm=@lmUtilizator))
	end

	if @codMeniu='DT3' -- tab date I.3
	begin
		if not exists (select 1 from #Decl394 where rand_decl='A_solicit_ramb' and denumire=1)
			raiserror ('Nu s-a marcat in declaratia 394, faptul ca s-a solicitat rambursare de TVA. Prin urmare nu are sens actualizarea acestei sectiuni!',16,1)

		update d394 -- scriere
			set are_doc=(case when isnull(@parxml.value('(row/row/@chk)[1]','varchar(50)'),'A')='Nu' then 0 when isnull(@parxml.value('(row/row/@chk)[1]','varchar(50)'),'A')='Da' then 1 else null end)
		where rtrim(rand_decl)=rtrim(@parxml.value('(row/row/@randdecl)[1]','varchar(50)')) and data=dbo.eom(@data)
		set @parXml=(select @codMeniu as codMeniu, @data as datalunii, 'AI' as subtip for xml raw)
		if object_id('tempdb..#denDecl394') is not null drop table #denDecl394
		exec wIaDateD394 @sesiune=@sesiune, @parxml=@parXml
	end

	if @codMeniu='DTH' -- tab date G-H
	begin
	if isnull(@parxml.value('(row/row/@cdecl)[1]','varchar(50)'),'A')<>'A' 
		begin
			set @cdecl=rtrim(@parxml.value('(row/row/@cdecl)[1]','varchar(50)'))
			set @nrfact=isnull(@parxml.value('(row/row/@nrfact)[1]','int'),0)
			set @incasari=isnull(@parxml.value('(row/row/@incasari)[1]','int'),0)
			set @baza=isnull(@parxml.value('(row/row/@baza)[1]','float'),0)
			set @tva=isnull(@parxml.value('(row/row/@tva)[1]','float'),0)
			set @cotatva=isnull(@parxml.value('(row/row/@cotatva)[1]','int'),0)
			set @tipop=(case when left(@cdecl,1)='H' then rtrim(substring(@cdecl,3,2)) else 'I'+right(rtrim(@cdecl),1) end)
			if @cotatva=0
				set @cotatva=rtrim(substring(@cdecl,charindex('.',@cdecl,3)+1,3))

			update d394 -- scriere
				set nrfacturi=@nrfact,
					incasari=@incasari,
					baza=@baza,
					tva=@tva
			where rtrim(rand_decl)=substring(@cdecl,1,charindex('.',@cdecl,3)-1) and data=dbo.eom(@data) and cota_tva=@cotatva
				and ((@multifirma=0 and lm is null) or (@multiFirma=1 and lm=@lmUtilizator))
			/*  sa se poata face doar update
			--if not exists (select 1 from d394 where rtrim(rand_decl)=substring(@cdecl,1,charindex('.',@cdecl,3)-1) and data=dbo.eom(@data) and cota_tva=@cotatva)
			--	insert into d394 (data, rand_decl, tipop, nrfacturi, baza, tva, cota_tva, incasari, introdus_manual)
			--	select @data, substring(@cdecl,1,charindex('.',@cdecl,3)-1), @tipop, @nrfact, @baza, @tva, @cotatva, @incasari, 0
			*/
		end

		set @parXml=(select @codMeniu as codMeniu, @data as datalunii, 'AH' as subtip, 10 as expandare for xml raw)
		if object_id('tempdb..#denDecl394') is not null drop table #denDecl394
		exec wIaDateD394 @sesiune=@sesiune, @parxml=@parXml
	end
		
	declare @seriei varchar(10), @nri varchar(20), @tipf int, @serief varchar(10), @nrf varchar(20), @o_seriei varchar(10), @o_nri varchar(20), @o_serief varchar(10), @o_nrf varchar(20), @o_tipf int
		
	if @codMeniu='DT2'
	begin
		set @update=isnull(@parxml.value('(row/row/@update)[1]','int'),0)

		set @tipf=@parxml.value('(row/row/@tipf)[1]','int')
		set @seriei=rtrim(isnull(@parxml.value('(row/row/@seriai)[1]','varchar(10)'),''))
		set @nri=isnull(@parxml.value('(row/row/@numari)[1]','varchar(20)'),'')
		set @serief=rtrim(isnull(@parxml.value('(row/row/@seriaf)[1]','varchar(10)'),''))
		set @nrf=isnull(@parxml.value('(row/row/@numarf)[1]','varchar(20)'),'')
		set @o_seriei=rtrim(isnull(@parxml.value('(row/row/@o_seriai)[1]','varchar(10)'),''))
		set @o_nri=isnull(@parxml.value('(row/row/@o_numari)[1]','varchar(20)'),'')
		set @o_serief=rtrim(isnull(@parxml.value('(row/row/@o_seriaf)[1]','varchar(10)'),''))
		set @o_nrf=isnull(@parxml.value('(row/row/@o_numarf)[1]','varchar(20)'),'')
		set @baza=isnull(@parxml.value('(row/row/@baza)[1]','decimal(15)'),0)
		set @tva=isnull(@parxml.value('(row/row/@tva)[1]','decimal(15)'),0)
		set @cotatva=@parxml.value('(row/row/@cotatva)[1]','int')

		if @subtip='A1' -- tab date I.2
		begin
			if isnull(@parxml.value('(row/row/@cdecl)[1]','varchar(50)'),'A')<>'A' and @update=1 
			begin
				set @cdecl=rtrim(@parxml.value('(row/row/@cdecl)[1]','varchar(50)'))
				update D394
					set tip=@tipf,
						seriei=@seriei,
						nri=@nri,
						serief=@serief,
						nrf=@nrf
				where isnull(seriei,'')=@o_seriei and isnull(nri,0)=@o_nri and isnull(serief,'')=@o_serief and isnull(nrf,0)=@o_nrf and rand_decl=@cdecl
					and ((@multifirma=0 and lm is null) or (@multiFirma=1 and lm=@lmUtilizator))
			end
			else
			if @update=0
			begin
				set @cdecl=rtrim(@parxml.value('(row/linie/@cdecl)[1]','varchar(50)'))
				insert into D394 (data, rand_decl, tip, seriei, nri, serief, nrf, introdus_manual, lm)
				select @data, (case when @tipf='1' then 'I.2.1' else 'I.2.2' end), @tipf, @seriei, @nri, @serief, @nrf, 1, @locm
			end

			set @parXml=(select @codMeniu as codMeniu, @data as datalunii, 'A1' as subtip, 10 as expandare for xml raw)
			if object_id('tempdb..#denDecl394') is not null drop table #denDecl394
			exec wIaDateD394 @sesiune=@sesiune, @parxml=@parXml
		end

		if @subtip='A2' -- tab date I.2
		begin
			if isnull(@parxml.value('(row/row/@cdecl)[1]','varchar(50)'),'A')<>'A' and @update=1 
			begin
				set @cdecl=rtrim(@parxml.value('(row/row/@cdecl)[1]','varchar(50)'))
				update D394
					set seriei=@seriei,
						nri=@nri,
						tip=@tipf,
						cota_tva=@cotatva, @baza=baza, @tva=tva
				where isnull(seriei,'')=@o_seriei and isnull(nri,0)=@o_nri and isnull(tip,0)=@o_tipf and rand_decl=@cdecl
					and ((@multifirma=0 and lm is null) or (@multiFirma=1 and lm=@lmUtilizator))
			end
			else
			if @update=0
			begin
				set @cdecl=rtrim(@parxml.value('(row/linie/@cdecl)[1]','varchar(50)'))
				insert into D394 (data, rand_decl, seriei, nri, tip, cota_tva, baza, tva, introdus_manual, lm)
				select @data, 'I.2.2.F', @seriei, @nri, @tipf, @cotatva, @baza, @tva, 1, @locm
			end

			set @parXml=(select @codMeniu as codMeniu, @data as datalunii, 'A2' as subtip, 10 as expandare for xml raw)
			if object_id('tempdb..#denDecl394') is not null drop table #denDecl394
			exec wIaDateD394 @sesiune=@sesiune, @parxml=@parXml
		end
	end
	
	declare @randdecl varchar(50), @cheltuieli decimal(15,2), @marja decimal(15,2), @cota_tva int, @o_randdecl varchar(50), @o_cheltuieli decimal(15,2), @o_marja decimal(15,2), @o_cota_tva int, 
			@o_incasari decimal(15,2), @o_tva decimal(15,2)
	if @codMeniu='DT6' and @subtip='I6' -- tab date I.6
	begin
		set @update=isnull(@parxml.value('(row/row/@update)[1]','int'),0)
		set @randdecl=rtrim(@parxml.value('(row/row/@randdecl)[1]','varchar(50)'))
		set @incasari=rtrim(isnull(@parxml.value('(row/row/@incasari)[1]','decimal(15,2)'),0))
		set @cheltuieli=ISNULL(@parxml.value('(row/row/@cheltuieli)[1]','decimal(15,2)'),0)
		set @marja=@parxml.value('(row/row/@marja)[1]','decimal(15,2)')
		set @tva=@parxml.value('(row/row/@tva)[1]','decimal(15,2)')
		set @cota_tva=@parxml.value('(row/row/@cota_tva)[1]','int')
		set @o_randdecl=rtrim(@parxml.value('(row/row/@o_randdecl)[1]','varchar(50)'))
		set @o_incasari=rtrim(isnull(@parxml.value('(row/row/@o_incasari)[1]','decimal(15,2)'),0))
		set @o_cheltuieli=ISNULL(@parxml.value('(row/row/@o_cheltuieli)[1]','decimal(15,2)'),0)
		set @o_marja=@parxml.value('(row/row/@o_marja)[1]','decimal(15,2)')
		set @o_tva=@parxml.value('(row/row/@o_tva)[1]','decimal(15,2)')
		set @o_cota_tva=@parxml.value('(row/row/@o_cota_tva)[1]','int')				
		
		if @update=1 
		begin
			update D394
				set rand_decl=@randdecl,
					incasari=@incasari,
					nrI=@cheltuieli,
					baza=@marja,
					tva=@tva,
					cota_tva=@cota_tva
			where isnull(rand_decl,'')=@o_randdecl and isnull(incasari,0)=@o_incasari and isnull(baza,0)=@o_marja and isnull(tva,0)=@o_tva and isnull(cota_tva,0)=@cota_tva and data=dbo.eom(@data)
				and ((@multifirma=0 and lm is null) or (@multiFirma=1 and lm=@lmUtilizator))
		end
		else
		begin
			insert into D394 (data, rand_decl, incasari, nrI, baza, tva, cota_tva, introdus_manual, lm)
			select @data, @randdecl, @incasari, @cheltuieli, @marja, @tva, @cota_tva, 1, @locm
		end

		set @parXml=(select @codMeniu as codMeniu, @data as datalunii, 'I6' as subtip, 10 as expandare for xml raw)
		if object_id('tempdb..#denDecl394') is not null drop table #denDecl394
		exec wIaDateD394 @sesiune=@sesiune, @parxml=@parXml
	end
	declare @activitate varchar(10), @o_activitate varchar(10)
	if @codMeniu='DT7' and @subtip='I7' -- tab date I.7
	begin
		set @update=isnull(@parxml.value('(row/row/@update)[1]','int'),0)
		set @randdecl=rtrim(@parxml.value('(row/row/@randdecl)[1]','varchar(50)'))
		set @activitate=rtrim(@parxml.value('(row/row/@activitate)[1]','varchar(10)'))
		set @marja=isnull(@parxml.value('(row/row/@valori)[1]','decimal(15,2)'),0)
		set @tva=isnull(@parxml.value('(row/row/@tva)[1]','decimal(15,2)'),0)
		set @cota_tva=isnull(@parxml.value('(row/row/@cota_tva)[1]','int'),0)
		set @o_randdecl=rtrim(@parxml.value('(row/row/@o_randdecl)[1]','varchar(50)'))
		set @o_marja=isnull(@parxml.value('(row/row/@o_valori)[1]','decimal(15,2)'),0)
		set @o_tva=isnull(@parxml.value('(row/row/@o_tva)[1]','decimal(15,2)'),0)
		set @o_cota_tva=isnull(@parxml.value('(row/row/@o_cota_tva)[1]','int'),0)
		set @o_activitate=rtrim(@parxml.value('(row/row/@o_activitate)[1]','varchar(10)'))

		if @update=1 
		begin
			update D394
				set rand_decl=@randdecl,
					incasari=@incasari,
					denumire=@activitate,
					baza=@marja,
					tva=@tva,
					cota_tva=@cota_tva,
					serieI=@activitate
			where isnull(rand_decl,'')='I.7' and isnull(denumire,'')=isnull(@o_activitate,'') and isnull(cota_tva,0)=@o_cota_tva and data=dbo.eom(@data)
				and ((@multifirma=0 and lm is null) or (@multiFirma=1 and lm=@lmUtilizator))
		end
		else
		begin
			if not exists (select 1 from d394 where rand_decl='I.7' and isnull(denumire,'')=isnull(@activitate,'') and isnull(cota_tva,0)=@cota_tva and data=dbo.eom(@data))
				insert into D394 (data, rand_decl, baza, tva, cota_tva, denumire, introdus_manual, lm)
				select @data, 'I.7', @marja, @tva, @cota_tva, @activitate, 1, @locm
		end

		set @parXml=(select @codMeniu as codMeniu, @data as datalunii, 'I7' as subtip, 10 as expandare for xml raw)
		if object_id('tempdb..#denDecl394') is not null drop table #denDecl394
		exec wIaDateD394 @sesiune=@sesiune, @parxml=@parXml
	end
end
