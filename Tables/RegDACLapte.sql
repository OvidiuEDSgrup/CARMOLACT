CREATE TABLE [dbo].[RegDACLapte] (
    [Regiune] CHAR (30) NOT NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Unic]
    ON [dbo].[RegDACLapte]([Regiune] ASC);

