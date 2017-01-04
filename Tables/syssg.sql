CREATE TABLE [dbo].[syssg] (
    [Host_id]                VARCHAR (10)  NULL,
    [Host_name]              VARCHAR (30)  NULL,
    [Aplicatia]              VARCHAR (30)  NULL,
    [Data_stergerii]         DATETIME2 (7) NULL,
    [Stergator]              VARCHAR (10)  NULL,
    [Subunitate]             VARCHAR (9)   NULL,
    [Tip_gestiune]           VARCHAR (1)   NULL,
    [Cod_gestiune]           VARCHAR (9)   NULL,
    [Denumire_gestiune]      VARCHAR (43)  NULL,
    [Cont_contabil_specific] VARCHAR (20)  NULL
) ON [SYSS];

