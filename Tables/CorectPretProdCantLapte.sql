CREATE TABLE [dbo].[CorectPretProdCantLapte] (
    [Producator] CHAR (9)   NOT NULL,
    [Data_lunii] DATETIME   NOT NULL,
    [Tip_lapte]  CHAR (20)  NOT NULL,
    [Bonus]      FLOAT (53) NOT NULL,
    [Penalizare] FLOAT (53) NOT NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Unic]
    ON [dbo].[CorectPretProdCantLapte]([Producator] ASC, [Data_lunii] DESC, [Tip_lapte] ASC);

