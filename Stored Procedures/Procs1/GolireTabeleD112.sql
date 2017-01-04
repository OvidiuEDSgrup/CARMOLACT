--***
Create procedure GolireTabeleD112 @DataJ datetime, @DataS datetime
as  
Begin
	declare @utilizator varchar(20), @lmUtilizator varchar(9), @lmFiltru varchar(9), @nrLMFiltru int, @multiFirma int

--	citire utilizator 
	set @utilizator = dbo.fIaUtilizator(null)
	select @lmUtilizator='', @multiFirma=0, @nrLMFiltru=0
	if exists (select * from sysobjects where name ='par' and xtype='V')
		set @multiFirma=1

--	in cazul BD multifirma stabilesc locul de munca pe care lucreaza utilizatorul
	select @lmFiltru=isnull(min(Cod),''), @nrLMFiltru=count(1) from LMfiltrare where utilizator=@utilizator and cod in (select cod from lm where Nivel=1)
	if @multiFirma=1 or @nrLMFiltru=1
		select @lmUtilizator=@lmFiltru
	select @lmUtilizator=nullif(@lmUtilizator,'')

--	exec CreareTabeleD112
--	golire tabele angajator
	if exists (select * from sysobjects where name ='D112angajatorA')
		delete from D112angajatorA where data=@DataS and (@multiFirma=0 and @lmUtilizator is null or loc_de_munca=@lmUtilizator)
	if exists (select * from sysobjects where name ='D112angajatorB')
		delete from D112angajatorB where data=@DataS and (@multiFirma=0 and @lmUtilizator is null or loc_de_munca=@lmUtilizator)
	if exists (select * from sysobjects where name ='D112angajatorC5')
		delete from D112angajatorc5 where data=@DataS and (@multiFirma=0 and @lmUtilizator is null or loc_de_munca=@lmUtilizator)
	if exists (select * from sysobjects where name ='D112angajatorF2')
		delete from D112angajatorF2 where data=@DataS and (@multiFirma=0 and @lmUtilizator is null or loc_de_munca=@lmUtilizator)

--	golire tabele asigurati
	if exists (select * from sysobjects where name ='D112Asigurat')
		delete from D112Asigurat where data=@DataS and (@multiFirma=0 and @lmUtilizator is null or loc_de_munca=@lmUtilizator)
	if exists (select * from sysobjects where name ='D112coAsigurati')
		delete from D112coAsigurati where data=@DataS and (@multiFirma=0 and @lmUtilizator is null or loc_de_munca=@lmUtilizator)
	if exists (select * from sysobjects where name ='D112AsiguratA')
		delete from D112AsiguratA where data=@DataS and (@multiFirma=0 and @lmUtilizator is null or loc_de_munca=@lmUtilizator)
	if exists (select * from sysobjects where name ='D112AsiguratB1')
		delete from D112AsiguratB1 where data=@DataS and (@multiFirma=0 and @lmUtilizator is null or loc_de_munca=@lmUtilizator)
	if exists (select * from sysobjects where name ='D112AsiguratB11')
		delete from D112AsiguratB11 where data=@DataS and (@multiFirma=0 and @lmUtilizator is null or loc_de_munca=@lmUtilizator)
	if exists (select * from sysobjects where name ='D112AsiguratB234')
		delete from D112AsiguratB234 where data=@DataS and (@multiFirma=0 and @lmUtilizator is null or loc_de_munca=@lmUtilizator)
	if exists (select * from sysobjects where name ='D112AsiguratC')
		delete from D112AsiguratC where data=@DataS and (@multiFirma=0 and @lmUtilizator is null or loc_de_munca=@lmUtilizator)
	if exists (select * from sysobjects where name ='D112AsiguratD')
		delete from D112AsiguratD where data=@DataS and (@multiFirma=0 and @lmUtilizator is null or loc_de_munca=@lmUtilizator)
	if exists (select * from sysobjects where name ='D112AsiguratE3')
		delete from D112AsiguratE3 where data=@DataS and (@multiFirma=0 and @lmUtilizator is null or loc_de_munca=@lmUtilizator) and isnull(E3_4,'')<>'A'

End