CREATE TABLE [dbo].[PozDispOp] (
    [idPoz]         INT          IDENTITY (1, 1) NOT NULL,
    [idDisp]        INT          NULL,
    [grupare]       VARCHAR (50) NULL,
    [stare]         VARCHAR (50) NULL,
    [cod]           VARCHAR (50) NULL,
    [cantitate]     FLOAT (53)   NULL,
    [pret]          FLOAT (53)   NULL,
    [tipDocSursa]   VARCHAR (50) NULL,
    [numarDocSursa] VARCHAR (50) NULL,
    [dataDocSursa]  VARCHAR (50) NULL,
    [detaliiXML]    XML          NULL,
    [utilizator]    VARCHAR (50) NULL,
    [data]          DATETIME     NULL,
    CONSTRAINT [PK_idPoz] PRIMARY KEY CLUSTERED ([idPoz] ASC),
    CONSTRAINT [FK_idDisp_PozDispOp] FOREIGN KEY ([idDisp]) REFERENCES [dbo].[AntDisp] ([idDisp])
);

