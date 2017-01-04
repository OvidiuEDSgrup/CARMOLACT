CREATE TABLE [dbo].[Filtre] (
    [Cod_filtru]   VARCHAR (50)  NOT NULL,
    [Tabela]       VARCHAR (100) NOT NULL,
    [Numar]        VARCHAR (30)  NOT NULL,
    [Camp_afectat] VARCHAR (100) NOT NULL,
    [Fel_operator] VARCHAR (100) NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Principal]
    ON [dbo].[Filtre]([Cod_filtru] ASC);


GO
CREATE NONCLUSTERED INDEX [Dupa_bara]
    ON [dbo].[Filtre]([Tabela] ASC);

