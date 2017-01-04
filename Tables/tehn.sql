CREATE TABLE [dbo].[tehn] (
    [Cod_tehn]      CHAR (20)  NOT NULL,
    [Denumire]      CHAR (80)  NOT NULL,
    [Tip_tehn]      CHAR (1)   NOT NULL,
    [Utilizator]    CHAR (10)  NOT NULL,
    [Data_operarii] DATETIME   NOT NULL,
    [Ora_operarii]  CHAR (6)   NOT NULL,
    [Data1]         DATETIME   NOT NULL,
    [Data2]         DATETIME   NOT NULL,
    [Alfa1]         CHAR (20)  NOT NULL,
    [Alfa2]         CHAR (20)  NOT NULL,
    [Alfa3]         CHAR (20)  NOT NULL,
    [Alfa4]         CHAR (20)  NOT NULL,
    [Alfa5]         CHAR (20)  NOT NULL,
    [Val1]          FLOAT (53) NOT NULL,
    [Val2]          FLOAT (53) NOT NULL,
    [Val3]          FLOAT (53) NOT NULL,
    [Val4]          FLOAT (53) NOT NULL,
    [Val5]          FLOAT (53) NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [tehn1]
    ON [dbo].[tehn]([Cod_tehn] ASC);


GO
CREATE NONCLUSTERED INDEX [tehn2]
    ON [dbo].[tehn]([Denumire] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [tehn3]
    ON [dbo].[tehn]([Tip_tehn] ASC, [Cod_tehn] ASC);


GO
CREATE NONCLUSTERED INDEX [tehn4]
    ON [dbo].[tehn]([Data1] ASC);


GO
CREATE NONCLUSTERED INDEX [tehn5]
    ON [dbo].[tehn]([Data2] ASC);

