CREATE TABLE [dbo].[grupe] (
    [Tip_de_nomenclator] CHAR (1)     NOT NULL,
    [Grupa]              CHAR (13)    NOT NULL,
    [Denumire]           CHAR (30)    NOT NULL,
    [Proprietate_1]      BIT          NOT NULL,
    [Proprietate_2]      BIT          NOT NULL,
    [Proprietate_3]      BIT          NOT NULL,
    [Proprietate_4]      BIT          NOT NULL,
    [Proprietate_5]      BIT          NOT NULL,
    [Proprietate_6]      BIT          NOT NULL,
    [Proprietate_7]      BIT          NOT NULL,
    [Proprietate_8]      BIT          NOT NULL,
    [Proprietate_9]      BIT          NOT NULL,
    [Proprietate_10]     BIT          NOT NULL,
    [detalii]            XML          NULL,
    [grupa_parinte]      VARCHAR (20) NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Unic]
    ON [dbo].[grupe]([Tip_de_nomenclator] ASC, [Grupa] ASC);


GO
CREATE NONCLUSTERED INDEX [Denumire]
    ON [dbo].[grupe]([Denumire] ASC);


GO
CREATE NONCLUSTERED INDEX [Grupa]
    ON [dbo].[grupe]([Grupa] ASC);

