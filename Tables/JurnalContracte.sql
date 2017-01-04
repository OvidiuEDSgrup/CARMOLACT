CREATE TABLE [dbo].[JurnalContracte] (
    [idJurnal]   INT           IDENTITY (1, 1) NOT NULL,
    [idContract] INT           NULL,
    [data]       DATETIME      NULL,
    [stare]      INT           NULL,
    [explicatii] VARCHAR (60)  NULL,
    [detalii]    XML           NULL,
    [utilizator] VARCHAR (100) NULL,
    PRIMARY KEY CLUSTERED ([idJurnal] ASC),
    CONSTRAINT [FK__JurnalCon__idCon__197394DC] FOREIGN KEY ([idContract]) REFERENCES [dbo].[Contracte] ([idContract]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_idContract]
    ON [dbo].[JurnalContracte]([idContract] ASC);

