CREATE TABLE [dbo].[cpv] (
    [cod]        NVARCHAR (100) NULL,
    [denumire]   NVARCHAR (500) NULL,
    [detalii]    XML            DEFAULT (NULL) NULL,
    [CodParinte] NVARCHAR (100) NULL
);


GO
CREATE CLUSTERED INDEX [indcod]
    ON [dbo].[cpv]([cod] ASC);

