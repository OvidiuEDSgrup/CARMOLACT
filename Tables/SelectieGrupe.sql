CREATE TABLE [dbo].[SelectieGrupe] (
    [Terminal]        CHAR (8)  NOT NULL,
    [Tip_nomenclator] CHAR (1)  NOT NULL,
    [Grupa]           CHAR (13) NOT NULL,
    [Grupa_parinte]   CHAR (13) NOT NULL,
    [Denumire_grupa]  CHAR (50) NOT NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Unic]
    ON [dbo].[SelectieGrupe]([Terminal] ASC, [Grupa] ASC);

