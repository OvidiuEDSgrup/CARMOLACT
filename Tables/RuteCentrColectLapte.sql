CREATE TABLE [dbo].[RuteCentrColectLapte] (
    [Ruta]   CHAR (5) NOT NULL,
    [Centru] CHAR (9) NOT NULL,
    [Ordine] SMALLINT NOT NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Unic]
    ON [dbo].[RuteCentrColectLapte]([Ruta] ASC, [Centru] ASC);


GO
CREATE NONCLUSTERED INDEX [Ordine]
    ON [dbo].[RuteCentrColectLapte]([Ruta] ASC, [Ordine] ASC);

