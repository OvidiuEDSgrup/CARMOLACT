CREATE TABLE [dbo].[BordAnalizaIntrariLapte] (
    [Data]         DATETIME   NOT NULL,
    [Masina]       CHAR (13)  NOT NULL,
    [Tura]         SMALLINT   NOT NULL,
    [Tip_lapte]    CHAR (20)  NOT NULL,
    [Compartiment] SMALLINT   NOT NULL,
    [Indicator]    CHAR (3)   NOT NULL,
    [Valoare]      FLOAT (53) NOT NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Unic]
    ON [dbo].[BordAnalizaIntrariLapte]([Data] ASC, [Masina] ASC, [Tura] ASC, [Tip_lapte] ASC, [Compartiment] ASC, [Indicator] ASC);

