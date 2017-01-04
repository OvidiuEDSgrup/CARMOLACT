﻿CREATE TABLE [dbo].[AL_Producatori] (
    [id_prod]          INT             IDENTITY (1, 1) NOT NULL,
    [cod_prod]         VARCHAR (9)     NOT NULL,
    [denumire]         VARCHAR (50)    NOT NULL,
    [initiala_tata]    CHAR (1)        NOT NULL,
    [CNP_CUI]          VARCHAR (15)    NOT NULL,
    [serie_BI]         CHAR (2)        NOT NULL,
    [nr_BI]            CHAR (7)        NOT NULL,
    [elib_BI]          VARCHAR (20)    NOT NULL,
    [cod_jud]          VARCHAR (3)     NULL,
    [judet]            VARCHAR (30)    NOT NULL,
    [cod_loc]          VARCHAR (8)     NULL,
    [localitate]       VARCHAR (30)    NOT NULL,
    [comuna]           VARCHAR (30)    NOT NULL,
    [sat]              VARCHAR (30)    NOT NULL,
    [strada]           VARCHAR (30)    NOT NULL,
    [nr_str]           VARCHAR (5)     NOT NULL,
    [nr_casa]          VARCHAR (10)    NOT NULL,
    [bloc]             VARCHAR (10)    NOT NULL,
    [scara]            VARCHAR (10)    NOT NULL,
    [etaj]             VARCHAR (10)    NOT NULL,
    [ap]               VARCHAR (5)     NOT NULL,
    [cod_exploatatie]  VARCHAR (15)    NOT NULL,
    [cota_actuala]     DECIMAL (12, 2) NOT NULL,
    [grad_actual]      DECIMAL (7, 3)  NOT NULL,
    [nr_contr]         VARCHAR (20)    NOT NULL,
    [data_contr]       DATETIME2 (0)   NOT NULL,
    [valabil_contr]    DATETIME2 (0)   NOT NULL,
    [cant_contr]       DECIMAL (12, 2) NOT NULL,
    [nr_vaci]          SMALLINT        NOT NULL,
    [grupa]            CHAR (1)        NOT NULL,
    [pret]             DECIMAL (12, 2) NOT NULL,
    [bonus]            TINYINT         NOT NULL,
    [tip_pers]         CHAR (1)        NOT NULL,
    [subunit]          VARCHAR (9)     CONSTRAINT [DF_AL_Producatori_subunitate] DEFAULT ('1') NOT NULL,
    [tert]             VARCHAR (13)    NOT NULL,
    [reprezentant]     VARCHAR (30)    NOT NULL,
    [CNP_repr]         VARCHAR (13)    NOT NULL,
    [id_centru]        INT             NULL,
    [centru_colectare] VARCHAR (9)     NOT NULL,
    [loc_munca]        VARCHAR (9)     NOT NULL,
    [DACL]             TINYINT         NOT NULL,
    [tip_furnizor]     CHAR (1)        NOT NULL,
    [cont_banca]       VARCHAR (35)    NOT NULL,
    [banca]            VARCHAR (20)    NOT NULL,
    [data_operarii]    DATETIME2 (3)   NOT NULL,
    [operator]         VARCHAR (10)    NOT NULL,
    CONSTRAINT [PK_AL_Producatori] PRIMARY KEY CLUSTERED ([id_prod] ASC)
);


GO
CREATE NONCLUSTERED INDEX [Denumire]
    ON [dbo].[AL_Producatori]([denumire] ASC);

