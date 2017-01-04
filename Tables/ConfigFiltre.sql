CREATE TABLE [dbo].[ConfigFiltre] (
    [Tip]        VARCHAR (1)   NOT NULL,
    [Utilizator] VARCHAR (10)  NOT NULL,
    [Cod_filtru] VARCHAR (20)  NOT NULL,
    [Valoare]    VARCHAR (100) NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Principal]
    ON [dbo].[ConfigFiltre]([Tip] ASC, [Utilizator] ASC, [Cod_filtru] ASC, [Valoare] ASC);

