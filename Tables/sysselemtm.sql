CREATE TABLE [dbo].[sysselemtm] (
    [Host_id]       VARCHAR (10)   NULL,
    [Host_name]     VARCHAR (30)   NULL,
    [Aplicatia]     VARCHAR (30)   NULL,
    [Data_operarii] DATETIME2 (3)  NULL,
    [Utilizator]    VARCHAR (10)   NULL,
    [Tip_act]       VARCHAR (1)    NULL,
    [Tip_masina]    VARCHAR (20)   NULL,
    [Element]       VARCHAR (20)   NULL,
    [Mod_calcul]    VARCHAR (1)    NULL,
    [Formula]       VARCHAR (2000) NULL,
    [Valoare]       FLOAT (53)     NOT NULL,
    [Ord_macheta]   SMALLINT       NOT NULL,
    [Ord_raport]    SMALLINT       NOT NULL,
    [Cu_totaluri]   BIT            NOT NULL,
    [Grupa]         VARCHAR (20)   NULL
) ON [SYSS];

