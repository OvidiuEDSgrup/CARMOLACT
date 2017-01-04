CREATE TABLE [dbo].[GrupeProdLapte] (
    [Cod_grupa] CHAR (1)  NOT NULL,
    [Denumire]  CHAR (50) NOT NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Unic]
    ON [dbo].[GrupeProdLapte]([Cod_grupa] ASC);

