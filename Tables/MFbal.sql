CREATE TABLE [dbo].[MFbal] (
    [Subunitate]     CHAR (9)   NOT NULL,
    [Locul_de_munca] CHAR (13)  NOT NULL,
    [Tip_balanta]    SMALLINT   NOT NULL,
    [Denumire]       CHAR (60)  NOT NULL,
    [Categoria_1]    FLOAT (53) NOT NULL,
    [Categoria_2]    FLOAT (53) NOT NULL,
    [Categoria_3]    FLOAT (53) NOT NULL,
    [Categoria_4]    FLOAT (53) NOT NULL,
    [Categoria_5]    FLOAT (53) NOT NULL,
    [Categoria_6]    FLOAT (53) NOT NULL,
    [Categoria_7]    FLOAT (53) NOT NULL,
    [Categoria_8]    FLOAT (53) NOT NULL,
    [Categoria_9]    FLOAT (53) NOT NULL,
    [Total]          FLOAT (53) NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Cheie]
    ON [dbo].[MFbal]([Subunitate] ASC, [Locul_de_munca] ASC, [Tip_balanta] ASC);


GO
CREATE NONCLUSTERED INDEX [Pt_bal_lm]
    ON [dbo].[MFbal]([Subunitate] ASC, [Locul_de_munca] ASC, [Tip_balanta] ASC);


GO
CREATE NONCLUSTERED INDEX [Pentru_bal_un]
    ON [dbo].[MFbal]([Subunitate] ASC, [Tip_balanta] ASC);

