CREATE TABLE [dbo].[docmodcotalapte110419] (
    [Tip_doc]         CHAR (1)   NOT NULL,
    [Data]            DATETIME   NOT NULL,
    [Producator]      CHAR (9)   NOT NULL,
    [Durata]          CHAR (1)   NOT NULL,
    [Cota]            FLOAT (53) NOT NULL,
    [Grad]            FLOAT (53) NOT NULL,
    [Nr_adeverinta]   CHAR (8)   NOT NULL,
    [Data_adeverinta] DATETIME   NOT NULL,
    [Confirmat]       BIT        NOT NULL,
    [Explicatii]      CHAR (150) NOT NULL,
    [Data_operarii]   DATETIME   NOT NULL,
    [Ora_operarii]    CHAR (6)   NOT NULL,
    [Utilizator]      CHAR (10)  NOT NULL
);

