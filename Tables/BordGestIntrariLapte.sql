CREATE TABLE [dbo].[BordGestIntrariLapte] (
    [Data]         DATETIME   NOT NULL,
    [Masina]       CHAR (13)  NOT NULL,
    [Tura]         SMALLINT   NOT NULL,
    [Tip_lapte]    CHAR (20)  NOT NULL,
    [Compartiment] SMALLINT   NOT NULL,
    [Gestiune]     CHAR (9)   NOT NULL,
    [Cantitate]    FLOAT (53) NOT NULL,
    [Tip_doc]      CHAR (2)   NOT NULL,
    [Nr_doc]       CHAR (8)   NOT NULL,
    [Poz_doc]      INT        NOT NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Unic]
    ON [dbo].[BordGestIntrariLapte]([Data] ASC, [Masina] ASC, [Tura] ASC, [Tip_lapte] ASC, [Compartiment] ASC, [Gestiune] ASC);


GO
CREATE NONCLUSTERED INDEX [Poz_doc]
    ON [dbo].[BordGestIntrariLapte]([Poz_doc] ASC, [Nr_doc] ASC, [Tip_doc] ASC, [Data] ASC);

