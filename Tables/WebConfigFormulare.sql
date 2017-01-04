CREATE TABLE [dbo].[WebConfigFormulare] (
    [idAsociere]   INT          IDENTITY (1, 1) NOT NULL,
    [meniu]        VARCHAR (20) NOT NULL,
    [tip]          VARCHAR (20) NULL,
    [cod_formular] VARCHAR (50) NULL,
    [detalii]      XML          NULL,
    [loc_munca]    VARCHAR (9)  NULL,
    PRIMARY KEY CLUSTERED ([idAsociere] ASC),
    CONSTRAINT [webconfigformulare_meniu_unic] UNIQUE NONCLUSTERED ([meniu] ASC, [tip] ASC, [cod_formular] ASC)
);

