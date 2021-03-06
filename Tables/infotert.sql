﻿CREATE TABLE [dbo].[infotert] (
    [Subunitate]     CHAR (9)       NOT NULL,
    [Tert]           CHAR (13)      NOT NULL,
    [Identificator]  CHAR (5)       NOT NULL,
    [Descriere]      CHAR (30)      NOT NULL,
    [Loc_munca]      CHAR (9)       NOT NULL,
    [Pers_contact]   CHAR (20)      NOT NULL,
    [Nume_delegat]   CHAR (30)      NOT NULL,
    [Buletin]        CHAR (12)      NOT NULL,
    [Eliberat]       CHAR (30)      NOT NULL,
    [Mijloc_tp]      CHAR (20)      NOT NULL,
    [Adresa2]        CHAR (20)      NOT NULL,
    [Telefon_fax2]   CHAR (20)      NOT NULL,
    [e_mail]         VARCHAR (2000) NULL,
    [Banca2]         CHAR (20)      NOT NULL,
    [Cont_in_banca2] CHAR (35)      NOT NULL,
    [Banca3]         CHAR (20)      NOT NULL,
    [Cont_in_banca3] CHAR (35)      NOT NULL,
    [Indicator]      BIT            NOT NULL,
    [Grupa13]        CHAR (13)      NOT NULL,
    [Sold_ben]       FLOAT (53)     NOT NULL,
    [Discount]       REAL           NOT NULL,
    [Zile_inc]       SMALLINT       NOT NULL,
    [Observatii]     CHAR (30)      NOT NULL,
    [codRuta]        VARCHAR (20)   NULL,
    [detalii]        XML            NULL,
    CONSTRAINT [fk_Rute] FOREIGN KEY ([codRuta]) REFERENCES [dbo].[rute] ([codRuta])
);


GO
CREATE UNIQUE CLUSTERED INDEX [Identific]
    ON [dbo].[infotert]([Subunitate] ASC, [Tert] ASC, [Identificator] ASC);


GO
CREATE NONCLUSTERED INDEX [Descriere]
    ON [dbo].[infotert]([Descriere] ASC);


GO
CREATE NONCLUSTERED INDEX [missing_index_254]
    ON [dbo].[infotert]([Tert] ASC, [Identificator] ASC, [Indicator] ASC)
    INCLUDE([Subunitate]);


GO
CREATE NONCLUSTERED INDEX [missing_index_256]
    ON [dbo].[infotert]([Identificator] ASC, [Indicator] ASC);


GO
CREATE NONCLUSTERED INDEX [missing_index_381]
    ON [dbo].[infotert]([Tert] ASC, [Identificator] ASC);


GO
CREATE NONCLUSTERED INDEX [missing_index_384]
    ON [dbo].[infotert]([Tert] ASC);


GO
CREATE NONCLUSTERED INDEX [missing_index_258]
    ON [dbo].[infotert]([Subunitate] ASC, [Identificator] ASC);


GO
CREATE NONCLUSTERED INDEX [missing_index_337]
    ON [dbo].[infotert]([Identificator] ASC);


GO
CREATE NONCLUSTERED INDEX [missing_index_1752]
    ON [dbo].[infotert]([Identificator] ASC)
    INCLUDE([Descriere]);


GO
CREATE NONCLUSTERED INDEX [missing_index_1754]
    ON [dbo].[infotert]([Identificator] ASC, [Descriere] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Descriere_unica]
    ON [dbo].[infotert]([Subunitate] ASC, [Tert] ASC, [Descriere] ASC);

