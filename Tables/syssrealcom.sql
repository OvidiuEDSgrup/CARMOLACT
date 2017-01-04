CREATE TABLE [dbo].[syssrealcom] (
    [Host_id]              VARCHAR (10)  NULL,
    [Host_name]            VARCHAR (30)  NULL,
    [Aplicatia]            VARCHAR (30)  NULL,
    [Data_operarii]        DATETIME2 (3) NULL,
    [Utilizator]           VARCHAR (10)  NULL,
    [Tip_act]              VARCHAR (1)   NULL,
    [Marca]                VARCHAR (6)   NULL,
    [Loc_de_munca]         VARCHAR (9)   NULL,
    [Numar_document]       VARCHAR (20)  NULL,
    [Data]                 DATETIME2 (3) NULL,
    [Comanda]              VARCHAR (13)  NULL,
    [Cod_reper]            VARCHAR (20)  NULL,
    [Cod]                  VARCHAR (20)  NULL,
    [Cantitate]            FLOAT (53)    NOT NULL,
    [Categoria_salarizare] VARCHAR (4)   NULL,
    [Norma_de_timp]        FLOAT (53)    NOT NULL,
    [Tarif_unitar]         FLOAT (53)    NOT NULL
) ON [SYSS];

