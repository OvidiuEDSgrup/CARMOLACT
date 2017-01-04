CREATE TABLE [dbo].[zoneliv] (
    [codZona]  VARCHAR (20)  NOT NULL,
    [denumire] VARCHAR (200) NULL,
    [detalii]  XML           NULL,
    CONSTRAINT [pkZone] PRIMARY KEY CLUSTERED ([codZona] ASC)
);

