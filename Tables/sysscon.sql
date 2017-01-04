﻿CREATE TABLE [dbo].[sysscon] (
    [Host_id]            VARCHAR (10)  NULL,
    [Host_name]          VARCHAR (30)  NULL,
    [Aplicatia]          VARCHAR (30)  NULL,
    [Data_stergerii]     DATETIME2 (7) NULL,
    [Stergator]          VARCHAR (10)  NULL,
    [Subunitate]         VARCHAR (9)   NULL,
    [Tip]                VARCHAR (2)   NULL,
    [Contract]           VARCHAR (20)  NULL,
    [Tert]               VARCHAR (13)  NULL,
    [Punct_livrare]      VARCHAR (13)  NULL,
    [Data]               DATETIME2 (3) NULL,
    [Stare]              VARCHAR (1)   NULL,
    [Loc_de_munca]       VARCHAR (9)   NULL,
    [Gestiune]           VARCHAR (9)   NULL,
    [Termen]             DATETIME2 (3) NULL,
    [Scadenta]           SMALLINT      NOT NULL,
    [Discount]           REAL          NOT NULL,
    [Valuta]             VARCHAR (3)   NULL,
    [Curs]               FLOAT (53)    NOT NULL,
    [Mod_plata]          VARCHAR (1)   NULL,
    [Mod_ambalare]       VARCHAR (1)   NULL,
    [Factura]            VARCHAR (20)  NULL,
    [Total_contractat]   FLOAT (53)    NOT NULL,
    [Total_TVA]          FLOAT (53)    NOT NULL,
    [Contract_coresp]    VARCHAR (20)  NULL,
    [Mod_penalizare]     VARCHAR (13)  NULL,
    [Procent_penalizare] REAL          NOT NULL,
    [Procent_avans]      REAL          NOT NULL,
    [Avans]              FLOAT (53)    NOT NULL,
    [Nr_rate]            SMALLINT      NOT NULL,
    [Val_reziduala]      FLOAT (53)    NOT NULL,
    [Sold_initial]       FLOAT (53)    NOT NULL,
    [Cod_dobanda]        VARCHAR (20)  NULL,
    [Dobanda]            REAL          NOT NULL,
    [Incasat]            FLOAT (53)    NOT NULL,
    [Responsabil]        VARCHAR (20)  NULL,
    [Responsabil_tert]   VARCHAR (20)  NULL,
    [Explicatii]         VARCHAR (50)  NULL,
    [Data_rezilierii]    DATETIME2 (3) NULL
) ON [SYSS];

