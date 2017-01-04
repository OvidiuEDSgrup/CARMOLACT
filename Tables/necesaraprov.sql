CREATE TABLE [dbo].[necesaraprov] (
    [Numar]         CHAR (8)   NOT NULL,
    [Data]          DATETIME   NOT NULL,
    [Numar_pozitie] INT        NOT NULL,
    [Gestiune]      CHAR (9)   NOT NULL,
    [Cod]           CHAR (20)  NOT NULL,
    [Cantitate]     FLOAT (53) NOT NULL,
    [Stare]         CHAR (1)   NOT NULL,
    [Loc_de_munca]  CHAR (9)   NOT NULL,
    [Comanda]       CHAR (13)  NOT NULL,
    [Numar_fisa]    CHAR (8)   NOT NULL,
    [Utilizator]    CHAR (10)  NOT NULL,
    [Data_operarii] DATETIME   NOT NULL,
    [Ora_operarii]  CHAR (6)   NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Principal]
    ON [dbo].[necesaraprov]([Numar] ASC, [Data] ASC, [Numar_pozitie] ASC);


GO
CREATE NONCLUSTERED INDEX [Cod]
    ON [dbo].[necesaraprov]([Numar] ASC, [Data] ASC, [Cod] ASC);


GO
CREATE NONCLUSTERED INDEX [Stare]
    ON [dbo].[necesaraprov]([Data] ASC, [Stare] ASC);


GO
CREATE NONCLUSTERED INDEX [Fisa]
    ON [dbo].[necesaraprov]([Comanda] ASC, [Numar_fisa] ASC, [Cod] ASC);

