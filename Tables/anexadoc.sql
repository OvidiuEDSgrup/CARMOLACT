CREATE TABLE [dbo].[anexadoc] (
    [Subunitate]          VARCHAR (9)   NOT NULL,
    [Tip]                 VARCHAR (2)   NOT NULL,
    [Numar]               VARCHAR (8)   NOT NULL,
    [Data]                DATETIME2 (0) NOT NULL,
    [Numele_delegatului]  VARCHAR (30)  NOT NULL,
    [Seria_buletin]       VARCHAR (10)  NOT NULL,
    [Numar_buletin]       VARCHAR (50)  NOT NULL,
    [Eliberat]            VARCHAR (30)  NOT NULL,
    [Mijloc_de_transport] VARCHAR (50)  NOT NULL,
    [Numarul_mijlocului]  VARCHAR (20)  NOT NULL,
    [Data_expedierii]     DATETIME2 (0) NOT NULL,
    [Ora_expedierii]      CHAR (6)      NOT NULL,
    [Observatii]          VARCHAR (200) NOT NULL,
    [Punct_livrare]       VARCHAR (50)  NOT NULL,
    [Tip_anexa]           VARCHAR (1)   NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Document]
    ON [dbo].[anexadoc]([Subunitate] ASC, [Tip] ASC, [Numar] ASC, [Data] ASC, [Tip_anexa] ASC);


GO
CREATE NONCLUSTERED INDEX [missing_index_970]
    ON [dbo].[anexadoc]([Tip] ASC, [Numar] ASC)
    INCLUDE([Mijloc_de_transport]);


GO
CREATE NONCLUSTERED INDEX [missing_index_968]
    ON [dbo].[anexadoc]([Tip] ASC, [Numar] ASC)
    INCLUDE([Eliberat]);


GO
CREATE NONCLUSTERED INDEX [missing_index_966]
    ON [dbo].[anexadoc]([Tip] ASC, [Numar] ASC)
    INCLUDE([Numele_delegatului]);


GO
CREATE NONCLUSTERED INDEX [missing_index_976]
    ON [dbo].[anexadoc]([Tip] ASC)
    INCLUDE([Numar], [Numele_delegatului]);


GO
CREATE NONCLUSTERED INDEX [missing_index_974]
    ON [dbo].[anexadoc]([Tip] ASC)
    INCLUDE([Numar], [Eliberat]);


GO
CREATE NONCLUSTERED INDEX [missing_index_972]
    ON [dbo].[anexadoc]([Tip] ASC)
    INCLUDE([Numar], [Mijloc_de_transport]);

