CREATE TABLE [dbo].[ProdDACLapte] (
    [Cod_producator]   CHAR (9)   NOT NULL,
    [Denumire]         CHAR (50)  NOT NULL,
    [Initiala_tatalui] CHAR (2)   NOT NULL,
    [Serie_buletin]    CHAR (2)   NOT NULL,
    [Nr_buletin]       CHAR (7)   NOT NULL,
    [Eliberat]         CHAR (20)  NOT NULL,
    [CNP_CUI]          CHAR (15)  NOT NULL,
    [Judet]            CHAR (30)  NOT NULL,
    [Localitate]       CHAR (30)  NOT NULL,
    [Comuna]           CHAR (30)  NOT NULL,
    [Sat]              CHAR (30)  NOT NULL,
    [Strada]           CHAR (30)  NOT NULL,
    [Nr_str]           CHAR (5)   NOT NULL,
    [Nr_casa]          CHAR (10)  NOT NULL,
    [Bloc]             CHAR (10)  NOT NULL,
    [Scara]            CHAR (10)  NOT NULL,
    [Etaj]             CHAR (10)  NOT NULL,
    [Ap]               CHAR (5)   NOT NULL,
    [Cod_exploatatie]  CHAR (15)  NOT NULL,
    [Cota_actuala]     FLOAT (53) NOT NULL,
    [Grad_actual]      FLOAT (53) NOT NULL,
    [Vaci]             INT        NOT NULL,
    [Grupa]            CHAR (1)   NOT NULL,
    [Pret]             FLOAT (53) NOT NULL,
    [Bonus]            BIT        NOT NULL,
    [Tip_pers]         CHAR (1)   NOT NULL,
    [Tert]             CHAR (13)  NOT NULL,
    [Reprezentant]     CHAR (30)  NOT NULL,
    [CNP_repr]         CHAR (13)  NOT NULL,
    [Centru_colectare] CHAR (9)   NOT NULL,
    [Loc_de_munca]     CHAR (9)   NOT NULL,
    [DACL]             BIT        NOT NULL,
    [Tip_furnizor]     CHAR (1)   NOT NULL,
    [Data_operarii]    DATETIME   NOT NULL,
    [Ora_operarii]     CHAR (6)   NOT NULL,
    [Utilizator]       CHAR (10)  NOT NULL,
    [Regiunea]         CHAR (30)  NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Unic]
    ON [dbo].[ProdDACLapte]([Regiunea] ASC, [Cod_producator] ASC);


GO
CREATE NONCLUSTERED INDEX [Denumire]
    ON [dbo].[ProdDACLapte]([Denumire] ASC);


GO
CREATE NONCLUSTERED INDEX [missing_index_91]
    ON [dbo].[ProdDACLapte]([Cod_exploatatie] ASC);

