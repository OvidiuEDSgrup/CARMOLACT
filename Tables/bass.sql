﻿CREATE TABLE [dbo].[bass] (
    [Anul_lista]       SMALLINT   NOT NULL,
    [Luna_lista]       SMALLINT   NOT NULL,
    [Data_lichidarii]  DATETIME   NOT NULL,
    [Denumire_unitate] CHAR (29)  NOT NULL,
    [Cod_fiscal]       CHAR (10)  NOT NULL,
    [Cod_judet]        CHAR (3)   NOT NULL,
    [Nr_inreg]         INT        NOT NULL,
    [An_inreg]         SMALLINT   NOT NULL,
    [Nr_med_ang]       FLOAT (53) NOT NULL,
    [FS]               FLOAT (53) NOT NULL,
    [FSN]              FLOAT (53) NOT NULL,
    [FSD]              FLOAT (53) NOT NULL,
    [FSS]              FLOAT (53) NOT NULL,
    [CASS]             FLOAT (53) NOT NULL,
    [CASAN]            FLOAT (53) NOT NULL,
    [BASS]             FLOAT (53) NOT NULL,
    [CASS145]          FLOAT (53) NOT NULL,
    [CASVIR]           FLOAT (53) NOT NULL,
    [Nr_pag]           SMALLINT   NOT NULL,
    [Banca_1]          CHAR (16)  NOT NULL,
    [Filiala_1]        CHAR (16)  NOT NULL,
    [Ct1]              CHAR (35)  NOT NULL,
    [Banca_2]          CHAR (16)  NOT NULL,
    [Filiala_2]        CHAR (16)  NOT NULL,
    [Ct2]              CHAR (35)  NOT NULL,
    [Banca_3]          CHAR (16)  NOT NULL,
    [Filiala_3]        CHAR (16)  NOT NULL,
    [Ct3]              CHAR (35)  NOT NULL,
    [Banca_4]          CHAR (16)  NOT NULL,
    [Filiala_4]        CHAR (16)  NOT NULL,
    [Ct4]              CHAR (35)  NOT NULL,
    [Plus]             FLOAT (53) NOT NULL,
    [CAAMBP]           FLOAT (53) NOT NULL,
    [A_LOCA]           CHAR (21)  NOT NULL,
    [A_STR]            CHAR (21)  NOT NULL,
    [A_NR]             CHAR (7)   NOT NULL,
    [A_BL]             CHAR (5)   NOT NULL,
    [A_SC]             CHAR (4)   NOT NULL,
    [A_ET]             CHAR (2)   NOT NULL,
    [A_AP]             CHAR (4)   NOT NULL,
    [TELEFON]          FLOAT (53) NOT NULL,
    [A_JUD]            CHAR (3)   NOT NULL,
    [A_SECT]           SMALLINT   NOT NULL,
    [E_MAIL]           CHAR (45)  NOT NULL,
    [TIPD]             CHAR (1)   NOT NULL,
    [NRCAZB]           INT        NOT NULL,
    [NRCAZA]           INT        NOT NULL,
    [NRCAZP]           INT        NOT NULL,
    [NRCAZL]           INT        NOT NULL,
    [NRCAZI]           INT        NOT NULL,
    [NRCAZC]           INT        NOT NULL,
    [NRCAZD]           INT        NOT NULL,
    [NRCAZR]           INT        NOT NULL,
    [NRPPB]            INT        NOT NULL,
    [NRPPA]            INT        NOT NULL,
    [NRPPP]            INT        NOT NULL,
    [NRPPL]            INT        NOT NULL,
    [NRPPI]            INT        NOT NULL,
    [NRPPC]            INT        NOT NULL,
    [NRPPR]            INT        NOT NULL,
    [SUMAB]            FLOAT (53) NOT NULL,
    [SUMAA]            FLOAT (53) NOT NULL,
    [SUMAP]            FLOAT (53) NOT NULL,
    [SUMAL]            FLOAT (53) NOT NULL,
    [SUMAI]            FLOAT (53) NOT NULL,
    [SUMAC]            FLOAT (53) NOT NULL,
    [SUMAD]            FLOAT (53) NOT NULL,
    [SUMAR]            FLOAT (53) NOT NULL,
    [CODCAEN]          CHAR (4)   NOT NULL,
    [TPP]              INT        NOT NULL,
    [PCAMBP]           REAL       NOT NULL,
    [TPPA]             INT        NOT NULL,
    [CASS145A]         FLOAT (53) NOT NULL,
    [PFAAMBP]          FLOAT (53) NOT NULL,
    [NRCAZIT]          INT        NOT NULL,
    [NRCAZTT]          INT        NOT NULL,
    [NRCAZRT]          INT        NOT NULL,
    [NRCAZCC]          INT        NOT NULL,
    [NRPPIT]           INT        NOT NULL,
    [NRPPTT]           INT        NOT NULL,
    [NRPPRT]           INT        NOT NULL,
    [NRPPCC]           INT        NOT NULL,
    [SUMAIT]           FLOAT (53) NOT NULL,
    [SUMATT]           FLOAT (53) NOT NULL,
    [SUMART]           FLOAT (53) NOT NULL,
    [SUMACC]           FLOAT (53) NOT NULL,
    [FAMBPV]           FLOAT (53) NOT NULL,
    [DATORAT]          SMALLINT   NOT NULL,
    [TSUMAIT]          FLOAT (53) NOT NULL,
    [TSUMATT]          FLOAT (53) NOT NULL,
    [TSUMART]          FLOAT (53) NOT NULL,
    [TSUMACC]          FLOAT (53) NOT NULL,
    [TBASS]            FLOAT (53) NOT NULL,
    [TBASS_N]          FLOAT (53) NOT NULL,
    [TBASS_D]          FLOAT (53) NOT NULL,
    [TBASS_S]          FLOAT (53) NOT NULL,
    [CASAN_CM]         FLOAT (53) NOT NULL,
    [CONTR_CM]         FLOAT (53) NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Uniq]
    ON [dbo].[bass]([Anul_lista] ASC, [Luna_lista] ASC, [Cod_judet] ASC);

