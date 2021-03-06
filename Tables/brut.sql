﻿CREATE TABLE [dbo].[brut] (
    [Data]                          DATETIME   NOT NULL,
    [Marca]                         CHAR (6)   NOT NULL,
    [Loc_de_munca]                  CHAR (9)   NOT NULL,
    [Loc_munca_pt_stat_de_plata]    BIT        NOT NULL,
    [Total_ore_lucrate]             SMALLINT   NOT NULL,
    [Ore_lucrate__regie]            SMALLINT   NOT NULL,
    [Realizat__regie]               FLOAT (53) NOT NULL,
    [Ore_lucrate_acord]             SMALLINT   NOT NULL,
    [Realizat_acord]                FLOAT (53) NOT NULL,
    [Ore_suplimentare_1]            SMALLINT   NOT NULL,
    [Indemnizatie_ore_supl_1]       FLOAT (53) NOT NULL,
    [Ore_suplimentare_2]            SMALLINT   NOT NULL,
    [Indemnizatie_ore_supl_2]       FLOAT (53) NOT NULL,
    [Ore_suplimentare_3]            SMALLINT   NOT NULL,
    [Indemnizatie_ore_supl_3]       FLOAT (53) NOT NULL,
    [Ore_suplimentare_4]            SMALLINT   NOT NULL,
    [Indemnizatie_ore_supl_4]       FLOAT (53) NOT NULL,
    [Ore_spor_100]                  SMALLINT   NOT NULL,
    [Indemnizatie_ore_spor_100]     FLOAT (53) NOT NULL,
    [Ore_de_noapte]                 SMALLINT   NOT NULL,
    [Ind_ore_de_noapte]             FLOAT (53) NOT NULL,
    [Ore_lucrate_regim_normal]      SMALLINT   NOT NULL,
    [Ind_regim_normal]              FLOAT (53) NOT NULL,
    [Ore_intrerupere_tehnologica]   SMALLINT   NOT NULL,
    [Ind_intrerupere_tehnologica]   FLOAT (53) NOT NULL,
    [Ore_obligatii_cetatenesti]     SMALLINT   NOT NULL,
    [Ind_obligatii_cetatenesti]     FLOAT (53) NOT NULL,
    [Ore_concediu_fara_salar]       SMALLINT   NOT NULL,
    [Ind_concediu_fara_salar]       FLOAT (53) NOT NULL,
    [Ore_concediu_de_odihna]        SMALLINT   NOT NULL,
    [Ind_concediu_de_odihna]        FLOAT (53) NOT NULL,
    [Ore_concediu_medical]          SMALLINT   NOT NULL,
    [Ind_c_medical_unitate]         FLOAT (53) NOT NULL,
    [Ind_c_medical_CAS]             FLOAT (53) NOT NULL,
    [Ore_invoiri]                   SMALLINT   NOT NULL,
    [Ind_invoiri]                   FLOAT (53) NOT NULL,
    [Ore_nemotivate]                SMALLINT   NOT NULL,
    [Ind_nemotivate]                FLOAT (53) NOT NULL,
    [Salar_categoria_lucrarii]      FLOAT (53) NOT NULL,
    [CMCAS]                         FLOAT (53) NOT NULL,
    [CMunitate]                     FLOAT (53) NOT NULL,
    [CO]                            FLOAT (53) NOT NULL,
    [Restituiri]                    FLOAT (53) NOT NULL,
    [Diminuari]                     FLOAT (53) NOT NULL,
    [Suma_impozabila]               FLOAT (53) NOT NULL,
    [Premiu]                        FLOAT (53) NOT NULL,
    [Diurna]                        FLOAT (53) NOT NULL,
    [Cons_admin]                    FLOAT (53) NOT NULL,
    [Sp_salar_realizat]             FLOAT (53) NOT NULL,
    [Suma_imp_separat]              FLOAT (53) NOT NULL,
    [Spor_vechime]                  FLOAT (53) NOT NULL,
    [Spor_de_noapte]                FLOAT (53) NOT NULL,
    [Spor_sistematic_peste_program] FLOAT (53) NOT NULL,
    [Spor_de_functie_suplimentara]  FLOAT (53) NOT NULL,
    [Spor_specific]                 FLOAT (53) NOT NULL,
    [Spor_cond_1]                   FLOAT (53) NOT NULL,
    [Spor_cond_2]                   FLOAT (53) NOT NULL,
    [Spor_cond_3]                   FLOAT (53) NOT NULL,
    [Spor_cond_4]                   FLOAT (53) NOT NULL,
    [Spor_cond_5]                   FLOAT (53) NOT NULL,
    [Spor_cond_6]                   FLOAT (53) NOT NULL,
    [Compensatie]                   FLOAT (53) NOT NULL,
    [VENIT_TOTAL]                   FLOAT (53) NOT NULL,
    [Salar_orar]                    FLOAT (53) NOT NULL,
    [Venit_cond_normale]            FLOAT (53) NOT NULL,
    [Venit_cond_deosebite]          FLOAT (53) NOT NULL,
    [Venit_cond_speciale]           FLOAT (53) NOT NULL,
    [Spor_cond_7]                   FLOAT (53) NOT NULL,
    [Spor_cond_8]                   FLOAT (53) NOT NULL,
    [Spor_cond_9]                   FLOAT (53) NOT NULL,
    [Spor_cond_10]                  FLOAT (53) NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Data_Marca_Locm]
    ON [dbo].[brut]([Data] ASC, [Marca] ASC, [Loc_de_munca] ASC);


GO
CREATE NONCLUSTERED INDEX [Marca]
    ON [dbo].[brut]([Marca] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Marca_Data_Locm]
    ON [dbo].[brut]([Marca] ASC, [Data] ASC, [Loc_de_munca] ASC);

