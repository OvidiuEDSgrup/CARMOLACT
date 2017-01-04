CREATE TABLE [dbo].[TvaPeTerti] (
    [idTvaPeTert]   INT           IDENTITY (1, 1) NOT NULL,
    [tipf]          CHAR (1)      NULL,
    [Tert]          VARCHAR (20)  NULL,
    [dela]          DATETIME      NOT NULL,
    [tip_tva]       CHAR (1)      NOT NULL,
    [factura]       VARCHAR (20)  NULL,
    [dataadaugarii] DATETIME      DEFAULT (getdate()) NULL,
    [utilizator]    VARCHAR (100) DEFAULT ('') NULL,
    CHECK ([tip_tva]='I' OR [tip_tva]='N' OR [tip_tva]='P')
);


GO
CREATE UNIQUE CLUSTERED INDEX [pTvaPeTerti]
    ON [dbo].[TvaPeTerti]([tipf] ASC, [Tert] ASC, [factura] ASC, [dela] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [kTvaPeTerti]
    ON [dbo].[TvaPeTerti]([idTvaPeTert] ASC);


GO
/*
	Pentru a evita generarea de necorelatii triggerul nu permite stergerea liniilor legate de TERTI (la facturi se pot sterge) din TvaPeTerti
	Orice modificare a tipului de TVA din dreptul unui tert se realizeaza prin adaugarea unei inregistrari
*/
create  trigger tr_validTVAPeTerti on TVAPeTerti INSTEAD OF insert AS
begin try	

	/* Facem verificare pentru date ulterioare*/
	create table  #facturi_cu_tli (tip varchar(2), tipf char(1), tert varchar(20),factura varchar(20),tip_TVA char(1),data datetime,cont varchar(20))
	insert #facturi_cu_tli (tip,tipf,tert,factura,tip_TVA,data)
	select distinct p.tip,'F',t.tert,p.factura,'',p.data
	from inserted t
	left join pozdoc p on t.tipf='F' and p.tert=t.tert and p.data>=t.dela and p.tip in ('RM','RS') and p.procent_vama=0
	where t.factura is null

	exec tipTVAFacturi '01/31/2014','01/31/2014' --nu conteaza data. Ea se citeste din #facturi_cu_tli

	declare @facturi varchar(8000)
	set @facturi=''

	select @facturi=@facturi+rtrim(f.factura)+'('+f.tip_TVA+') din '+convert(char(10),f.data,103)+char(13)
	from inserted t
	inner join #facturi_cu_tli f on t.tert=f.tert
	where f.tip_TVA!=t.tip_tva

	-->	Daca scrierea se face dinspre operatia de Verificare terti ANAF (de la Inchidere conturi), atunci trebuie sa se poate scrie in TVAPeTerti. 
	-->	De acolo se scrie si in DocDeContat si apoi se apeleaza faInregistrariContabile. 
	if @facturi>'' and ISNULL(left(cast(CONTEXT_INFO() as varchar),20),'')<>'dinoperatiaverifanaf'
	begin
		declare @msgErr varchar(8000)
		set @msgErr='Aveti facturi introduse deja ce nu corespund cu noul tip de plata TVA. '
			+'Corectati-le si reveniti sau apelati operatia Verificare terti ANAF dinspre Inchidere conturi, de unde se permite modificarea tipului de TVA incepand cu prima zi a perioadei de raportare a declaratiilor 300/394!'+char(13)+@facturi
		raiserror(@msgerr,16,1)
	end

	INSERT INTO TvaPeTerti(tipf, Tert, dela, tip_tva, factura)
	SELECT tipf, Tert, dela, tip_tva, factura FROM INSERTED
		
end try
begin catch	
	ROLLBACK TRANSACTION
	declare @mesaj varchar(max)
	set @mesaj = ERROR_MESSAGE() +' (tr_validTVAPeTerti)'
	raiserror(@mesaj, 11, 1)
end catch

GO
/*
	Pentru a evita generarea de necorelatii triggerul nu permite stergerea liniilor legate de TERTI (la facturi se pot sterge) din TvaPeTerti
	Orice modificare a tipului de TVA din dreptul unui tert se realizeaza prin adaugarea unei inregistrari
*/
create  trigger tr_validTVAPeTertiUD on TVAPeTerti for update,delete as
begin try	
	
	IF EXISTS (select 1 from deleted where factura IS NULL)
		raiserror('Nu este permisa modificarea/stergerea! Pentru a modifica tipul de TVA se va introduce o noua inregistrare.',16,1)
end try
begin catch	
	ROLLBACK TRANSACTION
	declare @mesaj varchar(max)
	set @mesaj = ERROR_MESSAGE() +' (tr_validTVAPeTertiUD)'
	raiserror(@mesaj, 11, 1)
end catch
