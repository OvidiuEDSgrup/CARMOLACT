CREATE TABLE [dbo].[opreper] (
    [Cod_reper]            CHAR (20)  NOT NULL,
    [Cod]                  CHAR (20)  NOT NULL,
    [Numar_operatie]       SMALLINT   NOT NULL,
    [Loc_de_munca]         CHAR (9)   NOT NULL,
    [Comanda]              CHAR (13)  NOT NULL,
    [Timp_de_pregatire]    FLOAT (53) NOT NULL,
    [Timp_util]            FLOAT (53) NOT NULL,
    [Categoria_salarizare] CHAR (4)   NOT NULL,
    [Norma_de_timp]        FLOAT (53) NOT NULL,
    [Tarif_unitar]         FLOAT (53) NOT NULL,
    [Cantitate_neta]       FLOAT (53) NOT NULL,
    [Lungime_dupa_op]      FLOAT (53) NOT NULL,
    [Latime_dupa_op]       FLOAT (53) NOT NULL,
    [Inaltime_dupa_op]     FLOAT (53) NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [CodRep_NrOp]
    ON [dbo].[opreper]([Cod_reper] ASC, [Numar_operatie] ASC);


GO
CREATE NONCLUSTERED INDEX [CodRep_CodOp]
    ON [dbo].[opreper]([Cod_reper] ASC, [Cod] ASC);


GO
CREATE NONCLUSTERED INDEX [Faze]
    ON [dbo].[opreper]([Cod_reper] ASC, [Lungime_dupa_op] ASC, [Latime_dupa_op] ASC, [Numar_operatie] ASC);

