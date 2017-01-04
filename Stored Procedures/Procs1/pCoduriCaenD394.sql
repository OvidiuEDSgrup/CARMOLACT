--***
Create procedure pCoduriCaenD394
as
begin
	if object_id('tempdb..#tmpCaen394') is not null 
		drop table #tmpCaen394
	create table #tmpCaen394 (cod varchar(10), denumire varchar(250))

	insert into #tmpCaen394 (cod, denumire)
	select '1071', 'Cofetarie si produse de patiserie' union all
	select '4520', 'Spalatorie auto' union all 
	select '4730', 'Comert cu amanuntul al carburantilor pentru autovehicule in magazine specializate' union all 
	select '47761', 'Comert cu amanuntul al florilor, plantelor si semintelor' union all
	select '47762', 'Comert cu amanuntul al animalelor de companie si a hranei pentru acestea, in magazine specializate' union all
	select '4932', 'Transporturi cu taxiuri' union all
	select '55101', 'Hoteluri' union all
	select '55102', 'Pensiuni turistice' union all
	select '56103', 'Restaurante' union all
	select '5630', 'Baruri si activitati de servire a bauturilor' union all
	select '812', 'Activitati de curatenie' union all
	select '9313', 'Activitati ale centrelor de fitness' union all
	select '9602', 'Activitati de coafura si de infrumusetare' union all
	select '9603', 'Servicii de pompe funebre' 
	
	if object_id('tempdb..#codCaen394') is not null 
		insert into #codCaen394 (cod, denumire)
		select * from #tmpCaen394
	else
		select * from #tmpCaen394
end
