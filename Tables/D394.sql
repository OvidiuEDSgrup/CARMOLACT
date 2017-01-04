CREATE TABLE [dbo].[D394] (
    [data]            DATETIME      NULL,
    [lm]              VARCHAR (9)   NULL,
    [rand_decl]       VARCHAR (20)  NULL,
    [denumire]        VARCHAR (100) NULL,
    [tip_partener]    INT           NULL,
    [tipop]           CHAR (3)      NULL,
    [tli]             INT           NULL,
    [nrCui]           INT           NULL,
    [codtert]         VARCHAR (20)  NULL,
    [cuiP]            VARCHAR (20)  NULL,
    [denP]            VARCHAR (200) NULL,
    [cod]             VARCHAR (20)  NULL,
    [bun]             VARCHAR (8)   NULL,
    [nrfacturi]       INT           NULL,
    [baza]            FLOAT (53)    NULL,
    [tva]             FLOAT (53)    NULL,
    [cota_tva]        INT           NULL,
    [incasari]        FLOAT (53)    NULL,
    [cheltuieli]      FLOAT (53)    NULL,
    [tip]             INT           NULL,
    [serieI]          VARCHAR (10)  NULL,
    [nrI]             VARCHAR (20)  NULL,
    [serieF]          VARCHAR (10)  NULL,
    [nrF]             VARCHAR (20)  NULL,
    [are_doc]         INT           NULL,
    [tip_document]    INT           NULL,
    [Introdus_manual] INT           NULL,
    [idplaja]         INT           NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Principal]
    ON [dbo].[D394]([data] ASC, [lm] ASC, [rand_decl] ASC, [denumire] ASC, [tip_partener] ASC, [tipop] ASC, [codtert] ASC, [cuiP] ASC, [cota_tva] ASC, [cod] ASC, [bun] ASC, [tip] ASC, [serieI] ASC, [nrI] ASC, [tip_document] ASC);

