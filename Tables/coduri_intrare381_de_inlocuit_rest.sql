CREATE TABLE [dbo].[coduri_intrare381_de_inlocuit_rest] (
    [Cod_gestiune]           CHAR (20)    NOT NULL,
    [Cod]                    CHAR (20)    NOT NULL,
    [data]                   CHAR (10)    NULL,
    [Pret]                   FLOAT (53)   NOT NULL,
    [Cod_intrare]            CHAR (13)    NOT NULL,
    [Cod_intrare_inlocuire]  VARCHAR (13) NULL,
    [Pret_de_stoc_inlocuire] FLOAT (53)   NOT NULL
);

