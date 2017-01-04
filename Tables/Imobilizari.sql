CREATE TABLE [dbo].[Imobilizari] (
    [nrinv]    VARCHAR (13) NULL,
    [denumire] VARCHAR (80) NULL,
    [serie]    VARCHAR (20) NULL,
    [tipam]    VARCHAR (1)  NULL,
    [codcl]    VARCHAR (20) NULL,
    [datapf]   DATETIME     NULL,
    [detalii]  XML          NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Nrinv]
    ON [dbo].[Imobilizari]([nrinv] ASC);


GO
CREATE NONCLUSTERED INDEX [Denumire]
    ON [dbo].[Imobilizari]([denumire] ASC);

