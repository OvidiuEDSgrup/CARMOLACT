CREATE TABLE [dbo].[GrilaPretCantLapte] (
    [Tip]        CHAR (1)   NOT NULL,
    [Perioada]   CHAR (1)   NOT NULL,
    [Tip_lapte]  CHAR (20)  NOT NULL,
    [Limita_inf] FLOAT (53) NOT NULL,
    [Limita_sup] FLOAT (53) NOT NULL,
    [Bonus]      FLOAT (53) NOT NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Unic]
    ON [dbo].[GrilaPretCantLapte]([Tip] ASC, [Tip_lapte] ASC, [Limita_inf] ASC, [Limita_sup] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Bonus]
    ON [dbo].[GrilaPretCantLapte]([Tip] ASC, [Tip_lapte] ASC, [Bonus] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Limita_inf]
    ON [dbo].[GrilaPretCantLapte]([Tip] ASC, [Tip_lapte] ASC, [Limita_inf] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Limita_sup]
    ON [dbo].[GrilaPretCantLapte]([Tip] ASC, [Tip_lapte] ASC, [Limita_sup] ASC);

