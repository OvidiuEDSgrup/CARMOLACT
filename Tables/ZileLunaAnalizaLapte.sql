CREATE TABLE [dbo].[ZileLunaAnalizaLapte] (
    [Ziua]       SMALLINT  NOT NULL,
    [Explicatii] CHAR (50) NOT NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Unic]
    ON [dbo].[ZileLunaAnalizaLapte]([Ziua] ASC);

