CREATE TABLE [dbo].[docjustbug] (
    [Tip_ang]   CHAR (1)  NOT NULL,
    [Numar_ang] CHAR (8)  NOT NULL,
    [Data_ang]  DATETIME  NOT NULL,
    [Tip_doc]   CHAR (2)  NOT NULL,
    [Numar_doc] CHAR (13) NOT NULL,
    [Data_doc]  DATETIME  NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Principal]
    ON [dbo].[docjustbug]([Tip_ang] ASC, [Numar_ang] ASC, [Data_ang] ASC, [Tip_doc] ASC, [Numar_doc] ASC, [Data_doc] ASC);


GO
CREATE NONCLUSTERED INDEX [Angajament]
    ON [dbo].[docjustbug]([Tip_ang] ASC, [Numar_ang] ASC, [Data_ang] ASC);


GO
CREATE NONCLUSTERED INDEX [Document]
    ON [dbo].[docjustbug]([Tip_doc] ASC, [Numar_doc] ASC, [Data_doc] ASC);

