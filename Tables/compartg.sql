CREATE TABLE [dbo].[compartg] (
    [Articol_grup]       CHAR (9) NOT NULL,
    [Articol_componenta] CHAR (9) NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Unic]
    ON [dbo].[compartg]([Articol_grup] ASC, [Articol_componenta] ASC);

