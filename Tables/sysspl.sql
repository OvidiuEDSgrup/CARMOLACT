CREATE TABLE [dbo].[sysspl] (
    [Host_id]            VARCHAR (10)  NULL,
    [Host_name]          VARCHAR (30)  NULL,
    [Aplicatia]          VARCHAR (30)  NULL,
    [Data_stergerii]     DATETIME2 (7) NULL,
    [Stergator]          VARCHAR (10)  NULL,
    [Tip_act]            VARCHAR (1)   NULL,
    [Data]               DATETIME2 (3) NULL,
    [Tip]                VARCHAR (2)   NULL,
    [Parametru]          VARCHAR (9)   NULL,
    [Denumire_parametru] VARCHAR (30)  NULL,
    [Val_logica]         BIT           NOT NULL,
    [Val_numerica]       FLOAT (53)    NOT NULL,
    [Val_alfanumerica]   VARCHAR (200) NULL,
    [Val_data]           DATETIME2 (3) NULL
) ON [SYSS];

