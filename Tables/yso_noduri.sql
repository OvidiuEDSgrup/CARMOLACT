CREATE TABLE [dbo].[yso_noduri] (
    [idnod]             CHAR (62)  NULL,
    [Subunitate]        CHAR (9)   NOT NULL,
    [Cod]               CHAR (20)  NOT NULL,
    [Gestiune]          CHAR (20)  NOT NULL,
    [Cod_intrare]       CHAR (13)  NOT NULL,
    [Data]              DATETIME   NOT NULL,
    [Pret_de_stoc]      FLOAT (53) NOT NULL,
    [Pret_cu_amanuntul] FLOAT (53) NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [nod]
    ON [dbo].[yso_noduri]([Subunitate] ASC, [Cod] ASC, [Gestiune] ASC, [Cod_intrare] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [idnod]
    ON [dbo].[yso_noduri]([idnod] ASC);

