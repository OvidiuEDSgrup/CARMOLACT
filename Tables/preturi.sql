CREATE TABLE [dbo].[preturi] (
    [Cod_produs]        CHAR (20)   NOT NULL,
    [UM]                SMALLINT    NOT NULL,
    [Tip_pret]          CHAR (20)   NOT NULL,
    [Data_inferioara]   DATETIME    NOT NULL,
    [Ora_inferioara]    CHAR (13)   NOT NULL,
    [Data_superioara]   DATETIME    NOT NULL,
    [Ora_superioara]    CHAR (6)    NOT NULL,
    [Pret_vanzare]      FLOAT (53)  NOT NULL,
    [Pret_cu_amanuntul] FLOAT (53)  NOT NULL,
    [Utilizator]        CHAR (10)   NOT NULL,
    [Data_operarii]     DATETIME    NOT NULL,
    [Ora_operarii]      CHAR (6)    NOT NULL,
    [umprodus]          VARCHAR (3) NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Cheie_unica]
    ON [dbo].[preturi]([Cod_produs] ASC, [UM] ASC, [umprodus] ASC, [Tip_pret] ASC, [Data_inferioara] ASC, [Ora_inferioara] ASC, [Ora_superioara] ASC, [Ora_operarii] ASC);


GO
CREATE NONCLUSTERED INDEX [Regasire]
    ON [dbo].[preturi]([Cod_produs] ASC, [Tip_pret] ASC, [umprodus] ASC, [Data_inferioara] ASC, [Ora_inferioara] ASC, [Ora_superioara] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Principal]
    ON [dbo].[preturi]([Cod_produs] ASC, [UM] ASC, [umprodus] ASC, [Tip_pret] ASC, [Data_superioara] ASC, [Ora_inferioara] ASC, [Ora_superioara] ASC, [Ora_operarii] ASC);


GO
CREATE NONCLUSTERED INDEX [missing_index_252]
    ON [dbo].[preturi]([UM] ASC, [Data_inferioara] ASC, [Data_superioara] ASC)
    INCLUDE([Tip_pret], [Pret_cu_amanuntul]);


GO
CREATE NONCLUSTERED INDEX [missing_index_249]
    ON [dbo].[preturi]([UM] ASC, [Data_inferioara] ASC, [Data_superioara] ASC)
    INCLUDE([Tip_pret], [Pret_vanzare]);


GO
CREATE NONCLUSTERED INDEX [missing_index_1007]
    ON [dbo].[preturi]([Data_inferioara] ASC, [Data_superioara] ASC)
    INCLUDE([Cod_produs], [UM], [Tip_pret], [Pret_vanzare], [Pret_cu_amanuntul]);


GO
CREATE NONCLUSTERED INDEX [missing_index_997]
    ON [dbo].[preturi]([UM] ASC, [Tip_pret] ASC, [Data_inferioara] ASC)
    INCLUDE([Cod_produs], [Ora_inferioara], [Data_superioara], [Ora_superioara], [Pret_vanzare], [Pret_cu_amanuntul], [umprodus]);


GO
--***
create trigger [dbo].[preturiazi] on [dbo].[preturi] for insert, update, delete NOT FOR REPLICATION as  
 
/*Trebuie sa ignoram modificarea datei superioare din preturi*/
select i.cod_produs,i.um,i.tip_pret,i.data_inferioara,i.pret_vanzare
	into #modificatecorect
	from inserted i
	inner join deleted d on i.cod_produs=d.cod_produs and i.um=d.um and i.tip_pret=d.tip_pret and i.data_inferioara=d.data_inferioara and i.pret_vanzare=d.pret_vanzare


declare @datamin datetime
set @datamin=convert(datetime,convert(char(10),getdate(),101))
if exists (select 1 from inserted i
			left outer join #modificatecorect m on i.cod_produs=m.cod_produs and i.um=m.um and i.tip_pret=m.tip_pret and i.data_inferioara=m.data_inferioara and i.pret_vanzare=m.pret_vanzare
			where i.data_inferioara < @datamin
			and m.cod_produs is null) --Nu este in modificarile corecte
begin  
 RAISERROR ('(tr)PreturiAzi: Eroare integritate date. Nu puteti modifica preturile in trecut.', 16, 1)  
 rollback transaction  
end

if exists (select 1 from deleted m
			left outer join inserted i on i.cod_produs=m.cod_produs and i.um=m.um and i.tip_pret=m.tip_pret and i.data_inferioara=m.data_inferioara and i.pret_vanzare=m.pret_vanzare
			where m.data_inferioara < @datamin 
			and i.cod_produs is null) --Este stergere fara modificare
begin  
 RAISERROR ('(tr)PreturiAzi: Eroare integritate date. Nu puteti stege un pret anterior valabil.', 16, 1)  
 rollback transaction  
end

GO
--***
CREATE trigger preturisterg on preturi for update, delete  NOT FOR REPLICATION as

declare @Utilizator char(10), @Aplicatia char(30)

set @Utilizator=dbo.fIauUtilizatorCurent()
select top 1 @Aplicatia=Aplicatia from sysunic where hostid=host_id() and data_iesirii is null order by data_intrarii desc
set @Aplicatia=left(isnull(@Aplicatia, APP_NAME()), 30)

insert into sysspv
	select host_id(),host_name (),@Aplicatia,getdate(),@Utilizator, data_operarii, ora_operarii,
	Cod_produs, UM, Tip_pret, Data_inferioara, Ora_inferioara, Data_superioara, Ora_superioara, 
	Pret_vanzare, Pret_cu_amanuntul, Utilizator
   from deleted
