CREATE TABLE [dbo].[TipLapte] (
    [Cod]              CHAR (20) NOT NULL,
    [Denumire]         CHAR (30) NOT NULL,
    [Grasime_standard] REAL      NOT NULL,
    [Cota]             BIT       NOT NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Unic]
    ON [dbo].[TipLapte]([Cod] ASC);

