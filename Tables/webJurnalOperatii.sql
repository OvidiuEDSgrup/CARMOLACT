﻿CREATE TABLE [dbo].[webJurnalOperatii] (
    [id]           INT           IDENTITY (1, 1) NOT NULL,
    [sesiune]      VARCHAR (50)  NULL,
    [utilizator]   VARCHAR (100) NULL,
    [data]         DATETIME      NULL,
    [tip]          VARCHAR (2)   NULL,
    [obiectSql]    VARCHAR (100) NULL,
    [parametruXML] XML           NULL,
    CONSTRAINT [PK_webJurnalOperatii_id] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_Utilizator_data]
    ON [dbo].[webJurnalOperatii]([utilizator] ASC, [data] DESC);

