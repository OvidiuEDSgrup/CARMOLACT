﻿CREATE TABLE [dbo].[generareplati] (
    [Tip]              CHAR (1)    NOT NULL,
    [Element]          CHAR (1)    NOT NULL,
    [Data]             DATETIME    NOT NULL,
    [Tert]             CHAR (13)   NOT NULL,
    [Factura]          CHAR (20)   NOT NULL,
    [Numar_document]   CHAR (20)   NOT NULL,
    [Numar_ordin]      CHAR (20)   NOT NULL,
    [Suma_platita]     FLOAT (53)  NOT NULL,
    [Detalii_plata]    CHAR (200)  NOT NULL,
    [Cont_platitor]    CHAR (20)   NOT NULL,
    [IBAN_beneficiar]  CHAR (50)   NOT NULL,
    [Banca_beneficiar] CHAR (100)  NOT NULL,
    [Alfa1]            CHAR (200)  NOT NULL,
    [Alfa2]            CHAR (200)  NOT NULL,
    [Alfa3]            CHAR (200)  NOT NULL,
    [Val1]             FLOAT (53)  NOT NULL,
    [Val2]             FLOAT (53)  NOT NULL,
    [Val3]             FLOAT (53)  NOT NULL,
    [Data1]            DATETIME    NOT NULL,
    [Data2]            DATETIME    NOT NULL,
    [Data3]            DATETIME    NOT NULL,
    [Stare]            SMALLINT    NOT NULL,
    [Loc_de_munca]     VARCHAR (9) NOT NULL
);


GO
CREATE NONCLUSTERED INDEX [Generare plati]
    ON [dbo].[generareplati]([Tip] ASC, [Numar_document] ASC, [Data] ASC);


GO
CREATE NONCLUSTERED INDEX [Factura]
    ON [dbo].[generareplati]([Tip] ASC, [Element] ASC, [Tert] ASC, [Factura] ASC, [Stare] ASC);

