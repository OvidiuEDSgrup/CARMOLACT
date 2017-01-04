CREATE TABLE [dbo].[FisiereContract] (
    [idFisier]      INT            IDENTITY (1, 1) NOT NULL,
    [idPozContract] INT            NULL,
    [idContract]    INT            NULL,
    [fisier]        VARCHAR (2000) NULL,
    [observatii]    VARCHAR (2000) NULL,
    PRIMARY KEY CLUSTERED ([idFisier] ASC),
    FOREIGN KEY ([idPozContract]) REFERENCES [dbo].[PozContracte] ([idPozContract]),
    CONSTRAINT [FK__FisiereCo__idCon__0FEA2AA2] FOREIGN KEY ([idContract]) REFERENCES [dbo].[Contracte] ([idContract]) ON DELETE CASCADE
);

