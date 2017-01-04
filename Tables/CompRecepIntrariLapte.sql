CREATE TABLE [dbo].[CompRecepIntrariLapte] (
    [Data]         DATETIME   NOT NULL,
    [Masina]       CHAR (13)  NOT NULL,
    [Tura]         SMALLINT   NOT NULL,
    [Tip_lapte]    CHAR (20)  NOT NULL,
    [Compartiment] SMALLINT   NOT NULL,
    [Cantitate]    FLOAT (53) NOT NULL,
    [Grasime]      REAL       NOT NULL,
    [Tip_doc]      CHAR (2)   NOT NULL,
    [Nr_doc]       CHAR (8)   NOT NULL,
    [Nr_poz]       SMALLINT   NOT NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Unic]
    ON [dbo].[CompRecepIntrariLapte]([Data] ASC, [Masina] ASC, [Tura] ASC, [Tip_lapte] ASC, [Compartiment] ASC);


GO
CREATE NONCLUSTERED INDEX [Ultim_poz_doc]
    ON [dbo].[CompRecepIntrariLapte]([Data] ASC, [Tip_doc] ASC, [Nr_doc] ASC, [Nr_poz] ASC);

