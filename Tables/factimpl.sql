﻿CREATE TABLE [dbo].[factimpl] (
    [Subunitate]            CHAR (9)      NOT NULL,
    [Loc_de_munca]          CHAR (9)      NOT NULL,
    [Tip]                   BINARY (1)    NOT NULL,
    [Factura]               CHAR (20)     NOT NULL,
    [Tert]                  CHAR (13)     NOT NULL,
    [Data]                  DATETIME      NOT NULL,
    [Data_scadentei]        DATETIME      NOT NULL,
    [Valoare]               FLOAT (53)    NOT NULL,
    [TVA_11]                FLOAT (53)    NOT NULL,
    [TVA_22]                FLOAT (53)    NOT NULL,
    [Valuta]                CHAR (3)      NOT NULL,
    [Curs]                  FLOAT (53)    NOT NULL,
    [Valoare_valuta]        FLOAT (53)    NOT NULL,
    [Achitat]               FLOAT (53)    NOT NULL,
    [Sold]                  FLOAT (53)    NOT NULL,
    [Cont_de_tert]          VARCHAR (20)  NULL,
    [Achitat_valuta]        FLOAT (53)    NOT NULL,
    [Sold_valuta]           FLOAT (53)    NOT NULL,
    [Comanda]               CHAR (20)     NOT NULL,
    [Data_ultimei_achitari] DATETIME      NOT NULL,
    [punct_livrare]         VARCHAR (20)  NULL,
    [explicatii]            VARCHAR (200) NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Unic]
    ON [dbo].[factimpl]([Subunitate] ASC, [Tip] ASC, [Factura] ASC, [Tert] ASC);


GO
CREATE NONCLUSTERED INDEX [Sub_Tip_Tert]
    ON [dbo].[factimpl]([Subunitate] ASC, [Tert] ASC, [Tip] ASC);


GO
CREATE NONCLUSTERED INDEX [Jurnale_TVA]
    ON [dbo].[factimpl]([Subunitate] ASC, [Tip] ASC, [Data] ASC);

