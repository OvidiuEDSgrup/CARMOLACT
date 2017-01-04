CREATE TABLE [dbo].[sysscor] (
    [Host_id]            VARCHAR (10)  NULL,
    [Host_name]          VARCHAR (30)  NULL,
    [Aplicatia]          VARCHAR (30)  NULL,
    [Data_operarii]      DATETIME2 (3) NULL,
    [Utilizator]         VARCHAR (10)  NULL,
    [Tip_act]            VARCHAR (1)   NULL,
    [Data]               DATETIME2 (3) NULL,
    [Marca]              VARCHAR (6)   NULL,
    [Loc_de_munca]       VARCHAR (9)   NULL,
    [Tip_corectie_venit] VARCHAR (2)   NULL,
    [Suma_corectie]      FLOAT (53)    NOT NULL,
    [Procent_corectie]   REAL          NOT NULL,
    [Suma_neta]          FLOAT (53)    NOT NULL
) ON [SYSS];

