﻿CREATE TABLE [dbo].[docsters] (
    [Subunitate]            CHAR (9)      NOT NULL,
    [Tip]                   CHAR (2)      NOT NULL,
    [Numar]                 CHAR (8)      NOT NULL,
    [Data]                  DATETIME      NOT NULL,
    [Tert]                  CHAR (13)     NOT NULL,
    [Factura]               CHAR (20)     NOT NULL,
    [Gestiune]              CHAR (9)      NOT NULL,
    [Cod]                   CHAR (20)     NOT NULL,
    [Cod_intrare]           CHAR (13)     NOT NULL,
    [Gestiune_primitoare]   CHAR (9)      NOT NULL,
    [Cont]                  CHAR (13)     NOT NULL,
    [Cont_cor]              CHAR (13)     NOT NULL,
    [Cantitate]             FLOAT (53)    NOT NULL,
    [Pret]                  FLOAT (53)    NOT NULL,
    [Pret_vanzare]          FLOAT (53)    NOT NULL,
    [Jurnal]                CHAR (3)      NOT NULL,
    [Utilizator]            CHAR (10)     NOT NULL,
    [Data_operarii]         DATETIME      NOT NULL,
    [Ora_operarii]          CHAR (6)      NOT NULL,
    [Data_stergerii]        DATETIME      NOT NULL,
    [Pret_valuta]           FLOAT (53)    NULL,
    [Adaos]                 REAL          NULL,
    [Pret_cu_amanuntul]     FLOAT (53)    NULL,
    [TVA_deductibil]        FLOAT (53)    NULL,
    [Cota_TVA]              REAL          NULL,
    [TVA_neexigibil]        REAL          NULL,
    [Pret_amanunt_predator] FLOAT (53)    NULL,
    [Tip_miscare]           VARCHAR (1)   NULL,
    [Locatie]               VARCHAR (30)  NULL,
    [Data_expirarii]        DATETIME      NULL,
    [Numar_pozitie]         INT           NULL,
    [Loc_de_munca]          VARCHAR (9)   NULL,
    [Comanda]               VARCHAR (40)  NULL,
    [Barcod]                VARCHAR (30)  NULL,
    [Cont_intermediar]      VARCHAR (20)  NULL,
    [Cont_venituri]         VARCHAR (20)  NULL,
    [Discount]              REAL          NULL,
    [Numar_DVI]             VARCHAR (25)  NULL,
    [Stare]                 SMALLINT      NULL,
    [Grupa]                 VARCHAR (13)  NULL,
    [Cont_factura]          VARCHAR (20)  NULL,
    [Valuta]                VARCHAR (3)   NULL,
    [Curs]                  FLOAT (53)    NULL,
    [Data_facturii]         DATETIME      NULL,
    [Data_scadentei]        DATETIME      NULL,
    [Procent_vama]          REAL          NULL,
    [Suprataxe_vama]        FLOAT (53)    NULL,
    [Accize_cumparare]      FLOAT (53)    NULL,
    [Accize_datorate]       FLOAT (53)    NULL,
    [Contract]              VARCHAR (20)  NULL,
    [detalii]               XML           NULL,
    [idPozDoc]              INT           NULL,
    [subtip]                VARCHAR (2)   NULL,
    [idIntrareFirma]        INT           NULL,
    [idIntrare]             INT           NULL,
    [idIntrareTI]           INT           NULL,
    [lot]                   VARCHAR (20)  NULL,
    [colet]                 VARCHAR (500) NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Sterse]
    ON [dbo].[docsters]([Subunitate] ASC, [Tip] ASC, [Numar] ASC, [Data] ASC, [Data_stergerii] ASC, [Cod] ASC, [Cod_intrare] ASC);


GO
CREATE NONCLUSTERED INDEX [Data_stergerii]
    ON [dbo].[docsters]([Data_stergerii] ASC);

