CREATE TABLE [dbo].[LegaturiStornare] (
    [idSursa]  INT NULL,
    [idStorno] INT NULL,
    CONSTRAINT [FK__LegaturiS__idSto__3CFBFCE4] FOREIGN KEY ([idStorno]) REFERENCES [dbo].[pozdoc] ([idPozDoc]),
    CONSTRAINT [FK__LegaturiS__idSur__3C07D8AB] FOREIGN KEY ([idSursa]) REFERENCES [dbo].[pozdoc] ([idPozDoc])
);

