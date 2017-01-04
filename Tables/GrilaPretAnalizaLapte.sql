CREATE TABLE [dbo].[GrilaPretAnalizaLapte] (
    [Tip]       CHAR (1)   NOT NULL,
    [Tip_lapte] CHAR (20)  NOT NULL,
    [Indicator] CHAR (3)   NOT NULL,
    [Valoare]   FLOAT (53) NOT NULL,
    [Corectie]  REAL       NOT NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Unic]
    ON [dbo].[GrilaPretAnalizaLapte]([Tip] ASC, [Tip_lapte] ASC, [Indicator] ASC, [Valoare] ASC);

