﻿CREATE TABLE [dbo].[webConfigACRapoarte] (
    [caleraport]  VARCHAR (500) NULL,
    [ordine]      INT           NULL,
    [expresie]    VARCHAR (200) NULL,
    [proceduraAC] VARCHAR (200) NULL,
    [id]          INT           IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [principal_webConfigACRapoarte] PRIMARY KEY CLUSTERED ([id] ASC)
);

