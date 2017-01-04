CREATE TABLE [dbo].[rute] (
    [codRuta]   VARCHAR (20)  NOT NULL,
    [denumire]  VARCHAR (200) NULL,
    [descriere] VARCHAR (500) NULL,
    [detalii]   XML           NULL,
    [codZona]   VARCHAR (20)  NULL,
    CONSTRAINT [pkRute] PRIMARY KEY CLUSTERED ([codRuta] ASC)
);


GO
CREATE NONCLUSTERED INDEX [denRute]
    ON [dbo].[rute]([denumire] ASC);


GO
CREATE NONCLUSTERED INDEX [denZone]
    ON [dbo].[rute]([denumire] ASC);

