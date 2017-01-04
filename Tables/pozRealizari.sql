CREATE TABLE [dbo].[pozRealizari] (
    [id]              INT           IDENTITY (1, 1) NOT NULL,
    [idLegatura]      INT           NOT NULL,
    [idRealizare]     INT           NOT NULL,
    [tip]             VARCHAR (2)   NULL,
    [cantitate]       FLOAT (53)    NULL,
    [observatii]      VARCHAR (400) NULL,
    [CM]              VARCHAR (13)  NULL,
    [PP]              VARCHAR (13)  NULL,
    [detalii]         XML           NULL,
    [data_start]      DATETIME      NULL,
    [data_stop]       DATETIME      NULL,
    [idPozLansare]    INT           NULL,
    [idPozTehnologie] INT           NULL,
    [idPlanificare]   INT           NULL,
    [idResursa]       INT           NULL,
    CONSTRAINT [FK_idPlanificare] FOREIGN KEY ([idPlanificare]) REFERENCES [dbo].[planificare] ([id]),
    CONSTRAINT [FK_idPozLansare] FOREIGN KEY ([idPozLansare]) REFERENCES [dbo].[pozLansari] ([id]),
    CONSTRAINT [FK_idPozTehnologie] FOREIGN KEY ([idPozTehnologie]) REFERENCES [dbo].[pozTehnologii] ([id])
);


GO
CREATE NONCLUSTERED INDEX [princ]
    ON [dbo].[pozRealizari]([idRealizare] ASC, [idLegatura] ASC, [tip] ASC) WITH (FILLFACTOR = 20);


GO
CREATE NONCLUSTERED INDEX [missing_index_3]
    ON [dbo].[pozRealizari]([tip] ASC)
    INCLUDE([id], [idRealizare], [CM], [PP]);

