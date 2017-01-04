﻿CREATE TABLE [dbo].[personal022011] (
    [Marca]                         CHAR (6)   NOT NULL,
    [Nume]                          CHAR (50)  NOT NULL,
    [Cod_functie]                   CHAR (6)   NOT NULL,
    [Loc_de_munca]                  CHAR (9)   NOT NULL,
    [Loc_de_munca_din_pontaj]       BIT        NOT NULL,
    [Categoria_salarizare]          CHAR (4)   NOT NULL,
    [Grupa_de_munca]                CHAR (1)   NOT NULL,
    [Salar_de_incadrare]            FLOAT (53) NOT NULL,
    [Salar_de_baza]                 FLOAT (53) NOT NULL,
    [Salar_orar]                    FLOAT (53) NOT NULL,
    [Tip_salarizare]                CHAR (1)   NOT NULL,
    [Tip_impozitare]                CHAR (1)   NOT NULL,
    [Pensie_suplimentara]           SMALLINT   NOT NULL,
    [Somaj_1]                       SMALLINT   NOT NULL,
    [As_sanatate]                   SMALLINT   NOT NULL,
    [Indemnizatia_de_conducere]     FLOAT (53) NOT NULL,
    [Spor_vechime]                  REAL       NOT NULL,
    [Spor_de_noapte]                REAL       NOT NULL,
    [Spor_sistematic_peste_program] REAL       NOT NULL,
    [Spor_de_functie_suplimentara]  FLOAT (53) NOT NULL,
    [Spor_specific]                 FLOAT (53) NOT NULL,
    [Spor_conditii_1]               FLOAT (53) NOT NULL,
    [Spor_conditii_2]               FLOAT (53) NOT NULL,
    [Spor_conditii_3]               FLOAT (53) NOT NULL,
    [Spor_conditii_4]               FLOAT (53) NOT NULL,
    [Spor_conditii_5]               FLOAT (53) NOT NULL,
    [Spor_conditii_6]               FLOAT (53) NOT NULL,
    [Sindicalist]                   BIT        NOT NULL,
    [Salar_lunar_de_baza]           FLOAT (53) NOT NULL,
    [Zile_concediu_de_odihna_an]    SMALLINT   NOT NULL,
    [Zile_concediu_efectuat_an]     SMALLINT   NOT NULL,
    [Zile_absente_an]               SMALLINT   NOT NULL,
    [Vechime_totala]                DATETIME   NOT NULL,
    [Data_angajarii_in_unitate]     DATETIME   NOT NULL,
    [Banca]                         CHAR (25)  NOT NULL,
    [Cont_in_banca]                 CHAR (25)  NOT NULL,
    [Poza]                          IMAGE      NULL,
    [Sex]                           BIT        NOT NULL,
    [Data_nasterii]                 DATETIME   NOT NULL,
    [Cod_numeric_personal]          CHAR (13)  NOT NULL,
    [Studii]                        CHAR (10)  NOT NULL,
    [Profesia]                      CHAR (10)  NOT NULL,
    [Adresa]                        CHAR (30)  NOT NULL,
    [Copii]                         CHAR (30)  NOT NULL,
    [Loc_ramas_vacant]              BIT        NOT NULL,
    [Localitate]                    CHAR (30)  NOT NULL,
    [Judet]                         CHAR (15)  NOT NULL,
    [Strada]                        CHAR (25)  NOT NULL,
    [Numar]                         CHAR (5)   NOT NULL,
    [Cod_postal]                    INT        NOT NULL,
    [Bloc]                          CHAR (10)  NOT NULL,
    [Scara]                         CHAR (2)   NOT NULL,
    [Etaj]                          CHAR (2)   NOT NULL,
    [Apartament]                    CHAR (5)   NOT NULL,
    [Sector]                        SMALLINT   NOT NULL,
    [Mod_angajare]                  CHAR (1)   NOT NULL,
    [Data_plec]                     DATETIME   NOT NULL,
    [Tip_colab]                     CHAR (3)   NOT NULL,
    [grad_invalid]                  CHAR (1)   NOT NULL,
    [coef_invalid]                  REAL       NOT NULL,
    [alte_surse]                    BIT        NOT NULL
);

