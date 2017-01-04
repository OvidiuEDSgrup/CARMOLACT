CREATE TABLE [dbo].[TotBordAchizRecepLapte] (
    [Data_lunii]          DATETIME   NOT NULL,
    [Centru_colectare]    CHAR (9)   NOT NULL,
    [Tip_lapte]           CHAR (20)  NOT NULL,
    [Cant_UM_achizitii]   FLOAT (53) NOT NULL,
    [Cant_UM_receptii]    FLOAT (53) NOT NULL,
    [Dif_cant_UM]         FLOAT (53) NOT NULL,
    [Cant_UG_achizitii]   FLOAT (53) NOT NULL,
    [Cant_UG_receptii]    FLOAT (53) NOT NULL,
    [Dif_cant_UG]         FLOAT (53) NOT NULL,
    [Gras_STAS]           REAL       NOT NULL,
    [Cant_STAS_achizitii] FLOAT (53) NOT NULL,
    [Cant_STAS_receptii]  FLOAT (53) NOT NULL,
    [Dif_cant_STAS]       FLOAT (53) NOT NULL,
    [Valoare_achizitii]   FLOAT (53) NOT NULL,
    [Valoare_receptii]    FLOAT (53) NOT NULL,
    [Dif_valoare]         FLOAT (53) NOT NULL,
    [Data_operarii]       DATETIME   NOT NULL,
    [Ora_operarii]        CHAR (6)   NOT NULL,
    [Utilizator]          CHAR (10)  NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Unic]
    ON [dbo].[TotBordAchizRecepLapte]([Data_lunii] ASC, [Centru_colectare] ASC, [Tip_lapte] ASC);

