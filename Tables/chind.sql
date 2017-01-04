CREATE TABLE [dbo].[chind] (
    [Subunitate]            CHAR (9)   NOT NULL,
    [Tip_document]          CHAR (2)   NOT NULL,
    [Numar_document]        CHAR (8)   NOT NULL,
    [Data]                  DATETIME   NOT NULL,
    [Suma]                  FLOAT (53) NOT NULL,
    [Explicatii]            CHAR (50)  NOT NULL,
    [Loc_de_munca]          CHAR (9)   NOT NULL,
    [Comanda]               CHAR (13)  NOT NULL,
    [Articol_de_calculatie] CHAR (9)   NOT NULL,
    [Cont_ch_sursa]         CHAR (13)  NOT NULL,
    [Loc_de_munca_sursa]    CHAR (9)   NOT NULL,
    [Comanda_sursa]         CHAR (13)  NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Pentru_costuri]
    ON [dbo].[chind]([Subunitate] ASC, [Data] ASC, [Loc_de_munca] ASC, [Comanda] ASC, [Tip_document] ASC, [Numar_document] ASC, [Cont_ch_sursa] ASC, [Loc_de_munca_sursa] ASC, [Comanda_sursa] ASC);

