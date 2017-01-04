CREATE TABLE [dbo].[AntDisp] (
    [idDisp]              INT            IDENTITY (1, 1) NOT NULL,
    [tipDisp]             VARCHAR (50)   NULL,
    [descriere]           VARCHAR (2000) NULL,
    [stare]               VARCHAR (50)   NULL,
    [detaliiXml]          XML            NULL,
    [utilizator]          VARCHAR (50)   NULL,
    [dataUltimeiOperatii] DATETIME       NULL,
    CONSTRAINT [PK_id] PRIMARY KEY CLUSTERED ([idDisp] ASC)
);

