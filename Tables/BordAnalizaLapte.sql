CREATE TABLE [dbo].[BordAnalizaLapte] (
    [Data_lunii]       DATETIME   NOT NULL,
    [Tip]              CHAR (1)   NOT NULL,
    [Producator]       CHAR (9)   NOT NULL,
    [Centru_colectare] CHAR (9)   NOT NULL,
    [Tip_lapte]        CHAR (20)  NOT NULL,
    [Indicator]        CHAR (3)   NOT NULL,
    [Ziua]             SMALLINT   NOT NULL,
    [Valoare]          FLOAT (53) NOT NULL,
    [Data_operarii]    DATETIME   NOT NULL,
    [Ora_operarii]     CHAR (6)   NOT NULL,
    [Utilizator]       CHAR (10)  NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Unic]
    ON [dbo].[BordAnalizaLapte]([Data_lunii] ASC, [Tip] ASC, [Producator] ASC, [Centru_colectare] ASC, [Tip_lapte] ASC, [Indicator] ASC, [Ziua] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Data]
    ON [dbo].[BordAnalizaLapte]([Data_lunii] DESC, [Producator] ASC, [Centru_colectare] ASC, [Tip] ASC, [Tip_lapte] ASC, [Indicator] ASC, [Ziua] ASC);

