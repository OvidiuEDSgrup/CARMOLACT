CREATE TABLE [dbo].[ProdSemifabrLapte] (
    [Cod]          CHAR (20)  NOT NULL,
    [Proc_grasime] REAL       NOT NULL,
    [Pret_UG]      FLOAT (53) NOT NULL,
    [Pret]         FLOAT (53) NOT NULL,
    [Tip_doc]      CHAR (2)   NOT NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Unic]
    ON [dbo].[ProdSemifabrLapte]([Cod] ASC);

