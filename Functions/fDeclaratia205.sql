--***
/**	functie ce returneaza date pt. declaratia 205 */
Create function fDeclaratia205 (@DataJ datetime, @DataS datetime, @tipdecl int, @TipVenit char(2), 
	@lmjos char(9), @lmsus char(9), @ContImpozit char(30), @ContFactura char(30))
returns @date205 table
	(Data datetime, Tip_venit char(2), Tip_impozit char(1), CNP char(13), Nume char(200), 
	Baza_impozit decimal(10), Impozit decimal(10), CampD205 varchar(max))
as  
Begin
	declare @Luna int, @An int, @LunaAlfa varchar(15), 
	@Sub char(9), @vcif varchar(13), @cif varchar(13), @den char(200),
	@TotalBazaImpozit decimal(12), @TotalImpozit decimal(12)

	select @Sub=dbo.iauParA('GE','SUBPRO'), @vcif=dbo.iauParA('GE','CODFISC'), @den=dbo.iauParA('GE','NUME')
	Select @cif=ltrim(rtrim((case when left(upper(@vcif),2)='RO' then substring(@vcif,3,13)
		when left(upper(@vcif),1)='R' then substring(@vcif,2,13) else @vcif end)))
	select @luna=month(@DataS), @An=year(@DataS)

	if exists (select 1 from sysobjects where [type]='P' and [name]='fDeclaratia205SP')
		exec fDeclaratia205SP @DataJ, @DataS, @tipdecl, @TipVenit, @lmjos, @lmsus
	else 
	Begin
--		completez intr-o tabela temporara baza impozit/impozit 
--		primul select este pornit de la specificul Grupului RematInvest (au evidentiat impozitul direct pe receptie pe un alt cod cu minus)
--		(linia cu cod=IMPPF are in cantitate procentul de impozit si in campul pret de stoc are baza impozitului/100)
--		selectul de dupa primul union all se refera la cei care au evidentiat retinerea impozitului prin plata furnizor
		declare @impozit table
		(Data datetime, Tip_venit char(2), Tip_impozit char(1), CNP char(13), Nume char(200), Baza_impozit decimal(10), Impozit decimal(10))
		insert into @impozit
		select @DataS, '17', '2', left(rtrim(t.Cod_fiscal),13), max(t.Denumire), round(sum(p.Pret_de_stoc*100),0), 
		round(sum(ROUND(-p.Cantitate*p.Pret_de_stoc,2)),0)
		from pozdoc p
			left outer join terti t on p.Subunitate=t.Subunitate and p.Tert=t.Tert
		where (@TipVenit='' or @TipVenit='17') and p.Subunitate=@Sub and Data between @DataJ and @DataS and p.Tip='RM'
			and (charindex(',',@ContImpozit)=0 and p.Cont_de_stoc=@ContImpozit or charindex(',',@ContImpozit)<>0 and charindex(rtrim(p.Cont_de_stoc),@ContImpozit)<>0)
			and (charindex(',',@ContFactura)=0 and p.Cont_factura=@ContFactura or charindex(',',@ContFactura)<>0 and charindex(rtrim(p.Cont_factura),@ContFactura)<>0)
		Group by t.Cod_fiscal
		union all 
		select @DataS, '17', '2', left(rtrim(t.Cod_fiscal),13), max(t.Denumire), sum(f.Valoare), sum(p.Suma)
		from pozplin p
			left outer join terti t on p.Subunitate=t.Subunitate and p.Tert=t.Tert
			left outer join facturi f on f.Subunitate=p.Subunitate and f.Factura=p.Factura and f.Tert=p.Tert and f.Tip=0x54
		where (@TipVenit='' or @TipVenit='17') and p.Subunitate=@Sub and p.Data between @DataJ and @DataS and p.Plata_incasare='PF'
			and p.Cont=@ContImpozit and p.Cont_corespondent=@ContFactura
		Group by t.Cod_fiscal
		union all
--		inserez salariatii care au realizat venituri din conventii civile/drepturi de autor
		select @DataS, (case when i.Tip_colab='DAC' then '01' else '06' end), 
		(case when i.Tip_impozitare='8' then '1' else '2' end), p.Cod_numeric_personal, max(p.Nume) as Nume, sum(n.Venit_baza), sum(n.Impozit)
		from net n
			left outer join personal p on p.Marca=n.Marca
			left outer join istPers i on i.Data=n.Data and i.Marca=n.Marca
		where n.Data between @DataJ and @DataS and n.Data=dbo.EOM(n.Data)
			and ((@TipVenit='' or @TipVenit='01') and i.Tip_colab='DAC' or (@TipVenit='' or @TipVenit='06') and i.Tip_colab='CCC')
		group by p.Cod_numeric_personal, (case when i.Tip_colab='DAC' then '01' else '06' end),
		(case when i.Tip_impozitare='8' then '1' else '2' end)

		delete from @impozit where CNP in (select CNP from @impozit group by CNP having SUM(Impozit)=0)

		select @TotalBazaImpozit=sum(Baza_impozit), @TotalImpozit=sum(Impozit) from @impozit
		where (@TipVenit='' or Tip_venit=@TipVenit)

		select @TotalBazaImpozit=isnull(@TotalBazaImpozit,0), @TotalImpozit=isnull(@TotalImpozit,0)

--		inserez total general ca header fisier (prima linie din fisierul exportat)
		insert into @date205 
		select @DataS, '', '', @cif, @den, 0, @TotalImpozit, 
			convert(char(4),YEAR(@DataS))+','+(case when @tipdecl=0 then '1' else '2' end)
			+','+rtrim(@cif)+',0,0,,,'+rtrim(convert(char(12),CONVERT(decimal(12),@TotalBazaImpozit)))
			+','+rtrim(convert(char(12),CONVERT(decimal(12),@TotalImpozit)))

--		inserez datele finale prelucrate
		insert into @date205
		select Data, Tip_venit, Tip_impozit, CNP, max(Nume), sum(Baza_impozit), sum(impozit), 
		rtrim(Tip_venit)+','+rtrim(Tip_impozit)+','+rtrim(CNP)+',0,0,,,'+rtrim(convert(char(10),sum(Baza_impozit)))+','+rtrim(convert(char(10),sum(Impozit)))
		from @impozit
		Group by Data, CNP, Tip_venit, Tip_impozit
		
	End

	return
End

/*
	select * from fDeclaratia205 ('01/01/2011', '12/31/2011', 0, '', Null, Null, '446.5','462.2')
*/