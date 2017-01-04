CREATE TABLE [dbo].[dateCentrColectLapte] (
    [Centru_colectare] CHAR (9)   NOT NULL,
    [Data_lunii]       DATETIME   NOT NULL,
    [Produs]           CHAR (20)  NOT NULL,
    [Pret]             FLOAT (53) NOT NULL,
    [Cantitate]        FLOAT (53) NOT NULL,
    [Procent]          REAL       NOT NULL,
    [UM]               CHAR (3)   NOT NULL,
    [Data_operarii]    DATETIME   NOT NULL,
    [Ora_operarii]     CHAR (6)   NOT NULL,
    [Utilizator]       CHAR (10)  NOT NULL
);

