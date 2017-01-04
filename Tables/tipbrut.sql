CREATE TABLE [dbo].[tipbrut] (
    [Numar_curent] SMALLINT  NOT NULL,
    [Valoare]      SMALLINT  NOT NULL,
    [Denumire]     CHAR (30) NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Secundar]
    ON [dbo].[tipbrut]([Numar_curent] ASC);


GO
CREATE NONCLUSTERED INDEX [Principal]
    ON [dbo].[tipbrut]([Valoare] ASC);

