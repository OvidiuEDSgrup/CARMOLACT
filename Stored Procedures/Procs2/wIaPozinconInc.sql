create procedure wIaPozinconInc @sesiune varchar(50) = null ,@parXML xml = null
as
declare @mesaj varchar(3000)
select @mesaj=''
begin try 
	declare @data datetime,@utilizator varchar(20),@lista_lm int
	select @data=@parXML.value('(/row/@data)[1]','datetime')
	
	--if @data is null
	--	raiserror('Data nu a fost gasita - problema de citire parametru!',16,1)
		
	declare @data_jos datetime, @data_sus datetime
	select @data_jos=dateadd(d,1-day(@data),@data)
	select @data_sus=dateadd(d,-1,dateadd(M,1,@data_jos))
	/*
if OBJECT_ID('wIaPozinconIncSP') is not null
begin
	exec wIaPozinconIncSP @sesiune,@parXML
	return
end*/

	EXEC wIaUtilizator @sesiune=@sesiune, @utilizator=@utilizator OUTPUT
	select @lista_lm=dbo.f_arelmfiltru(@utilizator)
	
	select convert(varchar(10), @data, 101) data
		 for xml raw, root('Date')

	SELECT (
		select top 100 p.Tip_document tip--,rtrim(p.Numar_document) nrdocument,CONVERT(char(10),p.Data,101) data
			,rtrim(p.Cont_debitor) contdebitor,rtrim(cd.Denumire_cont) dencontdebitor
			,rtrim(p.Cont_creditor) contcreditor,rtrim(cc.Denumire_cont) dencontcreditor
			,CONVERT(decimal(18,2),p.Suma)suma--,rtrim(p.Valuta) valuta	,convert(decimal(14, 4), p.curs) curs
			--,convert(decimal(18,2),p.Suma_valuta) sumavaluta
			,RTRIM(p.Explicatii) explicatii,
			RTRIM(p.Loc_de_munca) lm, RTRIM(p.Loc_de_munca)+'-'+rtrim(lm.Denumire) denlm
			--,rtrim(left(p.Comanda,20)) comanda,rtrim(p.indbug) as indbug
		from pozincon p
			left outer join conturi cd on p.Subunitate=cd.Subunitate and p.Cont_debitor=cd.Cont
			left outer join conturi cc on p.Subunitate=cc.Subunitate and p.Cont_creditor=cc.Cont
			left outer join lm on lm.Cod=p.Loc_de_munca
			left outer join pozplin pp on p.Subunitate=pp.Subunitate and p.Data=pp.Data	and p.Numar_document=pp.Cont 
				and p.Numar_pozitie=pp.idPozplin
		where ((p.Tip_document='IC' 
			and left(p.Numar_document, 2) in ('IC','IT')) or (p.Tip_document='PI' and pp.cont like '4428%'))
			and (@lista_lm=0 or exists (select 1 from lmfiltrare lu where lu.utilizator=@utilizator and lu.cod=p.loc_de_munca))
			and p.Data between @data_jos and @data_sus
			order by p.Tip_document, left(p.Numar_document, 2), p.Cont_debitor, p.Cont_creditor
		for xml raw, type
	)
	FOR XML path('DateGrid'), root('Mesaje')
	
	select 1 as areDetaliiXml FOR XML RAW, ROOT('Mesaje')
end try
begin catch
	set @mesaj = error_message() + ' ('+OBJECT_NAME(@@PROCID)+')'
end catch

if len(@mesaj)>0
raiserror(@mesaj, 11, 1)
