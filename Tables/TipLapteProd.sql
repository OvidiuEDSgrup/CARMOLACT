CREATE TABLE [dbo].[TipLapteProd] (
    [Producator]       CHAR (9)   NOT NULL,
    [Tip_lapte]        CHAR (20)  NOT NULL,
    [Grasime_standard] REAL       NOT NULL,
    [Pret]             FLOAT (53) NOT NULL,
    [Cantitate]        FLOAT (53) NOT NULL,
    [Procent]          REAL       NOT NULL,
    [UM]               CHAR (3)   NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Unic]
    ON [dbo].[TipLapteProd]([Producator] ASC, [Tip_lapte] ASC);

