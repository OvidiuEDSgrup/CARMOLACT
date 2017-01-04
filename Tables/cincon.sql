CREATE TABLE [dbo].[cincon] (
    [Subunitate]     CHAR (9)   NOT NULL,
    [Tip_document]   CHAR (2)   NOT NULL,
    [Numar_document] CHAR (13)  NOT NULL,
    [Data]           DATETIME   NOT NULL,
    [Cont_debitor]   CHAR (13)  NOT NULL,
    [Cont_creditor]  CHAR (13)  NOT NULL,
    [Suma]           FLOAT (53) NOT NULL,
    [Valuta]         CHAR (3)   NOT NULL,
    [Curs]           FLOAT (53) NOT NULL,
    [Suma_valuta]    FLOAT (53) NOT NULL,
    [Explicatii]     CHAR (50)  NOT NULL,
    [Utilizator]     CHAR (10)  NOT NULL,
    [Data_operarii]  DATETIME   NOT NULL,
    [Ora_operarii]   CHAR (6)   NOT NULL,
    [Loc_de_munca]   CHAR (9)   NOT NULL,
    [Comanda]        CHAR (20)  NOT NULL,
    [Tert]           CHAR (13)  NOT NULL,
    [Jurnal]         CHAR (3)   NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Sub_Tip_Numar_Data_Conturi]
    ON [dbo].[cincon]([Subunitate] ASC, [Tip_document] ASC, [Numar_document] ASC, [Data] ASC, [Cont_debitor] ASC, [Cont_creditor] ASC, [Loc_de_munca] ASC, [Comanda] ASC, [Explicatii] ASC);

