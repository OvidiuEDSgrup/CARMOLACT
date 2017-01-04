CREATE TABLE [dbo].[con] (
    [Subunitate]         VARCHAR (9)   NOT NULL,
    [Tip]                VARCHAR (2)   NOT NULL,
    [Contract]           VARCHAR (20)  NOT NULL,
    [Tert]               VARCHAR (13)  NOT NULL,
    [Punct_livrare]      VARCHAR (13)  NOT NULL,
    [Data]               DATETIME2 (0) NOT NULL,
    [Stare]              CHAR (1)      NOT NULL,
    [Loc_de_munca]       VARCHAR (9)   NOT NULL,
    [Gestiune]           VARCHAR (9)   NOT NULL,
    [Termen]             DATETIME2 (0) NOT NULL,
    [Scadenta]           SMALLINT      NOT NULL,
    [Discount]           REAL          NOT NULL,
    [Valuta]             VARCHAR (3)   NOT NULL,
    [Curs]               FLOAT (53)    NOT NULL,
    [Mod_plata]          VARCHAR (1)   NOT NULL,
    [Mod_ambalare]       VARCHAR (1)   NOT NULL,
    [Factura]            VARCHAR (20)  NOT NULL,
    [Total_contractat]   FLOAT (53)    NOT NULL,
    [Total_TVA]          FLOAT (53)    NOT NULL,
    [Contract_coresp]    VARCHAR (20)  NOT NULL,
    [Mod_penalizare]     VARCHAR (13)  NOT NULL,
    [Procent_penalizare] REAL          NOT NULL,
    [Procent_avans]      REAL          NOT NULL,
    [Avans]              FLOAT (53)    NOT NULL,
    [Nr_rate]            SMALLINT      NOT NULL,
    [Val_reziduala]      FLOAT (53)    NOT NULL,
    [Sold_initial]       FLOAT (53)    NOT NULL,
    [Cod_dobanda]        VARCHAR (20)  NOT NULL,
    [Dobanda]            REAL          NOT NULL,
    [Incasat]            FLOAT (53)    NOT NULL,
    [Responsabil]        VARCHAR (20)  NOT NULL,
    [Responsabil_tert]   VARCHAR (20)  NOT NULL,
    [Explicatii]         VARCHAR (50)  NOT NULL,
    [Data_rezilierii]    DATETIME      NOT NULL,
    [detalii]            XML           NULL,
    [idCon]              INT           IDENTITY (-1, -1) NOT NULL,
    CONSTRAINT [PK_con] PRIMARY KEY NONCLUSTERED ([idCon] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Principal]
    ON [dbo].[con]([Subunitate] ASC, [Tip] ASC, [Contract] ASC, [Data] ASC, [Tert] ASC);


GO
CREATE NONCLUSTERED INDEX [Tip_Numar]
    ON [dbo].[con]([Subunitate] ASC, [Tip] ASC, [Contract] ASC);


GO
CREATE NONCLUSTERED INDEX [Pe_tert]
    ON [dbo].[con]([Subunitate] ASC, [Tip] ASC, [Tert] ASC, [Data] ASC, [Contract] ASC);


GO
CREATE NONCLUSTERED INDEX [missing_index_275]
    ON [dbo].[con]([Subunitate] ASC, [Contract] ASC, [Tert] ASC, [Tip] ASC, [Data] ASC);


GO
CREATE NONCLUSTERED INDEX [missing_index_241]
    ON [dbo].[con]([Contract] ASC, [Tert] ASC, [Data] ASC);


GO
CREATE NONCLUSTERED INDEX [missing_index_227]
    ON [dbo].[con]([Subunitate] ASC, [Tip] ASC, [Tert] ASC, [Stare] ASC)
    INCLUDE([Contract], [Data], [Factura]);


GO
CREATE NONCLUSTERED INDEX [missing_index_264]
    ON [dbo].[con]([Subunitate] ASC, [Tip] ASC, [Data] ASC, [Responsabil] ASC, [Contract] ASC)
    INCLUDE([Tert], [Punct_livrare], [Stare], [Loc_de_munca], [Gestiune], [Termen], [Scadenta], [Discount], [Valuta], [Curs], [Mod_plata], [Mod_ambalare], [Factura], [Total_contractat], [Total_TVA], [Contract_coresp], [Mod_penalizare], [Procent_penalizare], [Procent_avans], [Avans], [Nr_rate], [Val_reziduala], [Sold_initial], [Cod_dobanda], [Dobanda], [Incasat], [Responsabil_tert], [Explicatii], [Data_rezilierii]);


GO
CREATE NONCLUSTERED INDEX [missing_index_906]
    ON [dbo].[con]([Subunitate] ASC, [Tip] ASC, [Tert] ASC, [Stare] ASC, [Data] ASC)
    INCLUDE([Contract], [Punct_livrare], [Loc_de_munca], [Gestiune], [Termen], [Scadenta], [Discount], [Valuta], [Curs], [Mod_plata], [Mod_ambalare], [Factura], [Total_contractat], [Total_TVA], [Contract_coresp], [Mod_penalizare], [Procent_penalizare], [Procent_avans], [Avans], [Nr_rate], [Val_reziduala], [Sold_initial], [Cod_dobanda], [Dobanda], [Incasat], [Responsabil], [Responsabil_tert], [Explicatii], [Data_rezilierii]);


GO
CREATE NONCLUSTERED INDEX [missing_index_277]
    ON [dbo].[con]([Subunitate] ASC, [Tip] ASC, [Data] ASC, [Contract] ASC)
    INCLUDE([Tert], [Punct_livrare], [Stare], [Loc_de_munca], [Gestiune], [Termen], [Scadenta], [Discount], [Valuta], [Curs], [Mod_plata], [Mod_ambalare], [Factura], [Total_contractat], [Total_TVA], [Contract_coresp], [Mod_penalizare], [Procent_penalizare], [Procent_avans], [Avans], [Nr_rate], [Val_reziduala], [Sold_initial], [Cod_dobanda], [Dobanda], [Incasat], [Responsabil], [Responsabil_tert], [Explicatii], [Data_rezilierii]);


GO
CREATE NONCLUSTERED INDEX [missing_index_310]
    ON [dbo].[con]([Tip] ASC, [Data] ASC)
    INCLUDE([Tert], [Gestiune]);


GO
CREATE NONCLUSTERED INDEX [missing_index_260]
    ON [dbo].[con]([Subunitate] ASC, [Tip] ASC, [Stare] ASC, [Cod_dobanda] ASC)
    INCLUDE([Contract], [Tert], [Data], [Gestiune]);


GO
CREATE NONCLUSTERED INDEX [missing_index_320]
    ON [dbo].[con]([Tip] ASC, [Data] ASC)
    INCLUDE([Contract], [Tert], [Punct_livrare], [Gestiune], [Total_contractat], [Total_TVA]);


GO
CREATE NONCLUSTERED INDEX [missing_index_904]
    ON [dbo].[con]([Subunitate] ASC, [Tip] ASC, [Tert] ASC, [Stare] ASC, [Contract] ASC)
    INCLUDE([Punct_livrare], [Data], [Loc_de_munca], [Gestiune], [Termen], [Scadenta], [Discount], [Valuta], [Curs], [Mod_plata], [Mod_ambalare], [Factura], [Total_contractat], [Total_TVA], [Contract_coresp], [Mod_penalizare], [Procent_penalizare], [Procent_avans], [Avans], [Nr_rate], [Val_reziduala], [Sold_initial], [Cod_dobanda], [Dobanda], [Incasat], [Responsabil], [Responsabil_tert], [Explicatii], [Data_rezilierii]);


GO
CREATE NONCLUSTERED INDEX [missing_index_92]
    ON [dbo].[con]([Subunitate] ASC, [Tert] ASC, [Tip] ASC)
    INCLUDE([Contract], [Data], [Stare], [Termen], [Total_contractat]);


GO
CREATE NONCLUSTERED INDEX [missing_index_1080]
    ON [dbo].[con]([Subunitate] ASC, [Tip] ASC, [Tert] ASC, [Data] ASC)
    INCLUDE([Contract], [Punct_livrare], [Stare], [Loc_de_munca], [Gestiune], [Termen], [Scadenta], [Discount], [Valuta], [Curs], [Mod_plata], [Mod_ambalare], [Factura], [Total_contractat], [Total_TVA], [Contract_coresp], [Mod_penalizare], [Procent_penalizare], [Procent_avans], [Avans], [Nr_rate], [Val_reziduala], [Sold_initial], [Cod_dobanda], [Dobanda], [Incasat], [Responsabil], [Responsabil_tert], [Explicatii], [Data_rezilierii]);


GO
CREATE NONCLUSTERED INDEX [missing_index_1078]
    ON [dbo].[con]([Subunitate] ASC, [Tip] ASC, [Tert] ASC, [Contract] ASC)
    INCLUDE([Punct_livrare], [Data], [Stare], [Loc_de_munca], [Gestiune], [Termen], [Scadenta], [Discount], [Valuta], [Curs], [Mod_plata], [Mod_ambalare], [Factura], [Total_contractat], [Total_TVA], [Contract_coresp], [Mod_penalizare], [Procent_penalizare], [Procent_avans], [Avans], [Nr_rate], [Val_reziduala], [Sold_initial], [Cod_dobanda], [Dobanda], [Incasat], [Responsabil], [Responsabil_tert], [Explicatii], [Data_rezilierii]);


GO
CREATE NONCLUSTERED INDEX [missing_index_944]
    ON [dbo].[con]([Subunitate] ASC, [Tip] ASC, [Punct_livrare] ASC, [Data] ASC)
    INCLUDE([Contract], [Tert], [Stare], [Loc_de_munca], [Gestiune], [Termen], [Scadenta], [Discount], [Valuta], [Curs], [Mod_plata], [Mod_ambalare], [Factura], [Total_contractat], [Total_TVA], [Contract_coresp], [Mod_penalizare], [Procent_penalizare], [Procent_avans], [Avans], [Nr_rate], [Val_reziduala], [Sold_initial], [Cod_dobanda], [Dobanda], [Incasat], [Responsabil], [Responsabil_tert], [Explicatii], [Data_rezilierii]);


GO
CREATE NONCLUSTERED INDEX [missing_index_1198]
    ON [dbo].[con]([Tip] ASC, [Data] ASC, [Gestiune] ASC)
    INCLUDE([Contract], [Tert], [Punct_livrare], [Explicatii]);


GO
CREATE NONCLUSTERED INDEX [missing_index_6128]
    ON [dbo].[con]([Data] ASC, [Gestiune] ASC)
    INCLUDE([Contract]);


GO
CREATE NONCLUSTERED INDEX [missing_index_6126]
    ON [dbo].[con]([Data] ASC, [Gestiune] ASC)
    INCLUDE([Subunitate], [Tip], [Contract], [Tert], [Punct_livrare], [Stare], [Loc_de_munca], [Termen], [Scadenta], [Discount], [Valuta], [Curs], [Mod_plata], [Mod_ambalare], [Factura], [Total_contractat], [Total_TVA], [Contract_coresp], [Mod_penalizare], [Procent_penalizare], [Procent_avans], [Avans], [Nr_rate], [Val_reziduala], [Sold_initial], [Cod_dobanda], [Dobanda], [Incasat], [Responsabil], [Responsabil_tert], [Explicatii], [Data_rezilierii], [detalii], [idCon]);


GO
CREATE NONCLUSTERED INDEX [missing_index_4248]
    ON [dbo].[con]([Data] ASC, [Gestiune] ASC)
    INCLUDE([Contract]);


GO
CREATE NONCLUSTERED INDEX [missing_index_6130]
    ON [dbo].[con]([Data] ASC, [Gestiune] ASC)
    INCLUDE([Contract], [Tert]);


GO
CREATE NONCLUSTERED INDEX [missing_index_968]
    ON [dbo].[con]([Subunitate] ASC, [Tip] ASC, [Gestiune] ASC, [Data] ASC)
    INCLUDE([Contract], [Tert], [Punct_livrare], [Stare], [Loc_de_munca], [Termen], [Scadenta], [Discount], [Valuta], [Curs], [Mod_plata], [Mod_ambalare], [Factura], [Total_contractat], [Total_TVA], [Contract_coresp], [Mod_penalizare], [Procent_penalizare], [Procent_avans], [Avans], [Nr_rate], [Val_reziduala], [Sold_initial], [Cod_dobanda], [Dobanda], [Incasat], [Responsabil], [Responsabil_tert], [Explicatii], [Data_rezilierii]);


GO
CREATE NONCLUSTERED INDEX [missing_index_995]
    ON [dbo].[con]([Tip] ASC, [Tert] ASC)
    INCLUDE([Subunitate], [Contract], [Data], [Valuta]);


GO
CREATE NONCLUSTERED INDEX [missing_index_39]
    ON [dbo].[con]([Data] ASC, [Gestiune] ASC)
    INCLUDE([Contract], [Tert]);


GO
CREATE NONCLUSTERED INDEX [missing_index_127]
    ON [dbo].[con]([Tip] ASC, [Tert] ASC)
    INCLUDE([Subunitate], [Contract], [Data], [Valuta]);


GO
--***
create trigger yso_tr_actualizeazaContracte on con after insert,update,delete
as
--if TRIGGER_NESTLEVEL()>2
	--return
BEGIN TRY
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 

	IF OBJECT_ID('temdb.dbo.#con') IS NOT NULL DROP TABLE #con

	select actiune=(case when i.idCon is null then 'DEL' when d.idCon is null then 'INS' else 'UPD' end)
		,idCon=isnull(i.idCon,d.idCon),Subunitate=isnull(i.Subunitate,d.Subunitate)
		,Tip=(case isnull(i.Tip,d.Tip) when 'BF' then 'CB' when 'BK' then 'CL' when 'FA' then 'CF' when 'FC' then 'CA' end)
		,Data=isnull(i.Data,d.Data),numar=isnull(i.Contract,d.Contract),Tert=isnull(i.Tert,d.Tert)
		,Punct_livrare=isnull(i.Punct_livrare,d.Punct_livrare),Stare=isnull(i.Stare,d.Stare),Loc_de_munca=isnull(i.Loc_de_munca,d.Loc_de_munca),Gestiune=isnull(i.Gestiune,d.Gestiune),Termen=isnull(i.Termen,d.Termen),Scadenta=isnull(i.Scadenta,d.Scadenta),Discount=isnull(i.Discount,d.Discount),Valuta=isnull(i.Valuta,d.Valuta),Curs=isnull(i.Curs,d.Curs),Mod_plata=isnull(i.Mod_plata,d.Mod_plata),Mod_ambalare=isnull(i.Mod_ambalare,d.Mod_ambalare),Factura=isnull(i.Factura,d.Factura),Total_contractat=isnull(i.Total_contractat,d.Total_contractat),Total_TVA=isnull(i.Total_TVA,d.Total_TVA)
		,Contract_coresp=isnull(i.Contract_coresp,d.Contract_coresp),Mod_penalizare=isnull(i.Mod_penalizare,d.Mod_penalizare),Procent_penalizare=isnull(i.Procent_penalizare,d.Procent_penalizare),Procent_avans=isnull(i.Procent_avans,d.Procent_avans),Avans=isnull(i.Avans,d.Avans),Nr_rate=isnull(i.Nr_rate,d.Nr_rate),Val_reziduala=isnull(i.Val_reziduala,d.Val_reziduala),Sold_initial=isnull(i.Sold_initial,d.Sold_initial),Cod_dobanda=isnull(i.Cod_dobanda,d.Cod_dobanda),Dobanda=isnull(i.Dobanda,d.Dobanda),Incasat=isnull(i.Incasat,d.Incasat),Responsabil=isnull(i.Responsabil,d.Responsabil),Responsabil_tert=isnull(i.Responsabil_tert,d.Responsabil_tert),Explicatii=isnull(i.Explicatii,d.Explicatii),Data_rezilierii=isnull(i.Data_rezilierii,d.Data_rezilierii)
		,detalii=isnull(i.detalii,d.detalii)
	into #con
	from inserted i full join deleted d on d.idCon=i.idCon
	where isnull(i.Tip,d.Tip) in ('BF','BK','FA','FC')

	UPDATE Contracte SET idContractCorespondent=NULL
	WHERE idContractCorespondent IN (SELECT idCon FROM #con cn WHERE cn.actiune='DEL')

	DELETE FisiereContract 
	WHERE idContract IN (SELECT idCon FROM #con cn WHERE cn.actiune='DEL')

	IF OBJECT_ID('temdb.dbo.#jurnalc') IS NOT NULL DROP TABLE #jurnalc

	SELECT TOP (0) convert(int, idJurnal) AS idjurnal 
	INTO #jurnalc
	FROM JurnalContracte

	DELETE JurnalContracte
	OUTPUT deleted.idJurnal INTO #jurnalc(idjurnal)
	WHERE idContract IN (SELECT idCon FROM #con cn WHERE cn.actiune='DEL')

	DELETE LegaturiContracte
	WHERE idJurnal IN (SELECT idJurnal FROM #jurnalc)

	DELETE PozContracte 
	WHERE idContract IN (SELECT idCon FROM #con cn WHERE cn.actiune='DEL')

	DELETE RateContracte 
	WHERE idContract IN (SELECT idCon FROM #con cn WHERE cn.actiune='DEL')

	DELETE Contracte
	WHERE idContract IN (SELECT idCon FROM #con cn WHERE cn.actiune='DEL')

	UPDATE Contracte SET tip=cn.tip, numar=cn.numar,data=cn.data,tert=nullif(cn.tert,''),punct_livrare=nullif(cn.punct_livrare,''),
		gestiune=nullif(cn.gestiune,''),gestiune_primitoare=nullif(cn.cod_dobanda,''),loc_de_munca=nullif(cn.loc_de_munca,''),valuta=cn.valuta,curs=cn.curs,
		valabilitate=(case when cn.termen>cn.data then cn.termen end),explicatii=cn.explicatii,idContractCorespondent=null,AWB=null
		,detalii=(select Subunitate=rtrim(nullif(cn.Subunitate,'')),Stare=rtrim(nullif(cn.Stare,''))
			,Scadenta=nullif(cn.Scadenta,0),Discount=convert(decimal(12,2),nullif(cn.Discount,0))
			,Mod_plata=rtrim(nullif(cn.Mod_plata,'')),Mod_ambalare=rtrim(nullif(cn.Mod_ambalare,''))
			,Factura=rtrim(nullif(cn.Factura,'')),Total_contractat=convert(decimal(15,2),nullif(cn.Total_contractat,0))
			,Total_TVA=convert(decimal(15,2),nullif(cn.Total_TVA,0))
			,Contract_coresp=rtrim(nullif(cn.Contract_coresp,'')),Mod_penalizare=rtrim(nullif(cn.Mod_penalizare,''))
			,Procent_penalizare=convert(decimal(12,2),nullif(cn.Procent_penalizare,0))
			,Procent_avans=convert(decimal(12,2),nullif(cn.Procent_avans,0))
			,Avans=convert(decimal(15,2),nullif(cn.Avans,0))
			,Nr_rate=nullif(cn.Nr_rate,0),Val_reziduala=convert(decimal(15,2),nullif(cn.Val_reziduala,0))
			,Sold_initial=convert(decimal(15,2),nullif(cn.Sold_initial,0)),Cod_dobanda=rtrim(nullif(cn.Cod_dobanda,''))
			,Dobanda=convert(decimal(12,2),nullif(cn.Dobanda,0)),Incasat=convert(decimal(15,2),nullif(cn.Incasat,0))
			,Responsabil=rtrim(nullif(cn.Responsabil,'')),Responsabil_tert=rtrim(nullif(cn.Responsabil_tert,''))
			,Data_rezilierii=convert(varchar(10),nullif(cn.Data_rezilierii,'01/01/1900'),101)
			for xml raw, type)
	FROM #con cn 
	WHERE cn.idCon = Contracte.idContract
		
	set identity_insert contracte on	
	insert into Contracte (idContract,tip,numar,data,tert,punct_livrare,gestiune,gestiune_primitoare,loc_de_munca,valuta,curs,valabilitate,explicatii,idContractCorespondent,AWB,detalii)
	select idCon,tip,numar,data,nullif(tert,''),nullif(punct_livrare,''),gestiune,nullif(cod_dobanda,''),nullif(loc_de_munca,''),valuta,curs,(case when cn.termen>cn.data then cn.termen end),explicatii,null,null
		,(select Subunitate=rtrim(nullif(cn.Subunitate,'')),Stare=rtrim(nullif(cn.Stare,''))
				,Scadenta=nullif(cn.Scadenta,0),Discount=convert(decimal(12,2),nullif(cn.Discount,0))
				,Mod_plata=rtrim(nullif(cn.Mod_plata,'')),Mod_ambalare=rtrim(nullif(cn.Mod_ambalare,''))
				,Factura=rtrim(nullif(cn.Factura,'')),Total_contractat=convert(decimal(15,2),nullif(cn.Total_contractat,0))
				,Total_TVA=convert(decimal(15,2),nullif(cn.Total_TVA,0))
				,Contract_coresp=rtrim(nullif(cn.Contract_coresp,'')),Mod_penalizare=rtrim(nullif(cn.Mod_penalizare,''))
				,Procent_penalizare=convert(decimal(12,2),nullif(cn.Procent_penalizare,0))
				,Procent_avans=convert(decimal(12,2),nullif(cn.Procent_avans,0))
				,Avans=convert(decimal(15,2),nullif(cn.Avans,0))
				,Nr_rate=nullif(cn.Nr_rate,0),Val_reziduala=convert(decimal(15,2),nullif(cn.Val_reziduala,0))
				,Sold_initial=convert(decimal(15,2),nullif(cn.Sold_initial,0)),Cod_dobanda=rtrim(nullif(cn.Cod_dobanda,''))
				,Dobanda=convert(decimal(12,2),nullif(cn.Dobanda,0)),Incasat=convert(decimal(15,2),nullif(cn.Incasat,0))
				,Responsabil=rtrim(nullif(cn.Responsabil,'')),Responsabil_tert=rtrim(nullif(cn.Responsabil_tert,''))
				,Data_rezilierii=convert(varchar(10),nullif(cn.Data_rezilierii,'01/01/1900'),101)
			for xml raw, type)
	FROM #con cn WHERE cn.idCon NOT IN (SELECT idContract FROM Contracte ct)
	set identity_insert contracte off	

	INSERT INTO JurnalContracte (idContract, data, stare, explicatii, detalii, utilizator)
		--OUTPUT inserted.idJurnal, inserted.idContract INTO #jurnalIntrodus(idJurnal, idContract)
	select idCon, GETDATE() data, ISNULL(c.stare,-900), rtrim(s.denumire) explicatii, detalii, isnull(nullif(dbo.fIaUtilizator(null),''),SUSER_NAME())
	from (select i.idCon, i.stare
			,tip=(case i.Tip when 'BF' then 'CB' when 'BK' then 'CL' when 'FA' then 'CF' when 'FC' then 'CA' end)
		from inserted i left join deleted d on d.idCon=i.idCon
		where coalesce(i.Stare,-900)<>coalesce(d.Stare,-900) ) c 
		join StariContracte s on s.tipContract=c.tip and s.stare=c.stare
		outer apply (select top 1 stare from JurnalContracte j where j.idContract=c.idCon 
			order by j.data desc, j.idJurnal desc) j
	where isnull(j.stare,-900)<>isnull(c.stare,-900)
		
END TRY
BEGIN CATCH
	declare @mesaj varchar(600)
	set @mesaj=ERROR_MESSAGE() + ' ('+OBJECT_NAME(@@PROCID)+')'
	raiserror (@mesaj, 15, 1)
END CATCH 

GO
--***
Create trigger DelExtcon on dbo.con for delete
as
Delete from extcon  where exists 
(select * from deleted d where d.subunitate = extcon.subunitate and d.tip = extcon.tip and d.contract = extcon.contract and d.data = extcon.data and d.tert = extcon.tert)

GO
--***
CREATE trigger consterg on con for update, delete  NOT FOR REPLICATION as

declare @Utilizator char(10), @Aplicatia char(30)

set @Utilizator=dbo.fIauUtilizatorCurent()
select top 1 @Aplicatia=Aplicatia from sysunic where hostid=host_id() and data_iesirii is null order by data_intrarii desc
set @Aplicatia=left(isnull(@Aplicatia, APP_NAME()), 30)

insert into sysscon
	select host_id(),host_name (),@Aplicatia,getdate(),@Utilizator, 
	Subunitate, Tip, Contract, Tert, Punct_livrare, Data, Stare, Loc_de_munca, Gestiune, Termen, 
	Scadenta, Discount, Valuta, Curs, Mod_plata, Mod_ambalare, Factura, Total_contractat, 
	Total_TVA, Contract_coresp, Mod_penalizare, Procent_penalizare, Procent_avans, Avans, 
	Nr_rate, Val_reziduala, Sold_initial, Cod_dobanda, Dobanda, Incasat, Responsabil, 
	Responsabil_tert, Explicatii, Data_rezilierii
   from deleted
