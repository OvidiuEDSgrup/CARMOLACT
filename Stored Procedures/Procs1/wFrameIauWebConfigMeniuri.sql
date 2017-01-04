--***

create procedure wFrameIauWebConfigMeniuri(@sesiune varchar(50), @parXML XML)
as

declare @eroare varchar(1000)
begin try
	declare --@proprietar int, @IdUtilizator int
		@TipMacheta varchar(2), @Meniu varchar(2), @Tip varchar(2), @Subtip varchar(2),
		@Text varchar(500), @Procedura varchar(60), @TipObiect varchar(50), @Vizibil int, 
		@InLucru varchar(2), @Fel varchar(1),
		@id int,
		@_cautare varchar(500), @denumire varchar(500),
		@maxordine int		--	@maxordine: orice macheta care are in webconfigtipuri valoarea mai mare pentru ordine decat parametrul 
							--		e semanalata ca nefiind configurata pana la capat
		, @_expandat varchar(2), @nivel int	--	@nivel: pana la ce adancime sa mearga aducerea datelor
		, @doc xml
	select	@TipMacheta=isnull(@parXML.value('(/row/@TipMacheta)[1]','varchar(2)'),''),
			@Meniu=isnull(@parXML.value('(/row/@Meniu)[1]','varchar(2)'),''),
			@Tip=isnull(@parXML.value('(/row/@Tip)[1]','varchar(2)'),''),
			@Subtip=isnull(@parXML.value('(/row/@Subtip)[1]','varchar(2)'),''),
			@Text='%'+replace(isnull(@parXML.value('(/row/@Text)[1]','varchar(500)'),''),' ','%')+'%',
			@Procedura='%'+replace(isnull(@parXML.value('(/row/@Procedura)[1]','varchar(50)'),''),' ','%')+'%',
			@Vizibil=isnull(@parXML.value('(/row/@Vizibil)[1]','int'),2),
			@InLucru=isnull(@parXML.value('(/row/@InLucru)[1]','varchar(2)'),2),
			@Fel=isnull(@parXML.value('(/row/@Fel)[1]','varchar(1)'),''),
			@id=isnull(@parXML.value('(/row/@id)[1]','int'),''),
--			@_cautare=isnull(@parXML.value('(/row/@_cautare)[1]','varchar(500)'),'%'),
			@denumire=isnull(@parXML.value('(/row/@denumire)[1]','varchar(500)'),'%'),
			@TipObiect=isnull(@parXML.value('(/row/@TipObiect)[1]','varchar(500)'),'%'),
			@_expandat=isnull(@parXML.value('(/row/@expandat)[1]','varchar(500)'),'0'),
			@nivel=isnull(@parXML.value('(/row/@nivel)[1]','int'),1000),
			@maxordine=1000
			--@_expandat='da'
			--select @nivel
	select @_expandat=(case when rtrim(@_expandat) in ('da','1') then 'da' else 'nu' end),
			@InLucru=(case	when rtrim(@InLucru)='2' then '2' 
							when rtrim(@InLucru) in ('da','1') then '1' else '0' end)
	select @Meniu=@Tip, @Subtip=@Tip
--/*tst
	--set @denumire='documente'
	set @denumire='%'+replace(isnull(@denumire,''),' ','%')+'%'
	--set @_expandat='da'
	--*/
	IF OBJECT_ID('tempdb..#webConfigMeniuFiltrate') IS NOT NULL drop table #webConfigMeniuFiltrate
	IF OBJECT_ID('tempdb..#webconfigmeniu') IS NOT NULL drop table #webconfigmeniu
	IF OBJECT_ID('tempdb..#webConfigTipuriFiltrate') IS NOT NULL drop table #webConfigTipuriFiltrate
	IF OBJECT_ID('tempdb..#webconfigtipuri') IS NOT NULL drop table #webconfigtipuri

--	select substring(@_cautare,charindex('Vizibil=',@_cautare)+8,1)
/*	if (@vizibil=2 and @_cautare like '%~%V=%~%')
		set @vizibil=(case substring(@_cautare,charindex('V=',@_cautare)+2,1) when  '1' then 1 when '0' then 0 else 2 end)
	
	if (@Meniu='' and @_cautare like 'Meniu=%')
	begin
		set @vizibil=substring(@_cautare,8,1)
		set @_cautare='%'
	end
	
	if (@_cautare like '%~%X%~%')
		set @_expandat='da'
	
	if (charindex('~',@_cautare))>0
	set @_cautare=substring(@_cautare,1,charindex('~',@_cautare)-1)+
			reverse(substring(reverse(@_cautare),1,charindex('~',reverse(@_cautare))-1))

	set @_cautare='%'+replace(@_cautare,' ','%')+'%'
	if replace(@Text,'%','')='' set @Text=@_cautare*/
