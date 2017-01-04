CREATE TABLE [dbo].[sysstipmas] (
    [Host_id]        VARCHAR (10)  NULL,
    [Host_name]      VARCHAR (30)  NULL,
    [Aplicatia]      VARCHAR (30)  NULL,
    [Data_operarii]  DATETIME2 (3) NULL,
    [Utilizator]     VARCHAR (10)  NULL,
    [Tip_act]        VARCHAR (1)   NULL,
    [Cod]            VARCHAR (20)  NULL,
    [Denumire]       VARCHAR (60)  NULL,
    [tip_activitate] VARCHAR (1)   NULL
) ON [SYSS];

