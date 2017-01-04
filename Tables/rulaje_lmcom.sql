CREATE TABLE [dbo].[rulaje_lmcom] (
    [Subunitate]   CHAR (9)   NOT NULL,
    [Cont]         CHAR (13)  NOT NULL,
    [Valuta]       CHAR (3)   NOT NULL,
    [Data]         DATETIME   NOT NULL,
    [Loc_de_munca] CHAR (9)   NOT NULL,
    [Comanda]      CHAR (20)  NOT NULL,
    [Rulaj_debit]  FLOAT (53) NOT NULL,
    [Rulaj_credit] FLOAT (53) NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Principal]
    ON [dbo].[rulaje_lmcom]([Subunitate] ASC, [Cont] ASC, [Valuta] ASC, [Data] ASC, [Loc_de_munca] ASC, [Comanda] ASC);


GO
CREATE NONCLUSTERED INDEX [Pentru_inchidere]
    ON [dbo].[rulaje_lmcom]([Subunitate] ASC, [Data] ASC, [Cont] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Valuta_data_cont]
    ON [dbo].[rulaje_lmcom]([Subunitate] ASC, [Valuta] ASC, [Data] ASC, [Cont] ASC, [Loc_de_munca] ASC, [Comanda] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Valuta_cont_data]
    ON [dbo].[rulaje_lmcom]([Subunitate] ASC, [Valuta] ASC, [Cont] ASC, [Data] ASC, [Loc_de_munca] ASC, [Comanda] ASC);

