﻿CREATE TABLE [dbo].[antetBonuri] (
    [Casa_de_marcat]      SMALLINT       NOT NULL,
    [Chitanta]            BIT            NOT NULL,
    [Numar_bon]           INT            NOT NULL,
    [Data_bon]            DATETIME       NOT NULL,
    [Vinzator]            VARCHAR (10)   NOT NULL,
    [Factura]             VARCHAR (20)   NULL,
    [Data_facturii]       DATETIME       NULL,
    [Data_scadentei]      DATETIME       NULL,
    [Tert]                VARCHAR (50)   NULL,
    [Gestiune]            VARCHAR (50)   NULL,
    [Loc_de_munca]        VARCHAR (50)   NULL,
    [Persoana_de_contact] VARCHAR (50)   NULL,
    [Punct_de_livrare]    VARCHAR (50)   NULL,
    [Categorie_de_pret]   SMALLINT       NULL,
    [Contract]            VARCHAR (8)    NULL,
    [Comanda]             VARCHAR (13)   NULL,
    [Observatii]          VARCHAR (2000) NULL,
    [Explicatii]          VARCHAR (500)  NULL,
    [UID]                 VARCHAR (36)   NULL,
    [Bon]                 XML            NULL,
    [IdAntetBon]          INT            IDENTITY (1, 1) NOT NULL,
    [UID_Card_Fidelizare] AS             ([dbo].[f_antetBonuri_UidCardFidelizareDinXml]([bon])) PERSISTED
);


GO
CREATE UNIQUE CLUSTERED INDEX [Numar_bon_Tip]
    ON [dbo].[antetBonuri]([Data_bon] ASC, [Casa_de_marcat] ASC, [Vinzator] ASC, [Numar_bon] ASC);


GO
CREATE NONCLUSTERED INDEX [Tert]
    ON [dbo].[antetBonuri]([Tert] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_idAntetBon]
    ON [dbo].[antetBonuri]([IdAntetBon] ASC)
    INCLUDE([Data_bon], [Casa_de_marcat], [Vinzator], [Numar_bon]);


GO
CREATE NONCLUSTERED INDEX [IX_dupaFactura]
    ON [dbo].[antetBonuri]([Factura] ASC, [Data_facturii] ASC)
    INCLUDE([IdAntetBon], [Chitanta], [Tert], [Casa_de_marcat], [Data_bon], [Numar_bon]);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Uid]
    ON [dbo].[antetBonuri]([UID] ASC)
    INCLUDE([Casa_de_marcat], [Data_bon], [Numar_bon]);

