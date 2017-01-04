CREATE TABLE [dbo].[syssl] (
    [Host_id]        VARCHAR (10)  NULL,
    [Host_name]      VARCHAR (30)  NULL,
    [Aplicatia]      VARCHAR (30)  NULL,
    [Data_stergerii] DATETIME2 (7) NULL,
    [Stergator]      VARCHAR (10)  NULL,
    [Nivel]          SMALLINT      NOT NULL,
    [Cod]            VARCHAR (9)   NULL,
    [Cod_parinte]    VARCHAR (9)   NULL,
    [Denumire]       VARCHAR (30)  NULL
) ON [SYSS];