------------------------------	reorganizare date din cele doua tabele de configurari

	select w.*, (case when w.idParinte is null then 3
				else 0 end) as stare,
			(case when ((isnull(w.nume,'')='') or (isnull(w.Meniu,'')='')) and isnull(w.idParinte,0)<>0
				or w.id>@maxordine then 1 else 0 end) as neconfigurat,
				isnull(w.TipMacheta,'') as Ltipmacheta, isnull(w.Meniu,'') as Lmeniu, isnull(w.id,0) as Lid, isnull(w.idParinte,0) as Lidparinte
				into #webConfigMeniuFiltrate
			from webConfigMeniu w

	select w.*,(case	when w.Vizibil=0 then 1
			else 0 end) as stare, 
			(case when (isnull(w.nume,'')='') or (isnull(w.Meniu,'')='')
				or ordine>@maxordine
				then 1 else 0 end) as neconfigurat,
				isnull(w.TipMacheta,'') as Ltipmacheta, isnull(w.Meniu,'') as Lmeniu, isnull(w.Tip,'') as Ltip, isnull(w.Subtip,'') as Lsubtip,
			wm.id, isnull(wm.id,'') as Lid
	into #webConfigTipuriFiltrate
	from webConfigTipuri w left join webconfigmeniu wm on w.TipMacheta=wm.TipMacheta and w.Meniu=wm.Meniu
		where	(@TipMacheta='' or isnull(w.TipMacheta,'')=@TipMacheta) and
				/*(@Meniu='' or isnull(w.Meniu,'')=@Meniu) and
				(@Subtip='' or isnull(w.Subtip,'')=@Subtip) and*/
				(@Tip='' or isnull(w.Tip,'')=@Tip or isnull(w.Subtip,'')=@Tip or isnull(w.Meniu,'')=@Tip) and
				(@Fel='' or isnull(w.Fel,'')=@Fel) 
	--tst		select * from #webConfigTipuriFiltrate w --WHERE MENIU='N'

