CREATE TABLE [dbo].[GrilaPretProdLapte] (
    [Producator] CHAR (9)   NOT NULL,
    [Data_lunii] DATETIME   NOT NULL,
    [Tip_lapte]  CHAR (20)  NOT NULL,
    [Pret]       FLOAT (53) NOT NULL,
    [Gras_STAS]  REAL       NOT NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Unic]
    ON [dbo].[GrilaPretProdLapte]([Producator] ASC, [Data_lunii] ASC, [Tip_lapte] ASC);

