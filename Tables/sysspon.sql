﻿CREATE TABLE [dbo].[sysspon] (
    [Host_id]                        VARCHAR (10)  NULL,
    [Host_name]                      VARCHAR (30)  NULL,
    [Aplicatia]                      VARCHAR (30)  NULL,
    [Data_operarii]                  DATETIME2 (3) NULL,
    [Utilizator]                     VARCHAR (10)  NULL,
    [Tip_act]                        VARCHAR (1)   NULL,
    [Data]                           DATETIME2 (3) NULL,
    [Marca]                          VARCHAR (6)   NULL,
    [Numar_curent]                   SMALLINT      NOT NULL,
    [Loc_de_munca]                   VARCHAR (9)   NULL,
    [Loc_munca_pentru_stat_de_plata] BIT           NOT NULL,
    [Tip_salarizare]                 VARCHAR (1)   NULL,
    [Regim_de_lucru]                 REAL          NOT NULL,
    [Salar_orar]                     FLOAT (53)    NOT NULL,
    [Ore_lucrate]                    SMALLINT      NOT NULL,
    [Ore_regie]                      SMALLINT      NOT NULL,
    [Ore_acord]                      SMALLINT      NOT NULL,
    [Ore_suplimentare_1]             SMALLINT      NOT NULL,
    [Ore_suplimentare_2]             SMALLINT      NOT NULL,
    [Ore_suplimentare_3]             SMALLINT      NOT NULL,
    [Ore_suplimentare_4]             SMALLINT      NOT NULL,
    [Ore_spor_100]                   SMALLINT      NOT NULL,
    [Ore_de_noapte]                  SMALLINT      NOT NULL,
    [Ore_intrerupere_tehnologica]    SMALLINT      NOT NULL,
    [Ore_concediu_de_odihna]         SMALLINT      NOT NULL,
    [Ore_concediu_medical]           SMALLINT      NOT NULL,
    [Ore_invoiri]                    SMALLINT      NOT NULL,
    [Ore_nemotivate]                 SMALLINT      NOT NULL,
    [Ore_obligatii_cetatenesti]      SMALLINT      NOT NULL,
    [Ore_concediu_fara_salar]        SMALLINT      NOT NULL,
    [Ore_donare_sange]               SMALLINT      NOT NULL,
    [Salar_categoria_lucrarii]       FLOAT (53)    NOT NULL,
    [Coeficient_acord]               FLOAT (53)    NOT NULL,
    [Realizat]                       FLOAT (53)    NOT NULL,
    [Coeficient_de_timp]             FLOAT (53)    NOT NULL,
    [Ore_realizate_acord]            REAL          NOT NULL,
    [Sistematic_peste_program]       REAL          NOT NULL,
    [Ore_sistematic_peste_program]   SMALLINT      NOT NULL,
    [Spor_specific]                  FLOAT (53)    NOT NULL,
    [Spor_conditii_1]                FLOAT (53)    NOT NULL,
    [Spor_conditii_2]                FLOAT (53)    NOT NULL,
    [Spor_conditii_3]                FLOAT (53)    NOT NULL,
    [Spor_conditii_4]                FLOAT (53)    NOT NULL,
    [Spor_conditii_5]                FLOAT (53)    NOT NULL,
    [Spor_conditii_6]                FLOAT (53)    NOT NULL,
    [Ore__cond_1]                    SMALLINT      NOT NULL,
    [Ore__cond_2]                    SMALLINT      NOT NULL,
    [Ore__cond_3]                    SMALLINT      NOT NULL,
    [Ore__cond_4]                    SMALLINT      NOT NULL,
    [Ore__cond_5]                    SMALLINT      NOT NULL,
    [Ore__cond_6]                    REAL          NOT NULL,
    [Grupa_de_munca]                 VARCHAR (1)   NULL,
    [Ore]                            SMALLINT      NOT NULL,
    [Spor_cond_7]                    FLOAT (53)    NOT NULL,
    [Spor_cond_8]                    FLOAT (53)    NOT NULL,
    [Spor_cond_9]                    FLOAT (53)    NOT NULL,
    [Spor_cond_10]                   FLOAT (53)    NOT NULL
) ON [SYSS];

