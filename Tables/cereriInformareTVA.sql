CREATE TABLE [dbo].[cereriInformareTVA] (
    [data_ora]       DATETIME      NULL,
    [data_raportare] DATETIME      NULL,
    [tip]            VARCHAR (4)   NULL,
    [cui]            VARCHAR (20)  NULL,
    [is_tva]         INT           NULL,
    [is_tli]         INT           NULL,
    [adresa]         VARCHAR (200) NULL,
    [valid]          INT           NULL,
    [dela]           DATETIME      NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Principal]
    ON [dbo].[cereriInformareTVA]([data_raportare] ASC, [cui] ASC);

