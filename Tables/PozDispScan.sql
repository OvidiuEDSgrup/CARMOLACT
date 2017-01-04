CREATE TABLE [dbo].[PozDispScan] (
    [idDet]      INT          IDENTITY (1, 1) NOT NULL,
    [idDisp]     INT          NULL,
    [tipPozitie] VARCHAR (50) NULL,
    [barcode]    VARCHAR (50) NULL,
    [cod]        VARCHAR (50) NULL,
    [cantitate]  FLOAT (53)   NULL,
    [locatie]    VARCHAR (50) NULL,
    [utilizator] VARCHAR (50) NULL,
    [data]       DATETIME     NULL,
    [detaliiXML] XML          NULL,
    CONSTRAINT [PK_idDep] PRIMARY KEY CLUSTERED ([idDet] ASC),
    CONSTRAINT [FK_idDisp_PozDispScand] FOREIGN KEY ([idDisp]) REFERENCES [dbo].[AntDisp] ([idDisp])
);

