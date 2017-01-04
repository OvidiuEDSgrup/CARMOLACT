CREATE TABLE [dbo].[erorips] (
    [Tabela]     CHAR (20)  NOT NULL,
    [Camp]       CHAR (25)  NOT NULL,
    [Data]       DATETIME   NOT NULL,
    [Marca]      CHAR (6)   NOT NULL,
    [Continut_1] CHAR (13)  NOT NULL,
    [Tip_eroare] CHAR (3)   NOT NULL,
    [Explicatii] CHAR (150) NOT NULL,
    [Valoare_1]  FLOAT (53) NOT NULL,
    [Valoare_2]  FLOAT (53) NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Unic]
    ON [dbo].[erorips]([Tabela] ASC, [Camp] ASC, [Data] ASC, [Marca] ASC, [Continut_1] ASC);

