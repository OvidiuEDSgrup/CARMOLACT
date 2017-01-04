
create procedure pCoduriNC394 @sesiune varchar(50)=null, @parXML xml=NULL
as 
/*
	exec pCoduriNC394 @sesiune=null, @parXML=NULL
*/
begin try

	if object_id ('tempdb.dbo.#tmpCodNC394') is not null drop table #tmpCodNC394

	create table #tmpCodNC394 (codnc varchar(20), Denumire varchar(100))
	
	insert into #tmpCodNC394 
	--	coduri de cereale
	select '1001', 'Grau si meslin' union all
	select '1002', 'Secara' union all
	select '1003', 'Orz' union all
	select '1004', 'Ovaz' union all
	select '1005', 'Porumb' union all
	select '1201', 'Boabe de soia, chiar sfaramate' union all
	select '1205', 'Boabe Seminte de rapita sau de rapita salbatica, chiar sfaramate' union all
	select '120600', 'Seminte de floarea-soarelui, chiar sfaramate' union all
	select '121291', 'Sfecla de zahar' union all
	select '10086000', 'Triticale' union all
	select '120400', 'Seminte de in, chiar sfaramate ' union all
/*
	select '2', 'Alac (Triticum spelta), destinat insamantarii' union all
	select '3', 'Grau comun destinat insamantarii' union all
	select '4', 'Alt alac (Triticum spelta) si grau comun, nedestinate insamantarii' union all
*/	--	bunuri
	select '21', 'Cereale si plante tehnice' union all
	select '22', 'Deseuri feroase si neferoase' union all
	select '23', 'Masa lemnoasa' union all
	select '24', 'Certificate de emisii de gaze cu efect de sera' union all
	select '25', 'Energie electrica' union all
	select '26', 'Certificate verzi' union all
	select '27', 'Cladiri/terenuri pt tip partener = 1' union all
	select '28', 'Aur de investitii' union all
	select '29', 'Telefoane mobile' union all
	select '30', 'Microprocesoare' union all
	select '31', 'Console de jocuri, tablete PC si laptopuri' union all
	select '32', 'Terenuri' union all
	select '33', 'Cladiri' union all
	select '34', 'Alte bunuri' union all
	select '35', 'Servicii'

	if object_id('tempdb..#codnc394') is not null
		insert into #codnc394 (codnc, denumire)
		select codnc, denumire
		from #tmpCodNC394
	else 
		select codnc, denumire from #tmpCodNC394

end try
begin catch
	declare @mesaj varchar(2000)
	set @mesaj=ERROR_MESSAGE() + ' ('+OBJECT_NAME(@@PROCID)+')'
	raiserror (@mesaj, 15, 1)
end catch
