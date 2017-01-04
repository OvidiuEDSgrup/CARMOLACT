CREATE TABLE [dbo].[deconttva] (
    [Data]               DATETIME    NULL,
    [Capitol]            CHAR (2)    NULL,
    [Rand_decont]        CHAR (10)   NULL,
    [Denumire_indicator] CHAR (500)  NULL,
    [Valoare]            FLOAT (53)  NULL,
    [TVA]                FLOAT (53)  NULL,
    [Modif_valoare]      INT         NULL,
    [Modif_tva]          INT         NULL,
    [Introdus_manual]    INT         NULL,
    [Loc_de_munca]       VARCHAR (9) NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Principal]
    ON [dbo].[deconttva]([Data] ASC, [Capitol] ASC, [Rand_decont] ASC, [Loc_de_munca] ASC);

