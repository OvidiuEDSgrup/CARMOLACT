CREATE TABLE [dbo].[AdevSubvenLapte] (
    [Nr_inregistrare]         CHAR (9)   NOT NULL,
    [Data]                    DATETIME   NOT NULL,
    [Producator]              CHAR (9)   NOT NULL,
    [Data_inf_perioada]       DATETIME   NOT NULL,
    [Data_sup_perioada]       DATETIME   NOT NULL,
    [Rezultat_trimestru]      BIT        NOT NULL,
    [Cantitate_livrata]       FLOAT (53) NOT NULL,
    [Cantitate_subventionata] FLOAT (53) NOT NULL,
    [Data_operarii]           DATETIME   NOT NULL,
    [Ora_operarii]            CHAR (6)   NOT NULL,
    [Utilizator]              CHAR (10)  NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Producator]
    ON [dbo].[AdevSubvenLapte]([Producator] ASC, [Data_inf_perioada] ASC, [Data_sup_perioada] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Unic]
    ON [dbo].[AdevSubvenLapte]([Nr_inregistrare] ASC, [Data] ASC);

