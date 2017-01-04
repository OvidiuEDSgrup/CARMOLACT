CREATE TABLE [dbo].[matrep] (
    [Cod_reper]              CHAR (20)  NOT NULL,
    [Cod_material]           CHAR (20)  NOT NULL,
    [Cod_operatie]           CHAR (20)  NOT NULL,
    [Numar_material]         SMALLINT   NOT NULL,
    [Tip_material]           CHAR (1)   NOT NULL,
    [_supr]                  FLOAT (53) NOT NULL,
    [Coeficient_de_consum]   FLOAT (53) NOT NULL,
    [Randament_de_utilizare] FLOAT (53) NOT NULL,
    [Consum_specific]        FLOAT (53) NOT NULL,
    [Cod_inlocuit]           CHAR (20)  NOT NULL,
    [Loc_de_munca]           CHAR (13)  NOT NULL,
    [Observatii]             CHAR (200) NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Structura]
    ON [dbo].[matrep]([Cod_reper] ASC, [Numar_material] ASC, [Cod_material] ASC, [Loc_de_munca] ASC);


GO
CREATE NONCLUSTERED INDEX [Cod_material]
    ON [dbo].[matrep]([Cod_reper] ASC, [Cod_material] ASC, [Loc_de_munca] ASC);


GO
CREATE NONCLUSTERED INDEX [Inlocuitor]
    ON [dbo].[matrep]([Cod_reper] ASC, [Cod_inlocuit] ASC);

