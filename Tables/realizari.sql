CREATE TABLE [dbo].[realizari] (
    [id]         INT          IDENTITY (1, 1) NOT NULL,
    [codResursa] VARCHAR (20) NULL,
    [data]       DATETIME     NULL,
    [nrDoc]      VARCHAR (20) NULL,
    [detalii]    XML          NULL,
    [idResursa]  INT          NULL,
    [tip]        VARCHAR (2)  NULL,
    CONSTRAINT [PK_realizari] PRIMARY KEY CLUSTERED ([id] ASC) WITH (FILLFACTOR = 20),
    CONSTRAINT [FK_idResursaRealizari] FOREIGN KEY ([idResursa]) REFERENCES [dbo].[Resurse] ([id])
);


GO
CREATE NONCLUSTERED INDEX [princ]
    ON [dbo].[realizari]([codResursa] ASC, [data] ASC) WITH (FILLFACTOR = 20);

