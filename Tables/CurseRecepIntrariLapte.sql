CREATE TABLE [dbo].[CurseRecepIntrariLapte] (
    [Nr_cursa] INT        NOT NULL,
    [Data]     DATETIME   NOT NULL,
    [Masina]   CHAR (13)  NOT NULL,
    [Tura]     SMALLINT   NOT NULL,
    [Sofer]    CHAR (6)   NOT NULL,
    [Ruta]     CHAR (5)   NOT NULL,
    [Tip_doc]  CHAR (2)   NOT NULL,
    [Nr_doc]   CHAR (8)   NOT NULL,
    [Valuta]   CHAR (3)   NOT NULL,
    [Curs]     FLOAT (53) NOT NULL,
    [Tip_TVA]  REAL       NOT NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Unic]
    ON [dbo].[CurseRecepIntrariLapte]([Data] ASC, [Masina] ASC, [Tura] ASC);


GO
CREATE NONCLUSTERED INDEX [Nr_cursa]
    ON [dbo].[CurseRecepIntrariLapte]([Nr_cursa] ASC);

