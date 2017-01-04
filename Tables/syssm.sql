CREATE TABLE [dbo].[syssm] (
    [Host_id]                   VARCHAR (10)  NULL,
    [Host_name]                 VARCHAR (30)  NULL,
    [Aplicatia]                 VARCHAR (30)  NULL,
    [Data_stergerii]            DATETIME2 (7) NULL,
    [Stergator]                 VARCHAR (10)  NULL,
    [Subunitate]                VARCHAR (9)   NULL,
    [Numar_de_inventar]         VARCHAR (13)  NULL,
    [Denumire]                  VARCHAR (80)  NULL,
    [Serie]                     VARCHAR (20)  NULL,
    [Tip_amortizare]            VARCHAR (1)   NULL,
    [Cod_de_clasificare]        VARCHAR (20)  NULL,
    [Data_punerii_in_functiune] DATETIME2 (3) NULL
) ON [SYSS];

