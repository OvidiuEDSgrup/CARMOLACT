CREATE TABLE [dbo].[surseImobilizari] (
    [sursa]    VARCHAR (20) NULL,
    [denumire] VARCHAR (80) NULL,
    [detalii]  XML          NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [sursa]
    ON [dbo].[surseImobilizari]([sursa] ASC);

