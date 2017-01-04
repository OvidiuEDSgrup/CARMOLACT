CREATE TABLE [dbo].[sysselemactiv] (
    [Host_id]        VARCHAR (10)  NULL,
    [Host_name]      VARCHAR (30)  NULL,
    [Aplicatia]      VARCHAR (30)  NULL,
    [Data_operarii]  DATETIME2 (3) NULL,
    [Utilizator]     VARCHAR (10)  NULL,
    [Tip_act]        VARCHAR (1)   NULL,
    [Tip]            VARCHAR (2)   NULL,
    [Fisa]           VARCHAR (10)  NULL,
    [Data]           DATETIME2 (3) NULL,
    [Numar_pozitie]  INT           NOT NULL,
    [Element]        VARCHAR (20)  NULL,
    [Valoare]        FLOAT (53)    NOT NULL,
    [Tip_document]   VARCHAR (2)   NULL,
    [Numar_document] VARCHAR (8)   NULL,
    [Data_document]  DATETIME2 (3) NULL
) ON [SYSS];

