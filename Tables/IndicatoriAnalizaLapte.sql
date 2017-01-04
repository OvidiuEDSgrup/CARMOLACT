CREATE TABLE [dbo].[IndicatoriAnalizaLapte] (
    [Cod]              CHAR (3)   NOT NULL,
    [Denumire]         CHAR (30)  NOT NULL,
    [Valoare_standard] FLOAT (53) NOT NULL,
    [Ordine_achizitii] SMALLINT   NOT NULL,
    [Ordine_receptii]  SMALLINT   NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Unic]
    ON [dbo].[IndicatoriAnalizaLapte]([Cod] ASC);


GO
CREATE NONCLUSTERED INDEX [Ordine_achizitii]
    ON [dbo].[IndicatoriAnalizaLapte]([Ordine_achizitii] ASC);


GO
CREATE NONCLUSTERED INDEX [Ordine_receptii]
    ON [dbo].[IndicatoriAnalizaLapte]([Ordine_receptii] ASC);

