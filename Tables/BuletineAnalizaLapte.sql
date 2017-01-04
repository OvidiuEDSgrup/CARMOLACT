CREATE TABLE [dbo].[BuletineAnalizaLapte] (
    [Nr_inreg_inf_set]  CHAR (8)  NOT NULL,
    [Nr_inreg_sup_set]  CHAR (8)  NOT NULL,
    [Data]              DATETIME  NOT NULL,
    [Indicator]         CHAR (3)  NOT NULL,
    [Laborator_analize] CHAR (30) NOT NULL,
    [Sediu_laborator]   CHAR (30) NOT NULL,
    [Tip_colecta]       CHAR (1)  NOT NULL,
    [Data_colecta]      DATETIME  NOT NULL,
    [Data_operarii]     DATETIME  NOT NULL,
    [Ora_operarii]      CHAR (6)  NOT NULL,
    [Utilizator]        CHAR (10) NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Unic]
    ON [dbo].[BuletineAnalizaLapte]([Nr_inreg_inf_set] ASC, [Nr_inreg_sup_set] ASC, [Data] ASC);

