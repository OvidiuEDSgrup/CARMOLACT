CREATE TABLE [dbo].[BordAnalizaRecepLapte] (
    [Data]         DATETIME   NOT NULL,
    [Masina]       CHAR (13)  NOT NULL,
    [Tura]         SMALLINT   NOT NULL,
    [Tip_lapte]    CHAR (20)  NOT NULL,
    [Compartiment] SMALLINT   NOT NULL,
    [Aviz]         CHAR (8)   NOT NULL,
    [Centru]       CHAR (9)   NOT NULL,
    [Indicator]    CHAR (3)   NOT NULL,
    [Rezultat]     FLOAT (53) NOT NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Unic]
    ON [dbo].[BordAnalizaRecepLapte]([Data] ASC, [Masina] ASC, [Tura] ASC, [Tip_lapte] ASC, [Compartiment] ASC, [Aviz] ASC, [Centru] ASC, [Indicator] ASC);

