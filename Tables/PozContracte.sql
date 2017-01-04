CREATE TABLE [dbo].[PozContracte] (
    [idPozContract] INT          IDENTITY (1, 1) NOT NULL,
    [idContract]    INT          NULL,
    [cod]           VARCHAR (20) NULL,
    [grupa]         VARCHAR (20) NULL,
    [cantitate]     FLOAT (53)   NULL,
    [pret]          FLOAT (53)   NULL,
    [discount]      FLOAT (53)   NULL,
    [termen]        DATETIME     NULL,
    [periodicitate] INT          NULL,
    [explicatii]    VARCHAR (60) NULL,
    [detalii]       XML          NULL,
    [cod_specific]  VARCHAR (20) NULL,
    [idPozLansare]  INT          NULL,
    [subtip]        VARCHAR (20) NULL,
    [Numar_pozitie] INT          NULL,
    PRIMARY KEY CLUSTERED ([idPozContract] ASC),
    FOREIGN KEY ([idContract]) REFERENCES [dbo].[Contracte] ([idContract])
);


GO
CREATE NONCLUSTERED INDEX [IX_idContract]
    ON [dbo].[PozContracte]([idContract] ASC);

