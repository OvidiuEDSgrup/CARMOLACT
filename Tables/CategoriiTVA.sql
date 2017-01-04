CREATE TABLE [dbo].[CategoriiTVA] (
    [CategorieTVA] VARCHAR (2)    NOT NULL,
    [DeLa]         DATETIME       NOT NULL,
    [CotaTVA]      DECIMAL (5, 2) NOT NULL,
    CONSTRAINT [PK_CategoriiTVA] PRIMARY KEY CLUSTERED ([CategorieTVA] ASC, [DeLa] ASC)
);

