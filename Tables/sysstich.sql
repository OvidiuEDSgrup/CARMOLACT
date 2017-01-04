CREATE TABLE [dbo].[sysstich] (
    [Host_id]          VARCHAR (10)  NULL,
    [Host_name]        VARCHAR (30)  NULL,
    [Aplicatia]        VARCHAR (30)  NULL,
    [Data_operarii]    DATETIME2 (3) NULL,
    [Utilizator]       VARCHAR (10)  NULL,
    [Tip_act]          VARCHAR (1)   NULL,
    [Marca]            VARCHAR (6)   NULL,
    [Data_lunii]       DATETIME2 (3) NULL,
    [Tip_operatie]     VARCHAR (1)   NULL,
    [Serie_inceput]    VARCHAR (13)  NULL,
    [Serie_sfarsit]    VARCHAR (13)  NULL,
    [Nr_tichete]       REAL          NOT NULL,
    [Valoare_tichet]   FLOAT (53)    NOT NULL,
    [Valoare_imprimat] FLOAT (53)    NOT NULL,
    [TVA_imprimat]     FLOAT (53)    NOT NULL
) ON [SYSS];

