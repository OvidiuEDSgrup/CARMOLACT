CREATE TABLE [dbo].[syssca] (
    [Host_id]       VARCHAR (10)  NULL,
    [Host_name]     VARCHAR (30)  NULL,
    [Aplicatia]     VARCHAR (30)  NULL,
    [Data_operarii] DATETIME2 (3) NULL,
    [Utilizator]    VARCHAR (10)  NULL,
    [Tip_act]       VARCHAR (1)   NULL,
    [Data]          DATETIME2 (3) NULL,
    [Marca]         VARCHAR (6)   NULL,
    [Tip_concediu]  VARCHAR (1)   NULL,
    [Data_inceput]  DATETIME2 (3) NULL,
    [Data_sfarsit]  DATETIME2 (3) NULL,
    [Zile]          SMALLINT      NOT NULL,
    [Introd_manual] BIT           NOT NULL,
    [Indemnizatie]  FLOAT (53)    NOT NULL
) ON [SYSS];

