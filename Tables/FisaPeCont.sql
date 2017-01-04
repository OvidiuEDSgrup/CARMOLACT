CREATE TABLE [dbo].[FisaPeCont] (
    [Data]    DATETIME   NOT NULL,
    [Tip]     CHAR (1)   NOT NULL,
    [LM]      CHAR (9)   NOT NULL,
    [Comanda] CHAR (13)  NOT NULL,
    [Cont]    CHAR (13)  NOT NULL,
    [Suma]    FLOAT (53) NOT NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Prin]
    ON [dbo].[FisaPeCont]([Data] ASC, [Tip] ASC, [LM] ASC, [Comanda] ASC, [Cont] ASC);

