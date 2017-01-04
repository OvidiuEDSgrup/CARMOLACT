CREATE TABLE [dbo].[webConfigGrid] (
    [Meniu]       VARCHAR (20)  NOT NULL,
    [Tip]         VARCHAR (2)   NULL,
    [Subtip]      VARCHAR (2)   NULL,
    [InPozitii]   BIT           NOT NULL,
    [NumeCol]     VARCHAR (50)  NULL,
    [DataField]   VARCHAR (50)  NULL,
    [TipObiect]   VARCHAR (50)  NULL,
    [Latime]      INT           NULL,
    [Ordine]      INT           NULL,
    [Vizibil]     BIT           NULL,
    [Modificabil] BIT           NULL,
    [formula]     VARCHAR (MAX) NULL,
    [detalii]     XML           NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [PrincwebConfigGrid]
    ON [dbo].[webConfigGrid]([Meniu] ASC, [Tip] ASC, [Subtip] ASC, [DataField] ASC, [InPozitii] ASC, [Ordine] ASC);

