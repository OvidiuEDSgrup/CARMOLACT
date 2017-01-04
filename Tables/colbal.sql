CREATE TABLE [dbo].[colbal] (
    [Nr_crt]  SMALLINT NOT NULL,
    [Coloana] SMALLINT NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [coloana]
    ON [dbo].[colbal]([Coloana] ASC);

