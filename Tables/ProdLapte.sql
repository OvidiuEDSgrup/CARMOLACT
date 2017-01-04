CREATE TABLE [dbo].[ProdLapte] (
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
    [Nr_contr]         CHAR (20)  DEFAULT ('') NOT NULL,
    [Data_contr]       DATETIME   DEFAULT (((1)/(1))/(1900)) NOT NULL,
    [Valabil_contr]    DATETIME   DEFAULT (((1)/(1))/(1900)) NOT NULL,
    [Cant_contr]       FLOAT (53) DEFAULT ((0.00)) NOT NULL,
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
    [Cont_banca]       CHAR (35)  CONSTRAINT [DF_ProdLapte_Cont_banca] DEFAULT ('') NOT NULL,
    [Banca]            CHAR (20)  CONSTRAINT [DF_ProdLapte_Banca] DEFAULT ('') NOT NULL,
    [Data_operarii]    DATETIME   NOT NULL,
    [Ora_operarii]     CHAR (6)   NOT NULL,
    [Utilizator]       CHAR (10)  NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Unic]
    ON [dbo].[ProdLapte]([Cod_producator] ASC);


GO
CREATE NONCLUSTERED INDEX [Denumire]
    ON [dbo].[ProdLapte]([Denumire] ASC);


GO
CREATE NONCLUSTERED INDEX [missing_index_81]
    ON [dbo].[ProdLapte]([CNP_CUI] ASC);


GO
CREATE NONCLUSTERED INDEX [missing_index_83]
    ON [dbo].[ProdLapte]([Cod_exploatatie] ASC);


GO
CREATE NONCLUSTERED INDEX [missing_index_3927]
    ON [dbo].[ProdLapte]([Nr_contr] ASC)
    INCLUDE([Cod_producator], [Denumire], [Initiala_tatalui], [Serie_buletin], [Nr_buletin], [Eliberat], [CNP_CUI], [Judet], [Localitate], [Comuna], [Sat], [Strada], [Nr_str], [Nr_casa], [Bloc], [Scara], [Etaj], [Ap], [Cod_exploatatie], [Cota_actuala], [Grad_actual], [Data_contr], [Valabil_contr], [Cant_contr], [Vaci], [Grupa], [Pret], [Bonus], [Tip_pers], [Tert], [Reprezentant], [CNP_repr], [Centru_colectare], [Loc_de_munca], [DACL], [Tip_furnizor], [Cont_banca], [Banca], [Data_operarii], [Ora_operarii], [Utilizator]);


GO
CREATE NONCLUSTERED INDEX [missing_index_1940]
    ON [dbo].[ProdLapte]([CNP_CUI] ASC)
    INCLUDE([Cod_producator], [Denumire], [Initiala_tatalui], [Serie_buletin], [Nr_buletin], [Eliberat], [Judet], [Localitate], [Comuna], [Sat], [Strada], [Nr_str], [Nr_casa], [Bloc], [Scara], [Etaj], [Ap], [Cod_exploatatie], [Cota_actuala], [Grad_actual], [Nr_contr], [Data_contr], [Valabil_contr], [Cant_contr], [Vaci], [Grupa], [Pret], [Bonus], [Tip_pers], [Tert], [Reprezentant], [CNP_repr], [Centru_colectare], [Loc_de_munca], [DACL], [Tip_furnizor], [Cont_banca], [Banca], [Data_operarii], [Ora_operarii], [Utilizator]);


GO
CREATE NONCLUSTERED INDEX [missing_index_89]
    ON [dbo].[ProdLapte]([Denumire] ASC)
    INCLUDE([Cod_producator], [Initiala_tatalui], [Serie_buletin], [Nr_buletin], [Eliberat], [CNP_CUI], [Judet], [Localitate], [Comuna], [Sat], [Strada], [Nr_str], [Nr_casa], [Bloc], [Scara], [Etaj], [Ap], [Cod_exploatatie], [Cota_actuala], [Grad_actual], [Nr_contr], [Data_contr], [Valabil_contr], [Cant_contr], [Vaci], [Grupa], [Pret], [Bonus], [Tip_pers], [Tert], [Reprezentant], [CNP_repr], [Centru_colectare], [Loc_de_munca], [DACL], [Tip_furnizor], [Cont_banca], [Banca], [Data_operarii], [Ora_operarii], [Utilizator]);

