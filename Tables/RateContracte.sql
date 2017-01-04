CREATE TABLE [dbo].[RateContracte] (
    [idRataContract] INT          IDENTITY (1, 1) NOT NULL,
    [idContract]     INT          NULL,
    [nr_rata]        INT          NULL,
    [cod]            VARCHAR (20) NULL,
    [suma]           FLOAT (53)   NULL,
    [detalii]        XML          NULL,
    PRIMARY KEY CLUSTERED ([idRataContract] ASC),
    CONSTRAINT [FK__RateContr__idCon__14AEDFBF] FOREIGN KEY ([idContract]) REFERENCES [dbo].[Contracte] ([idContract]) ON DELETE CASCADE
);

