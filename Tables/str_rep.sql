CREATE TABLE [dbo].[str_rep] (
    [Cod_reper_parinte] CHAR (20)  NOT NULL,
    [Cod]               CHAR (20)  NOT NULL,
    [Cantitate]         FLOAT (53) NOT NULL,
    [Nr_reper]          FLOAT (53) NOT NULL,
    [Loc_de_munca]      CHAR (9)   NOT NULL,
    [Alfa1]             CHAR (20)  NOT NULL,
    [Alfa2]             CHAR (20)  NOT NULL,
    [Alfa3]             CHAR (20)  NOT NULL,
    [Alfa4]             CHAR (20)  NOT NULL,
    [Val1]              FLOAT (53) NOT NULL,
    [Val2]              FLOAT (53) NOT NULL,
    [Val3]              FLOAT (53) NOT NULL,
    [Val4]              FLOAT (53) NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Str_rep1]
    ON [dbo].[str_rep]([Cod_reper_parinte] ASC, [Cod] ASC, [Nr_reper] ASC);


GO
CREATE NONCLUSTERED INDEX [Str_rep2]
    ON [dbo].[str_rep]([Cod] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Str_rep3]
    ON [dbo].[str_rep]([Cod_reper_parinte] ASC, [Nr_reper] ASC, [Cod] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Str_rep4]
    ON [dbo].[str_rep]([Cod_reper_parinte] ASC, [Loc_de_munca] ASC, [Cod] ASC, [Nr_reper] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Str_rep5]
    ON [dbo].[str_rep]([Cod_reper_parinte] ASC, [Loc_de_munca] ASC, [Nr_reper] ASC, [Cod] ASC);

