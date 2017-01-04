CREATE TABLE [dbo].[JudRegDACLapte] (
    [Judet]             CHAR (30) NOT NULL,
    [Regiune]           CHAR (30) NOT NULL,
    [Laborator_analize] CHAR (30) NOT NULL,
    [Sediu_laborator]   CHAR (30) NOT NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Unic]
    ON [dbo].[JudRegDACLapte]([Judet] ASC);

