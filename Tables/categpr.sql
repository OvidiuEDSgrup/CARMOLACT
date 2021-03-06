﻿CREATE TABLE [dbo].[categpr] (
    [Tip]      VARCHAR (1)  NOT NULL,
    [Categ]    VARCHAR (13) NOT NULL,
    [Denumire] VARCHAR (50) NOT NULL,
    [Formular] FLOAT (53)   NOT NULL,
    [Alfa1]    VARCHAR (13) NOT NULL,
    [Alfa2]    VARCHAR (13) NOT NULL,
    [Val1]     FLOAT (53)   NOT NULL,
    [Val2]     FLOAT (53)   NOT NULL,
    [Data_rez] DATETIME     NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Categpr1]
    ON [dbo].[categpr]([Tip] ASC, [Categ] ASC);


GO
CREATE NONCLUSTERED INDEX [Categpr2]
    ON [dbo].[categpr]([Tip] ASC, [Denumire] ASC);

