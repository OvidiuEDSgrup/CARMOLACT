CREATE TABLE [dbo].[syssavx] (
    [Host_id]              VARCHAR (10)  NULL,
    [Host_name]            VARCHAR (30)  NULL,
    [Aplicatia]            VARCHAR (30)  NULL,
    [Data_operarii]        DATETIME2 (3) NULL,
    [Utilizator]           VARCHAR (10)  NULL,
    [Tip_act]              VARCHAR (1)   NULL,
    [Marca]                VARCHAR (6)   NULL,
    [Data]                 DATETIME2 (3) NULL,
    [Ore_lucrate_la_avans] SMALLINT      NOT NULL,
    [Suma_avans]           FLOAT (53)    NOT NULL,
    [Premiu_la_avans]      FLOAT (53)    NOT NULL
) ON [SYSS];

