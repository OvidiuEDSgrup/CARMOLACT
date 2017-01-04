CREATE TABLE [dbo].[rulaje_nu_ma_sterge] (
    [Subunitate]   CHAR (9)   NOT NULL,
    [Cont]         CHAR (13)  NOT NULL,
    [Valuta]       CHAR (3)   NOT NULL,
    [Data]         DATETIME   NOT NULL,
    [Rulaj_debit]  FLOAT (53) NOT NULL,
    [Rulaj_credit] FLOAT (53) NOT NULL,
    [Loc_de_munca] NCHAR (9)  NULL
);

