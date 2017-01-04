CREATE TABLE [dbo].[GrilaPretProdSemifabrLapte] (
    [Cod]        CHAR (20)  NOT NULL,
    [Data_lunii] DATETIME   NOT NULL,
    [Pret]       FLOAT (53) NOT NULL,
    [Tip_doc]    CHAR (2)   NOT NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Unic]
    ON [dbo].[GrilaPretProdSemifabrLapte]([Cod] ASC, [Data_lunii] ASC);

