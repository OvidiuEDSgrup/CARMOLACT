CREATE TABLE [dbo].[CentrColectProdLapte] (
    [Centru_colectare] CHAR (9)  NOT NULL,
    [Tip_lapte]        CHAR (20) NOT NULL,
    [Producator]       CHAR (9)  NOT NULL,
    [Nr_ordine]        INT       NOT NULL,
    [Nr_fisa]          CHAR (5)  NOT NULL,
    [Data_inscrierii]  DATETIME  NOT NULL,
    [Data_operarii]    DATETIME  NOT NULL,
    [Ora_operarii]     CHAR (6)  NOT NULL,
    [Utilizator]       CHAR (10) NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Unic]
    ON [dbo].[CentrColectProdLapte]([Centru_colectare] ASC, [Tip_lapte] ASC, [Producator] ASC);


GO
CREATE NONCLUSTERED INDEX [Nr_ordine]
    ON [dbo].[CentrColectProdLapte]([Centru_colectare] ASC, [Tip_lapte] ASC, [Nr_ordine] ASC);


GO
CREATE NONCLUSTERED INDEX [missing_index_118]
    ON [dbo].[CentrColectProdLapte]([Producator] ASC)
    INCLUDE([Centru_colectare], [Tip_lapte]);

