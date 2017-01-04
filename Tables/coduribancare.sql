CREATE TABLE [dbo].[coduribancare] (
    [cod]      VARCHAR (20)  NOT NULL,
    [denumire] VARCHAR (100) NULL,
    [swift]    VARCHAR (20)  NULL,
    CONSTRAINT [PK_coduribancare_cod] PRIMARY KEY CLUSTERED ([cod] ASC)
);

