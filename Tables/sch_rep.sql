CREATE TABLE [dbo].[sch_rep] (
    [Terminal]        SMALLINT   NOT NULL,
    [Cod_reper]       CHAR (20)  NOT NULL,
    [Cant_in_parinte] FLOAT (53) NOT NULL,
    [Cant_in_produs]  FLOAT (53) NOT NULL,
    [Nivel]           FLOAT (53) NOT NULL,
    [Ordine]          FLOAT (53) NOT NULL,
    [Cod_parinte]     CHAR (20)  NOT NULL,
    [Nr_reper]        FLOAT (53) NOT NULL,
    [Loc_de_munca]    CHAR (9)   NOT NULL,
    [Nr_fisa]         CHAR (8)   NOT NULL,
    [Alfa1]           CHAR (20)  NOT NULL,
    [Alfa2]           CHAR (20)  NOT NULL,
    [Val1]            FLOAT (53) NOT NULL,
    [Val2]            FLOAT (53) NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Ordine]
    ON [dbo].[sch_rep]([Terminal] ASC, [Ordine] ASC);


GO
CREATE NONCLUSTERED INDEX [Cod]
    ON [dbo].[sch_rep]([Cod_reper] ASC, [Terminal] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Nivel_si_ordine]
    ON [dbo].[sch_rep]([Nivel] ASC, [Ordine] ASC, [Terminal] ASC);

