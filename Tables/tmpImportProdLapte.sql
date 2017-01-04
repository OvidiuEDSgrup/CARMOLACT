CREATE TABLE [dbo].[tmpImportProdLapte] (
    [Terminal]         CHAR (8)   NOT NULL,
    [Cale_fisier]      CHAR (200) NOT NULL,
    [Nume_fisier]      CHAR (100) NOT NULL,
    [Nr_linie_fisier]  FLOAT (53) NOT NULL,
    [Denumire]         CHAR (50)  NOT NULL,
    [CNP_CUI]          CHAR (15)  NOT NULL,
    [Judet]            CHAR (30)  NOT NULL,
    [Cod_exploatatie]  CHAR (12)  NOT NULL,
    [Cota_actuala]     FLOAT (53) NOT NULL,
    [Grad_actual]      FLOAT (53) NOT NULL,
    [Centru_colectare] CHAR (9)   NOT NULL,
    [Data_operarii]    DATETIME   NOT NULL,
    [Ora_operarii]     CHAR (6)   NOT NULL,
    [Utilizator]       CHAR (10)  NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Unic]
    ON [dbo].[tmpImportProdLapte]([Terminal] ASC, [Cale_fisier] ASC, [Nume_fisier] ASC, [Nr_linie_fisier] ASC);


GO
CREATE NONCLUSTERED INDEX [Denumire]
    ON [dbo].[tmpImportProdLapte]([Denumire] ASC);

