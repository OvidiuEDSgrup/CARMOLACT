CREATE TABLE [dbo].[syssterm] (
    [Host_id]        VARCHAR (10)  NULL,
    [Host_name]      VARCHAR (30)  NULL,
    [Aplicatia]      VARCHAR (30)  NULL,
    [Data_stergerii] DATETIME2 (7) NULL,
    [Stergator]      VARCHAR (10)  NULL,
    [Subunitate]     VARCHAR (9)   NULL,
    [Tip]            VARCHAR (2)   NULL,
    [Contract]       VARCHAR (20)  NULL,
    [Tert]           VARCHAR (13)  NULL,
    [Cod]            VARCHAR (20)  NULL,
    [Data]           DATETIME2 (3) NULL,
    [Termen]         DATETIME2 (3) NULL,
    [Cantitate]      FLOAT (53)    NOT NULL,
    [Cant_realizata] FLOAT (53)    NOT NULL,
    [Pret]           FLOAT (53)    NOT NULL,
    [Explicatii]     VARCHAR (200) NULL,
    [Val1]           FLOAT (53)    NOT NULL,
    [Val2]           FLOAT (53)    NOT NULL,
    [Data1]          DATETIME2 (3) NULL,
    [Data2]          DATETIME2 (3) NULL
) ON [SYSS];

