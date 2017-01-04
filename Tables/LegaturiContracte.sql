CREATE TABLE [dbo].[LegaturiContracte] (
    [idLegatura]                INT IDENTITY (1, 1) NOT NULL,
    [idJurnal]                  INT NULL,
    [idPozContract]             INT NULL,
    [idPozDoc]                  INT NULL,
    [idPozContractCorespondent] INT NULL,
    PRIMARY KEY CLUSTERED ([idLegatura] ASC),
    FOREIGN KEY ([idJurnal]) REFERENCES [dbo].[JurnalContracte] ([idJurnal]),
    FOREIGN KEY ([idPozContract]) REFERENCES [dbo].[PozContracte] ([idPozContract]),
    FOREIGN KEY ([idPozContractCorespondent]) REFERENCES [dbo].[PozContracte] ([idPozContract])
);


GO
CREATE NONCLUSTERED INDEX [IX_idPozContract_LegaturiContracte]
    ON [dbo].[LegaturiContracte]([idPozContract] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_idPozContractCorespondent_LegaturiContracte]
    ON [dbo].[LegaturiContracte]([idPozContractCorespondent] ASC);


GO
CREATE NONCLUSTERED INDEX [missing_index_50]
    ON [dbo].[LegaturiContracte]([idPozDoc] ASC)
    INCLUDE([idLegatura]);


GO
CREATE NONCLUSTERED INDEX [missing_index_63]
    ON [dbo].[LegaturiContracte]([idJurnal] ASC);


GO
CREATE NONCLUSTERED INDEX [missing_index_28]
    ON [dbo].[LegaturiContracte]([idPozDoc] ASC)
    INCLUDE([idLegatura]);


GO
CREATE NONCLUSTERED INDEX [missing_index_22]
    ON [dbo].[LegaturiContracte]([idJurnal] ASC);

