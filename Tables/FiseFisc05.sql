﻿CREATE TABLE [dbo].[FiseFisc05] (
    [AN]         SMALLINT   NOT NULL,
    [VERSIUNE]   SMALLINT   NOT NULL,
    [MARCA]      CHAR (6)   NOT NULL,
    [TIP]        SMALLINT   NOT NULL,
    [Cod]        FLOAT (53) NOT NULL,
    [Denumire]   CHAR (200) NOT NULL,
    [Adresa]     CHAR (200) NOT NULL,
    [Rectif]     CHAR (1)   NOT NULL,
    [MISDIPL]    CHAR (1)   NOT NULL,
    [TV1]        CHAR (1)   NOT NULL,
    [TV2]        CHAR (1)   NOT NULL,
    [TV3]        CHAR (1)   NOT NULL,
    [TV4]        CHAR (1)   NOT NULL,
    [TV5]        CHAR (1)   NOT NULL,
    [TV6]        CHAR (1)   NOT NULL,
    [TV7]        CHAR (1)   NOT NULL,
    [DATA_ANGAJ] DATETIME   NOT NULL,
    [DATA_INCET] DATETIME   NOT NULL,
    [CNP_1]      FLOAT (53) NOT NULL,
    [L1_1]       CHAR (1)   NOT NULL,
    [L2_1]       CHAR (1)   NOT NULL,
    [L3_1]       CHAR (1)   NOT NULL,
    [L4_1]       CHAR (1)   NOT NULL,
    [L5_1]       CHAR (1)   NOT NULL,
    [L6_1]       CHAR (1)   NOT NULL,
    [L7_1]       CHAR (1)   NOT NULL,
    [L8_1]       CHAR (1)   NOT NULL,
    [L9_1]       CHAR (1)   NOT NULL,
    [L10_1]      CHAR (1)   NOT NULL,
    [L11_1]      CHAR (1)   NOT NULL,
    [L12_1]      CHAR (1)   NOT NULL,
    [CNP_2]      FLOAT (53) NOT NULL,
    [L1_2]       CHAR (1)   NOT NULL,
    [L2_2]       CHAR (1)   NOT NULL,
    [L3_2]       CHAR (1)   NOT NULL,
    [L4_2]       CHAR (1)   NOT NULL,
    [L5_2]       CHAR (1)   NOT NULL,
    [L6_2]       CHAR (1)   NOT NULL,
    [L7_2]       CHAR (1)   NOT NULL,
    [L8_2]       CHAR (1)   NOT NULL,
    [L9_2]       CHAR (1)   NOT NULL,
    [L10_2]      CHAR (1)   NOT NULL,
    [L11_2]      CHAR (1)   NOT NULL,
    [L12_2]      CHAR (1)   NOT NULL,
    [CNP_3]      FLOAT (53) NOT NULL,
    [L1_3]       CHAR (1)   NOT NULL,
    [L2_3]       CHAR (1)   NOT NULL,
    [L3_3]       CHAR (1)   NOT NULL,
    [L4_3]       CHAR (1)   NOT NULL,
    [L5_3]       CHAR (1)   NOT NULL,
    [L6_3]       CHAR (1)   NOT NULL,
    [L7_3]       CHAR (1)   NOT NULL,
    [L8_3]       CHAR (1)   NOT NULL,
    [L9_3]       CHAR (1)   NOT NULL,
    [L10_3]      CHAR (1)   NOT NULL,
    [L11_3]      CHAR (1)   NOT NULL,
    [L12_3]      CHAR (1)   NOT NULL,
    [CNP_4]      FLOAT (53) NOT NULL,
    [L1_4]       CHAR (1)   NOT NULL,
    [L2_4]       CHAR (1)   NOT NULL,
    [L3_4]       CHAR (1)   NOT NULL,
    [L4_4]       CHAR (1)   NOT NULL,
    [L5_4]       CHAR (1)   NOT NULL,
    [L6_4]       CHAR (1)   NOT NULL,
    [L7_4]       CHAR (1)   NOT NULL,
    [L8_4]       CHAR (1)   NOT NULL,
    [L9_4]       CHAR (1)   NOT NULL,
    [L10_4]      CHAR (1)   NOT NULL,
    [L11_4]      CHAR (1)   NOT NULL,
    [L12_4]      CHAR (1)   NOT NULL,
    [CNP_5]      FLOAT (53) NOT NULL,
    [L1_5]       CHAR (1)   NOT NULL,
    [L2_5]       CHAR (1)   NOT NULL,
    [L3_5]       CHAR (1)   NOT NULL,
    [L4_5]       CHAR (1)   NOT NULL,
    [L5_5]       CHAR (1)   NOT NULL,
    [L6_5]       CHAR (1)   NOT NULL,
    [L7_5]       CHAR (1)   NOT NULL,
    [L8_5]       CHAR (1)   NOT NULL,
    [L9_5]       CHAR (1)   NOT NULL,
    [L10_5]      CHAR (1)   NOT NULL,
    [L11_5]      CHAR (1)   NOT NULL,
    [L12_5]      CHAR (1)   NOT NULL,
    [CNP_6]      FLOAT (53) NOT NULL,
    [L1_6]       CHAR (1)   NOT NULL,
    [L2_6]       CHAR (1)   NOT NULL,
    [L3_6]       CHAR (1)   NOT NULL,
    [L4_6]       CHAR (1)   NOT NULL,
    [L5_6]       CHAR (1)   NOT NULL,
    [L6_6]       CHAR (1)   NOT NULL,
    [L7_6]       CHAR (1)   NOT NULL,
    [L8_6]       CHAR (1)   NOT NULL,
    [L9_6]       CHAR (1)   NOT NULL,
    [L10_6]      CHAR (1)   NOT NULL,
    [L11_6]      CHAR (1)   NOT NULL,
    [L12_6]      CHAR (1)   NOT NULL,
    [CNP_7]      FLOAT (53) NOT NULL,
    [L1_7]       CHAR (1)   NOT NULL,
    [L2_7]       CHAR (1)   NOT NULL,
    [L3_7]       CHAR (1)   NOT NULL,
    [L4_7]       CHAR (1)   NOT NULL,
    [L5_7]       CHAR (1)   NOT NULL,
    [L6_7]       CHAR (1)   NOT NULL,
    [L7_7]       CHAR (1)   NOT NULL,
    [L8_7]       CHAR (1)   NOT NULL,
    [L9_7]       CHAR (1)   NOT NULL,
    [L10_7]      CHAR (1)   NOT NULL,
    [L11_7]      CHAR (1)   NOT NULL,
    [L12_7]      CHAR (1)   NOT NULL,
    [CNP_8]      FLOAT (53) NOT NULL,
    [L1_8]       CHAR (1)   NOT NULL,
    [L2_8]       CHAR (1)   NOT NULL,
    [L3_8]       CHAR (1)   NOT NULL,
    [L4_8]       CHAR (1)   NOT NULL,
    [L5_8]       CHAR (1)   NOT NULL,
    [L6_8]       CHAR (1)   NOT NULL,
    [L7_8]       CHAR (1)   NOT NULL,
    [L8_8]       CHAR (1)   NOT NULL,
    [L9_8]       CHAR (1)   NOT NULL,
    [L10_8]      CHAR (1)   NOT NULL,
    [L11_8]      CHAR (1)   NOT NULL,
    [L12_8]      CHAR (1)   NOT NULL,
    [VBRUT_1]    FLOAT (53) NOT NULL,
    [DEDU_1]     FLOAT (53) NOT NULL,
    [ALTDED_1]   FLOAT (53) NOT NULL,
    [VENIT_1]    FLOAT (53) NOT NULL,
    [IMPOZIT_1]  FLOAT (53) NOT NULL,
    [VBRUT_2]    FLOAT (53) NOT NULL,
    [DEDU_2]     FLOAT (53) NOT NULL,
    [ALTDED_2]   FLOAT (53) NOT NULL,
    [VENIT_2]    FLOAT (53) NOT NULL,
    [IMPOZIT_2]  FLOAT (53) NOT NULL,
    [VBRUT_3]    FLOAT (53) NOT NULL,
    [DEDU_3]     FLOAT (53) NOT NULL,
    [ALTDED_3]   FLOAT (53) NOT NULL,
    [VENIT_3]    FLOAT (53) NOT NULL,
    [IMPOZIT_3]  FLOAT (53) NOT NULL,
    [VBRUT_4]    FLOAT (53) NOT NULL,
    [DEDU_4]     FLOAT (53) NOT NULL,
    [ALTDED_4]   FLOAT (53) NOT NULL,
    [VENIT_4]    FLOAT (53) NOT NULL,
    [IMPOZIT_4]  FLOAT (53) NOT NULL,
    [VBRUT_5]    FLOAT (53) NOT NULL,
    [DEDU_5]     FLOAT (53) NOT NULL,
    [ALTDED_5]   FLOAT (53) NOT NULL,
    [VENIT_5]    FLOAT (53) NOT NULL,
    [IMPOZIT_5]  FLOAT (53) NOT NULL,
    [VBRUT_6]    FLOAT (53) NOT NULL,
    [DEDU_6]     FLOAT (53) NOT NULL,
    [ALTDED_6]   FLOAT (53) NOT NULL,
    [VENIT_6]    FLOAT (53) NOT NULL,
    [IMPOZIT_6]  FLOAT (53) NOT NULL,
    [TOT6_ROL]   FLOAT (53) NOT NULL,
    [TOT6_RON]   FLOAT (53) NOT NULL,
    [VBRUT_7]    FLOAT (53) NOT NULL,
    [DEDU_7]     FLOAT (53) NOT NULL,
    [ALTDED_7]   FLOAT (53) NOT NULL,
    [VENIT_7]    FLOAT (53) NOT NULL,
    [IMPOZIT_7]  FLOAT (53) NOT NULL,
    [VBRUT_8]    FLOAT (53) NOT NULL,
    [DEDU_8]     FLOAT (53) NOT NULL,
    [ALTDED_8]   FLOAT (53) NOT NULL,
    [VENIT_8]    FLOAT (53) NOT NULL,
    [IMPOZIT_8]  FLOAT (53) NOT NULL,
    [VBRUT_9]    FLOAT (53) NOT NULL,
    [DEDU_9]     FLOAT (53) NOT NULL,
    [ALTDED_9]   FLOAT (53) NOT NULL,
    [VENIT_9]    FLOAT (53) NOT NULL,
    [IMPOZIT_9]  FLOAT (53) NOT NULL,
    [VBRUT_10]   FLOAT (53) NOT NULL,
    [DEDU_10]    FLOAT (53) NOT NULL,
    [ALTDED_10]  FLOAT (53) NOT NULL,
    [VENIT_10]   FLOAT (53) NOT NULL,
    [IMPOZIT_10] FLOAT (53) NOT NULL,
    [VBRUT_11]   FLOAT (53) NOT NULL,
    [DEDU_11]    FLOAT (53) NOT NULL,
    [ALTDED_11]  FLOAT (53) NOT NULL,
    [VENIT_11]   FLOAT (53) NOT NULL,
    [IMPOZIT_11] FLOAT (53) NOT NULL,
    [VBRUT_12]   FLOAT (53) NOT NULL,
    [DEDU_12]    FLOAT (53) NOT NULL,
    [ALTDED_12]  FLOAT (53) NOT NULL,
    [VENIT_12]   FLOAT (53) NOT NULL,
    [IMPOZIT_12] FLOAT (53) NOT NULL,
    [VBRUT_13]   FLOAT (53) NOT NULL,
    [DEDU_13]    FLOAT (53) NOT NULL,
    [ALTDED_13]  FLOAT (53) NOT NULL,
    [VENIT_13]   FLOAT (53) NOT NULL,
    [IMPOZIT_13] FLOAT (53) NOT NULL,
    [BURSA_PL]   FLOAT (53) NOT NULL,
    [BURSA_AD]   FLOAT (53) NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [CNP]
    ON [dbo].[FiseFisc05]([AN] ASC, [VERSIUNE] ASC, [TIP] ASC, [Cod] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [PRINCIPAL]
    ON [dbo].[FiseFisc05]([AN] ASC, [VERSIUNE] ASC, [TIP] ASC, [MARCA] ASC);


GO
CREATE NONCLUSTERED INDEX [OPERARE]
    ON [dbo].[FiseFisc05]([AN] ASC, [VERSIUNE] ASC, [TIP] ASC, [Denumire] ASC);
