CREATE TABLE [dbo].[gesttmp] (
    [Terminal] SMALLINT NOT NULL,
    [Gestiune] CHAR (9) NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Cod_gestiune]
    ON [dbo].[gesttmp]([Terminal] ASC, [Gestiune] ASC);

