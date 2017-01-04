CREATE TABLE [dbo].[CentrColectLapte] (
    [Cod_centru_colectare] CHAR (9)  NOT NULL,
    [Denumire]             CHAR (30) NOT NULL,
    [Cod_IBAN]             CHAR (25) NOT NULL,
    [Banca]                CHAR (20) NOT NULL,
    [Sat]                  CHAR (30) NOT NULL,
    [Comuna]               CHAR (30) NOT NULL,
    [Localitate]           CHAR (30) NOT NULL,
    [Judet]                CHAR (30) NOT NULL,
    [Responsabil]          CHAR (30) NOT NULL,
    [Loc_de_munca]         CHAR (9)  NOT NULL,
    [Tip_pers]             CHAR (1)  NOT NULL,
    [Tert]                 CHAR (13) NOT NULL,
    [Ruta]                 CHAR (5)  NOT NULL,
    [Ord_ruta]             SMALLINT  NOT NULL,
    [Data_operarii]        DATETIME  NOT NULL,
    [Ora_operarii]         CHAR (6)  NOT NULL,
    [Utilizator]           CHAR (10) NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Unic]
    ON [dbo].[CentrColectLapte]([Cod_centru_colectare] ASC);


GO
CREATE NONCLUSTERED INDEX [Loc_munca]
    ON [dbo].[CentrColectLapte]([Loc_de_munca] ASC, [Cod_centru_colectare] ASC);


GO
CREATE NONCLUSTERED INDEX [Denumire]
    ON [dbo].[CentrColectLapte]([Denumire] ASC);


GO
CREATE NONCLUSTERED INDEX [Ordine_ruta]
    ON [dbo].[CentrColectLapte]([Ruta] ASC, [Ord_ruta] ASC, [Cod_centru_colectare] ASC);

