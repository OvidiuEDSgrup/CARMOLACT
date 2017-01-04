CREATE TABLE [dbo].[rulaje] (
    [Subunitate]   CHAR (9)     NOT NULL,
    [Cont]         VARCHAR (20) NOT NULL,
    [Loc_de_munca] CHAR (9)     NOT NULL,
    [Valuta]       CHAR (3)     NOT NULL,
    [Data]         DATETIME     NOT NULL,
    [Rulaj_debit]  FLOAT (53)   NOT NULL,
    [Rulaj_credit] FLOAT (53)   NOT NULL,
    [Indbug]       VARCHAR (20) CONSTRAINT [DF__rulaje__Indbug__29D5E24F] DEFAULT ('') NOT NULL,
    CONSTRAINT [PK_rulaje] PRIMARY KEY CLUSTERED ([Subunitate] ASC, [Cont] ASC, [Data] ASC, [Valuta] ASC, [Loc_de_munca] ASC, [Indbug] ASC) ON [SYNTHESIS]
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Cont_Lm_Data_Valuta]
    ON [dbo].[rulaje]([Subunitate] ASC, [Cont] ASC, [Loc_de_munca] ASC, [Data] ASC, [Valuta] ASC, [Indbug] ASC)
    ON [SYNTHESIS];


GO
CREATE UNIQUE NONCLUSTERED INDEX [Lm_Cont_Data_Valuta]
    ON [dbo].[rulaje]([Subunitate] ASC, [Loc_de_munca] ASC, [Cont] ASC, [Data] ASC, [Valuta] ASC, [Indbug] ASC)
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [Pentru_inchidere]
    ON [dbo].[rulaje]([Subunitate] ASC, [Data] ASC, [Cont] ASC, [Loc_de_munca] ASC)
    ON [SYNTHESIS];


GO
CREATE UNIQUE NONCLUSTERED INDEX [Valuta_Cont_Data]
    ON [dbo].[rulaje]([Subunitate] ASC, [Valuta] ASC, [Cont] ASC, [Data] ASC, [Loc_de_munca] ASC, [Indbug] ASC)
    ON [SYNTHESIS];


GO
CREATE UNIQUE NONCLUSTERED INDEX [Valuta_Data_Cont]
    ON [dbo].[rulaje]([Subunitate] ASC, [Valuta] ASC, [Data] ASC, [Cont] ASC, [Loc_de_munca] ASC, [Indbug] ASC)
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [missing_index_4009]
    ON [dbo].[rulaje]([Subunitate] ASC, [Valuta] ASC, [Data] ASC)
    INCLUDE([Cont], [Rulaj_debit], [Rulaj_credit])
    ON [SYNTHESIS];


GO
--***
CREATE trigger rulajeinisterg on rulaje for insert,update, delete  NOT FOR REPLICATION as
begin

declare @Utilizator char(10), @Aplicatia char(30)

set @Utilizator=dbo.fIauUtilizatorCurent()
select top 1 @Aplicatia=Aplicatia from sysunic where hostid=host_id() and data_iesirii is null order by data_intrarii desc
set @Aplicatia=left(isnull(@Aplicatia, APP_NAME()), 30)

insert into syssrulsoldi
	select host_id(),host_name (), @Aplicatia, getdate(),@Utilizator, 'A', 
		Subunitate,Cont,Valuta,Data,Rulaj_debit,Rulaj_credit
   from inserted 
	where month(data) = 1 and day(data) = 1 
	
insert into syssrulsoldi
	select host_id(),host_name (), @Aplicatia, getdate(),@Utilizator,
		'S', Subunitate,Cont,Valuta,Data,Rulaj_debit,Rulaj_credit
   from deleted
	where month(data) = 1 and day(data) = 1 
end
