﻿CREATE TABLE [dbo].[sysspd] (
    [Host_id]               VARCHAR (10)  NULL,
    [Host_name]             VARCHAR (30)  NULL,
    [Aplicatia]             VARCHAR (30)  NULL,
    [Data_stergerii]        DATETIME2 (7) NULL,
    [Stergator]             VARCHAR (10)  NULL,
    [Data_operarii]         DATETIME2 (3) NULL,
    [Ora_operarii]          VARCHAR (6)   NULL,
    [Subunitate]            VARCHAR (9)   NULL,
    [Tip]                   VARCHAR (2)   NULL,
    [Numar]                 VARCHAR (8)   NULL,
    [Cod]                   VARCHAR (20)  NULL,
    [Data]                  DATETIME2 (3) NULL,
    [Gestiune]              VARCHAR (9)   NULL,
    [Cantitate]             FLOAT (53)    NOT NULL,
    [Pret_valuta]           FLOAT (53)    NOT NULL,
    [Pret_de_stoc]          FLOAT (53)    NOT NULL,
    [Adaos]                 REAL          NOT NULL,
    [Pret_vanzare]          FLOAT (53)    NOT NULL,
    [Pret_cu_amanuntul]     FLOAT (53)    NOT NULL,
    [TVA_deductibil]        FLOAT (53)    NOT NULL,
    [Cota_TVA]              SMALLINT      NOT NULL,
    [Utilizator]            VARCHAR (10)  NULL,
    [Cod_intrare]           VARCHAR (13)  NULL,
    [Cont_de_stoc]          VARCHAR (20)  NULL,
    [Cont_corespondent]     VARCHAR (20)  NULL,
    [TVA_neexigibil]        SMALLINT      NOT NULL,
    [Pret_amanunt_predator] FLOAT (53)    NOT NULL,
    [Tip_miscare]           VARCHAR (1)   NULL,
    [Locatie]               VARCHAR (30)  NULL,
    [Data_expirarii]        DATETIME2 (3) NULL,
    [Numar_pozitie]         INT           NOT NULL,
    [Loc_de_munca]          VARCHAR (9)   NULL,
    [Comanda]               VARCHAR (20)  NULL,
    [Barcod]                VARCHAR (30)  NULL,
    [Cont_intermediar]      VARCHAR (20)  NULL,
    [Cont_venituri]         VARCHAR (20)  NULL,
    [Discount]              REAL          NOT NULL,
    [Tert]                  VARCHAR (13)  NULL,
    [Factura]               VARCHAR (20)  NULL,
    [Gestiune_primitoare]   VARCHAR (20)  NULL,
    [Numar_DVI]             VARCHAR (25)  NULL,
    [Stare]                 SMALLINT      NOT NULL,
    [Grupa]                 VARCHAR (13)  NULL,
    [Cont_factura]          VARCHAR (20)  NULL,
    [Valuta]                VARCHAR (3)   NULL,
    [Curs]                  FLOAT (53)    NOT NULL,
    [Data_facturii]         DATETIME2 (3) NULL,
    [Data_scadentei]        DATETIME2 (3) NULL,
    [Procent_vama]          REAL          NOT NULL,
    [Suprataxe_vama]        FLOAT (53)    NOT NULL,
    [Accize_cumparare]      FLOAT (53)    NOT NULL,
    [Accize_datorate]       FLOAT (53)    NOT NULL,
    [Contract]              VARCHAR (20)  NULL,
    [Jurnal]                VARCHAR (3)   NULL
) ON [SYSS];

