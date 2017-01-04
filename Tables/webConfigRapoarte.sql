CREATE TABLE [dbo].[webConfigRapoarte] (
    [utilizator] CHAR (10)     NOT NULL,
    [caleRaport] VARCHAR (500) NOT NULL,
    CONSTRAINT [utilizator] PRIMARY KEY CLUSTERED ([utilizator] ASC, [caleRaport] ASC)
);

