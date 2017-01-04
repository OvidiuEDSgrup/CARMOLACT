CREATE TABLE [dbo].[sysscoefm] (
    [Host_id]       VARCHAR (10)  NULL,
    [Host_name]     VARCHAR (30)  NULL,
    [Aplicatia]     VARCHAR (30)  NULL,
    [Data_operarii] DATETIME2 (3) NULL,
    [Utilizator]    VARCHAR (10)  NULL,
    [Tip_act]       VARCHAR (1)   NULL,
    [Masina]        VARCHAR (20)  NULL,
    [Coeficient]    VARCHAR (20)  NULL,
    [Valoare]       FLOAT (53)    NOT NULL,
    [Interval]      FLOAT (53)    NOT NULL
) ON [SYSS];

