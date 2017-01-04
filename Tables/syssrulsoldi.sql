CREATE TABLE [dbo].[syssrulsoldi] (
    [Host_id]       VARCHAR (10)  NULL,
    [Host_name]     VARCHAR (30)  NULL,
    [Aplicatia]     VARCHAR (30)  NULL,
    [Data_operarii] DATETIME2 (3) NULL,
    [Utilizator]    VARCHAR (10)  NULL,
    [Tip_act]       VARCHAR (1)   NULL,
    [Subunitate]    VARCHAR (9)   NULL,
    [Cont]          VARCHAR (20)  NULL,
    [Valuta]        VARCHAR (3)   NULL,
    [Data]          DATETIME2 (3) NULL,
    [Rulaj_debit]   FLOAT (53)    NOT NULL,
    [Rulaj_credit]  FLOAT (53)    NOT NULL
) ON [SYSS];

