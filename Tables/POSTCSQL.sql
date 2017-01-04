CREATE TABLE [dbo].[POSTCSQL] (
    [Pivot1]                CHAR (15)  NOT NULL,
    [Pivot2]                CHAR (15)  NOT NULL,
    [Tip_inregistrare]      CHAR (2)   NOT NULL,
    [Multiplicare_zecimala] SMALLINT   NOT NULL,
    [Articol_1]             FLOAT (53) NOT NULL,
    [Articol_2]             FLOAT (53) NOT NULL,
    [Articol_3]             FLOAT (53) NOT NULL,
    [Articol_4]             FLOAT (53) NOT NULL,
    [Articol_5]             FLOAT (53) NOT NULL,
    [Articol_6]             FLOAT (53) NOT NULL,
    [Articol_7]             FLOAT (53) NOT NULL,
    [Articol_8]             FLOAT (53) NOT NULL,
    [Articol_9]             FLOAT (53) NOT NULL,
    [Articol_10]            FLOAT (53) NOT NULL,
    [Articol_11]            FLOAT (53) NOT NULL,
    [Articol_12]            FLOAT (53) NOT NULL,
    [Articol_13]            FLOAT (53) NOT NULL,
    [Articol_14]            FLOAT (53) NOT NULL,
    [Articol_15]            FLOAT (53) NOT NULL,
    [Articol_16]            FLOAT (53) NOT NULL,
    [Articol_17]            FLOAT (53) NOT NULL,
    [Articol_18]            FLOAT (53) NOT NULL,
    [Articol_19]            FLOAT (53) NOT NULL,
    [Articol_20]            FLOAT (53) NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Principal]
    ON [dbo].[POSTCSQL]([Multiplicare_zecimala] ASC, [Pivot1] ASC, [Pivot2] ASC, [Tip_inregistrare] ASC);

