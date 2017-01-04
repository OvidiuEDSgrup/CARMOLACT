﻿CREATE TABLE [dbo].[sysspn] (
    [Host_id]        VARCHAR (10)  NULL,
    [Host_name]      VARCHAR (30)  NULL,
    [Aplicatia]      VARCHAR (30)  NULL,
    [Data_stergerii] DATETIME2 (7) NULL,
    [Stergator]      VARCHAR (10)  NULL,
    [Data_operarii]  DATETIME2 (3) NULL,
    [Ora_operarii]   VARCHAR (6)   NULL,
    [Subunitate]     VARCHAR (9)   NULL,
    [Tip]            VARCHAR (2)   NULL,
    [Numar]          VARCHAR (13)  NULL,
    [Data]           DATETIME2 (3) NULL,
    [Cont_debitor]   VARCHAR (20)  NULL,
    [Cont_creditor]  VARCHAR (20)  NULL,
    [Suma]           FLOAT (53)    NOT NULL,
    [Valuta]         VARCHAR (3)   NULL,
    [Curs]           FLOAT (53)    NOT NULL,
    [Suma_valuta]    FLOAT (53)    NOT NULL,
    [Explicatii]     VARCHAR (200) NULL,
    [Utilizator]     VARCHAR (10)  NULL,
    [Nr_pozitie]     INT           NOT NULL,
    [Loc_munca]      VARCHAR (9)   NULL,
    [Comanda]        VARCHAR (20)  NULL,
    [Tert]           VARCHAR (13)  NULL,
    [Jurnal]         VARCHAR (3)   NULL
) ON [SYSS];

