CREATE TABLE [dbo].[tmpFisImportProdLapte] (
    [Terminal]         CHAR (8)   NOT NULL,
    [Cale_fisier]      CHAR (200) NOT NULL,
    [Nume_fisier]      CHAR (100) NOT NULL,
    [Luna]             CHAR (20)  NOT NULL,
    [An_cota]          CHAR (10)  NOT NULL,
    [explicatii]       CHAR (100) NOT NULL,
    [Regiunea]         CHAR (30)  NOT NULL,
    [Centru_colectare] CHAR (9)   NOT NULL,
    [Judet]            CHAR (3)   NOT NULL,
    [Data_operarii]    DATETIME   NOT NULL,
    [Ora_operarii]     CHAR (6)   NOT NULL,
    [Utilizator]       CHAR (10)  NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Unic]
    ON [dbo].[tmpFisImportProdLapte]([Terminal] ASC, [Cale_fisier] ASC, [Nume_fisier] ASC);

