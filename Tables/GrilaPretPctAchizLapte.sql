CREATE TABLE [dbo].[GrilaPretPctAchizLapte] (
    [Data]          DATETIME   NOT NULL,
    [Pct_achizitie] CHAR (9)   NOT NULL,
    [Tip_lapte]     CHAR (20)  NOT NULL,
    [Valoare]       FLOAT (53) NOT NULL,
    [Pret]          FLOAT (53) NOT NULL,
    [Grasime]       REAL       NOT NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Unic]
    ON [dbo].[GrilaPretPctAchizLapte]([Data] ASC, [Pct_achizitie] ASC, [Tip_lapte] ASC);

