CREATE TABLE [dbo].[BordRecepLapte] (
    [Data]         DATETIME   NOT NULL,
    [Masina]       CHAR (13)  NOT NULL,
    [Tura]         SMALLINT   NOT NULL,
    [Nr_poz]       SMALLINT   NOT NULL,
    [Tip_lapte]    CHAR (20)  NOT NULL,
    [Compartiment] SMALLINT   NOT NULL,
    [Aviz]         CHAR (8)   NOT NULL,
    [Centru]       CHAR (9)   NOT NULL,
    [Cantitate]    FLOAT (53) NOT NULL,
    [Grasime]      REAL       NOT NULL,
    [Tip_doc]      CHAR (2)   NOT NULL,
    [Nr_doc]       CHAR (8)   NOT NULL,
    [Poz_doc]      INT        NOT NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Unic]
    ON [dbo].[BordRecepLapte]([Data] ASC, [Masina] ASC, [Tura] ASC, [Nr_poz] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Centru]
    ON [dbo].[BordRecepLapte]([Data] ASC, [Masina] ASC, [Tura] ASC, [Tip_lapte] ASC, [Compartiment] ASC, [Aviz] ASC, [Centru] ASC);


GO
CREATE NONCLUSTERED INDEX [Poz_doc]
    ON [dbo].[BordRecepLapte]([Data] ASC, [Tip_doc] ASC, [Nr_doc] ASC, [Poz_doc] ASC);