/**	luare configurari "ratacite" (meniuri cu folder inexistent, tipuri fara meniuri)	*/
	/**	meniurile cu parinte "absent" dar cu idparinte completat se grupeaza separat:	*/
	declare @idFaraParinte int, @idUrmator int
	select @idFaraParinte=max(w.idParinte)	--> determin cel mai mare idparinte nedefinit
	from #webConfigMeniuFiltrate w where isnull(w.idParinte,0)<>0 and not exists 
		(select 1 from #webConfigMeniuFiltrate w1 where w1.id=w.idparinte)
		
	update w set w.Lidparinte=@idFaraParinte, neconfigurat=1		-->	toate machetele cu parinte "absent" vor aparea in cadrul unui singur folder
	from #webConfigMeniuFiltrate w where isnull(w.idParinte,0)<>0 and not exists	--> se considera ca sunt neconfigurate
		(select 1 from #webConfigMeniuFiltrate w1 where w1.id=w.idparinte)
	update w set neconfigurat=1
	from #webConfigTipuriFiltrate w inner join #webConfigMeniuFiltrate wm on w.TipMacheta=wm.TipMacheta and w.Meniu=wm.Meniu and wm.neconfigurat=1
	/**	tipuri fara meniu	*/
	select @idUrmator=max(id) from #webConfigMeniuFiltrate				--> imi trebuie pentru a creea liniile de meniu necesare
	if @idFaraParinte is null select @idFaraParinte=@idUrmator+1		--> pentru meniul folder '<Fara parinte>'
	update wt set wt.Id=0, wt.Lid=@idUrmator+w.nr_rand,					--> legatura pentru tipurile fara meniu
			wt.neconfigurat=1
		from (select wt.*,row_number() over (order by wt.tip) as nr_rand from #webConfigTipuriFiltrate wt
		where not exists (select 1 from #webConfigMeniuFiltrate wm where wt.meniu=wm.meniu)) w
			inner join #webConfigTipuriFiltrate wt on isnull(w.Meniu,'')=isnull(wt.Meniu,'')
						and isnull(wt.TipMacheta,'')=isnull(w.TipMacheta,'') and isnull(wt.Tip,'')=isnull(w.Tip,'')
						and isnull(wt.Subtip,'')=isnull(w.Subtip,'')
--tst	select lid,* from #webConfigTipuriFiltrate where meniu='bl'						
	insert into #webConfigMeniuFiltrate									--> creare linii pentru tipurile fara meniu
	select w.*, 0 as stare, 2 as neconfigurat, '~' as Ltipmacheta, '~~' as Lmeniu,
		@idFaraParinte as Lid, 0 as Lidparinte from webconfigmeniu w where w.Id=@idUrmator
		union all
	select w.*, 0 as stare, 2 as neconfigurat, wt.TipMacheta as Ltipmacheta, wt.Meniu as Lmeniu,
		wt.Lid as Lid, @idFaraParinte as Lidparinte
		from webConfigMeniu w, #webConfigTipuriFiltrate wt
		where not exists (select 1 from #webConfigMeniuFiltrate wm where wt.meniu=wm.meniu)
				and w.Id=@idUrmator and isnull(wt.tip,'')=''

	update w set w.Nume='<Fara parinte>',w.TipMacheta='D',w.Meniu='~~', neconfigurat=1, w.id=@idFaraParinte, w.idParinte=null,
		Icoana='<Fara meniu>'
	from #webConfigMeniuFiltrate w where w.neconfigurat=2 and Lid=@idFaraParinte

	update w set neconfigurat=1, Nume=wt.Nume, id=w.Lid, idParinte=@idFaraParinte,
		meniu=wt.Meniu, TipMacheta=wt.TipMacheta, Icoana='<Fara meniu>'
	from #webConfigMeniuFiltrate w inner join #webConfigTipuriFiltrate wt on w.Lid=wt.lid and isnull(wt.tip,'')=''
		where w.neconfigurat=2
/*--tst	
select * from #webConfigMeniuFiltrate where meniu='xx'--id=@idUrmator-1
select * from #webConfigTipuriFiltrate where meniu='xx'	--*/

	/**		filtrare tabele; regula generala aplicata este: daca am date intr-o linie de nivel inferior, linia de nivel superior trebuie sa apara,
		chiar daca nu respecta regulile de filtrare; la fel, liniile inferioare liniei filtrate	**/
	delete wt from #webConfigTipuriFiltrate wt	/** se elimina tipurile care nu corespund filtrelor */
	where not exists (select 1 from #webConfigTipuriFiltrate wf where
					wf.Ltipmacheta=wt.Ltipmacheta and wf.Lmeniu=wt.Lmeniu and 
					((isnull(wt.Ltip,'')='' or isnull(wf.Ltip,'')=isnull(wt.Ltip,''))	/**	legatura pt nivelele superioare liniei filtrate*/
						and (isnull(wt.Lsubtip,'')='' or isnull(wf.Lsubtip,'')=isnull(wt.Lsubtip,''))
					 or (--isnull(wf.tip,'')=''										/**	legatura pt nivelele inferioare liniei filtrate*/
							isnull(wt.Ltip,'')<>'' and (isnull(wf.Ltip,'')='' or
							isnull(wt.Ltip,'')=isnull(wf.Ltip,'') and (isnull(wt.Lsubtip,'')<>'' and isnull(wf.Lsubtip,'')=''))
						)) 
						and
						(isnull(wf.nume,'') like @denumire and
						(isnull(wf.ProcScriere,'') like @procedura
						 or isnull(wf.ProcDatePoz,'') like @procedura
							 or isnull(wf.ProcScriere,'') like @procedura or isnull(wf.ProcScrierePoz,'') like @procedura
							 or isnull(wf.ProcStergere,'') like @procedura or isnull(wf.ProcStergerePoz,'') like @procedura
							 or isnull(wf.procPopulare,'') like @procedura))
--						and (wt.neconfigurat=1)
					)
				/**	se sterg doar acele tipuri pentru care nu va exista linia din meniu:	*/
			and not exists (select 1 from #webConfigMeniuFiltrate wf left join #webConfigMeniuFiltrate wM on wf.lidParinte=wm.lId
					where			/**	se iau doar acele tipuri pentru care exista meniul dupa filtrare*/
						wf.Ltipmacheta=wt.Ltipmacheta and wf.Lmeniu=wt.Lmeniu and 
							(isnull(wf.nume,'') like @denumire
							or isnull(wM.Nume,'') like @denumire)
					)
		
delete wt from #webConfigTipuriFiltrate wt
	where not exists (select 1 from #webConfigTipuriFiltrate wf where 
		wf.Ltipmacheta=wt.Ltipmacheta and wf.Lmeniu=wt.Lmeniu and 
					((isnull(wt.Ltip,'')='' or isnull(wf.Ltip,'')=isnull(wt.Ltip,''))	/**	legatura pt nivelele superioare liniei filtrate*/
						and (isnull(wt.Lsubtip,'')='' or isnull(wf.Lsubtip,'')=isnull(wt.Lsubtip,'')))
		and ((@Vizibil=2 or isnull(wf.Vizibil,1)=@Vizibil)
			and (@InLucru=2 or wf.neconfigurat=@InLucru)
			)
		)
/* --tst
select * from #webConfigMeniuFiltrate WHERE lidparinte='6'
select * from #webConfigTipuriFiltrate w WHERE w.Lid in (1004,1005,501,502,505)
--*/
/*--tst
	select * from #webConfigTipuriFiltrate w WHERE MENIU='bl'
	select * from #webConfigMeniuFiltrate WHERE Lmeniu='~~'	--*/
					
delete w from #webConfigMeniuFiltrate w
	where w.idParinte is not null and
		not exists (select 1 from #webConfigTipuriFiltrate wt
				where w.Ltipmacheta=wt.Ltipmacheta and w.Lmeniu=wt.Lmeniu)

delete w from #webConfigMeniuFiltrate w where w.Lidparinte is null and 
		(not exists (select 1 from #webConfigMeniuFiltrate wt where w.Lid=wt.Lidparinte)
		and w.Nume not like @denumire)
/*--tst		
	select * from #webConfigTipuriFiltrate w --WHERE MENIU='N'
	select * from #webConfigMeniuFiltrate	--*/

	declare @max_lungime_id int
	set @max_lungime_id=(select max(len(id)) from #webConfigMeniuFiltrate)
	------------------------------	pregatire webConfigMeniuri
	select ' <Fara dir>' A, '~' B, '~' C, '' D, '' E, '' F, '' G, '' H,						--> folder pentru meniuri fara folder-e
		'~' TipMacheta, '~' Meniu, '' Tip, '' Subtip, 
		(select min(isnull(w.idParinte,w.Id)) from #webConfigMeniuFiltrate w)-1 Ordine, 
		'~' Ltipmacheta, '~' Lmeniu, convert(varchar(100),'') as Lidparinte, convert(varchar(100),0) as Lid,
		'#0000AA' culoare, 0 nivel, 1 _nemodificabil,
		convert(varchar(100),'') as idparinte, convert(varchar(100),0) as id
		into #webConfigMeniu
		where not exists (select 1 from #webConfigMeniuFiltrate w1 where w1.id=0)
		union all
	select isnull(w.Nume,'') A, isnull(w.TipMacheta,'') B, isnull(w.Meniu,'') C, isnull(w.Modul,'') D, 
			space(@max_lungime_id-len(convert(varchar(20),isnull(w.id,0))))+convert(varchar(20),isnull(w.id,0)) E,
			convert(varchar(20),isnull(w.idParinte,'')) F, isnull(w.Icoana,'') G, '' H,
		isnull(w.TipMacheta,'') TipMacheta, isnull(w.Meniu,''), '' Tip, '' Subtip, isnull(w.Id,0) Ordine,
			Ltipmacheta, Lmeniu, w.Lidparinte, w.Lid,
			(case	when neconfigurat=1 then '#FF0000'
					when stare=0 then '#000000'
					when stare=1 then '#888888'
					when stare=3 then '#00AA00' end) culoare, 
				(case when w.idParinte is null then 0 else 1 end) nivel, 0 _nemodificabil,
			convert(varchar(100),idParinte) as idparinte, convert(varchar(100),w.Id) as id
		from #webConfigMeniuFiltrate w

/*--tst	
select * from #webConfigMeniu
select * from #webConfigTipuriFiltrate	--*/
	
	------------------------------	pregatire webConfigTipuri
	select	w.Nume A, w.TipMacheta+(case when fel<>'' then ' ('+fel+')' else '' end) B, w.Meniu C, w.Tip D, convert(varchar(20),w.Ordine) E, w.Subtip F, convert(varchar(20),isnull(Vizibil,1)) G,
			Fel H, isnull(w.TipMacheta,'') TipMacheta, isnull(w.Meniu,'') Meniu, isnull(w.Tip,'') Tip, 
			isnull(w.Subtip,'') Subtip, isnull(w.Ordine,0) Ordine, 
			w.Ltipmacheta, w.Lmeniu, w.Ltip, w.Lsubtip,
			(case	when neconfigurat=1 then '#FF0000'
					when stare=0 then '#000000'
					when stare=1 then '#888888'
					when stare=3 then '#00AA00' end) culoare, 2 as nivel, 0 _nemodificabil, 
			convert(varchar(100),w.id) as idparinte,
			convert(varchar(100),w.id) as id	into #webconfigtipuri
			from #webConfigTipuriFiltrate w
			where
			not (isnull(w.tip,'')='' --or isnull(w.tip,'')=w.Meniu --or isnull(w.Subtip,'')<>''
				) --or Lmeniu='~1'
	order by nivel, Tip, Meniu,-- TipMacheta, 
	Ordine
--tst	select * from #webConfigMeniu w where Lidparinte=6--where Lmeniu='~~'--where w.nivel=2
--tst	select * from #webconfigtipuri w where idparinte=6--where meniu='bl'--where w.nivel=2
--tst	select * from #webConfigTipuriFiltrate w --WHERE MENIU='N'
-------------------------------------------------------------------- aranjarea datelor pentru grid
set @doc=(select 'E1' tip, 'EO' as subtip,A,B,C,D,E,F,G,H, TipMacheta, Meniu, Tip, Subtip, Ordine, culoare, nivel, _nemodificabil,
			(select A,B,C,D,E,F,G,H, TipMacheta, Meniu, Tip, Subtip, Ordine, culoare, nivel, _nemodificabil,
			(select *,					--> webConfigTipuri pe tipuri (nivel 1 - tipuri)
				(select --'EM' tip, 'ET' as subtip, --? e nevoie de tip si subtip pentru adaugare ? sau facem prin operatii?
					A,B,C,D,E,F,G,H, TipMacheta, Meniu, Tip, Subtip, Ordine, culoare, nivel, _nemodificabil--, ceva.query('/') 
				from (	select *		--> tabele de configurari legate de tipul curent (nivel 2 - subtipuri)
							from #webconfigtipuri wst
							where wst.nivel=2 and isnull(wst.TipMacheta,'')<>'' 
								and wst.TipMacheta=w.TipMacheta and wst.Meniu=w.Meniu and wst.TipMacheta<>'C' and wst.nivel<@nivel-1
								and (wst.TipMacheta='D' and wst.Tip=w.Tip and wst.Subtip<>'' or wst.TipMacheta<>'D' and wst.Tip<>'')
				--------------------------------------------------------------------/**/
				)x for xml raw, type)
		from #webconfigtipuri w where 
		w.nivel=2 and isnull(w.TipMacheta,'')<>'' and 
				((w.TipMacheta='D') and isnull(w.Subtip,'')='' or isnull(w.Tip,'')='' and w.TipMacheta<>'C' or
					w.TipMacheta='C' and isnull(w.Tip,'')<>'') and
				wm.Lmeniu=w.Lmeniu and wm.Ltipmacheta=w.Ltipmacheta and w.nivel<@nivel
			for xml raw, type)
		from #webConfigMeniu wm where wm.nivel=1 and wm.Lidparinte=wmm.Lid and wm.nivel<@nivel for xml raw, type)
from #webConfigMeniu wmm where wmm.nivel=0 and wmm.nivel<@nivel order by wmm.ordine for xml raw)
		

set @doc =(select @_expandat as [@_expandat], @doc for xml path('Ierarhie'), root('Date'))
select @doc

	IF OBJECT_ID('tempdb..#webConfigMeniuFiltrate') IS NOT NULL drop table #webConfigMeniuFiltrate
	IF OBJECT_ID('tempdb..#webconfigmeniu') IS NOT NULL drop table #webconfigmeniu
	IF OBJECT_ID('tempdb..#webConfigTipuriFiltrate') IS NOT NULL drop table #webConfigTipuriFiltrate
	IF OBJECT_ID('tempdb..#webconfigtipuri') IS NOT NULL drop table #webconfigtipuri
end try
begin catch
	set @eroare='wFrameIauWebConfigTipuri (linia '+convert(varchar(20),ERROR_LINE())+'):'+char(10)+
				ERROR_MESSAGE()
	raiserror(@eroare,16,1)
end catch