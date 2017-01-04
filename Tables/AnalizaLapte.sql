CREATE TABLE [dbo].[AnalizaLapte] (
    [Nr_inreg_inf_set] CHAR (8)   NOT NULL,
    [Nr_inreg_sup_set] CHAR (8)   NOT NULL,
    [Data]             DATETIME   NOT NULL,
    [Indicator]        CHAR (3)   NOT NULL,
    [Tip_analiza]      CHAR (1)   NOT NULL,
    [Centru_colectare] CHAR (9)   NOT NULL,
    [Producator]       CHAR (9)   NOT NULL,
    [Rezultat]         BIT        NOT NULL,
    [Valoare]          FLOAT (53) NOT NULL,
    [Data_operarii]    DATETIME   NOT NULL,
    [Ora_operarii]     CHAR (6)   NOT NULL,
    [Utilizator]       CHAR (10)  NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Unic]
    ON [dbo].[AnalizaLapte]([Nr_inreg_inf_set] ASC, [Nr_inreg_sup_set] ASC, [Data] ASC, [Tip_analiza] ASC, [Centru_colectare] ASC, [Producator] ASC);

