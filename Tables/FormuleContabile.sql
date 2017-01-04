CREATE TABLE [dbo].[FormuleContabile] (
    [tip]           VARCHAR (2)   NULL,
    [cont_debit]    VARCHAR (40)  NULL,
    [cont_credit]   VARCHAR (40)  NULL,
    [utilizator]    VARCHAR (200) NULL,
    [data_operarii] DATETIME      DEFAULT (getdate()) NULL
);


GO


CREATE trigger ValidareFormuleSterg on FormuleContabile for update, delete NOT FOR REPLICATION 
as

	declare 
		@Utilizator char(10), @Aplicatia char(30)

	select 
		@Utilizator=dbo.fIauUtilizatorCurent()
	select top 1 
		@Aplicatia=Aplicatia from sysunic where hostid=host_id() and data_iesirii is null order by data_intrarii desc
	select
		@Aplicatia=left(isnull(@Aplicatia, APP_NAME()), 30)

	insert into syssformulec ([host_name], aplicatia, data_stergere, stergator, tip, cont_debit, cont_credit, utilizator, data_operarii)
	select 
		host_name (), @Aplicatia, getdate(), @Utilizator, tip, cont_debit, cont_credit, utilizator, data_operarii
	from deleted
