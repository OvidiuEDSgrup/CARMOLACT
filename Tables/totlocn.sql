CREATE TABLE [dbo].[totlocn] (
    [Data_tot]                      DATETIME   NOT NULL,
    [Marca_tot]                     CHAR (6)   NOT NULL,
    [Loc_de_munca_tot]              CHAR (9)   NOT NULL,
    [VENIT_TOTAL_tot]               FLOAT (53) NOT NULL,
    [CM_incasat_tot]                FLOAT (53) NOT NULL,
    [CO_incasat_tot]                FLOAT (53) NOT NULL,
    [Suma_incasata_tot]             FLOAT (53) NOT NULL,
    [Suma_neimpozabila_tot]         FLOAT (53) NOT NULL,
    [Diferenta_impozit_tot]         FLOAT (53) NOT NULL,
    [Impozit_tot]                   FLOAT (53) NOT NULL,
    [Pensie_suplimentara_3_tot]     FLOAT (53) NOT NULL,
    [Somaj_1_tot]                   FLOAT (53) NOT NULL,
    [Asig_sanatate_din_impozit_tot] FLOAT (53) NOT NULL,
    [Asig_sanatate_din_net_tot]     FLOAT (53) NOT NULL,
    [Asig_sanatate_din_CAS_tot]     FLOAT (53) NOT NULL,
    [SALAR_NET_tot]                 FLOAT (53) NOT NULL,
    [Avans_tot]                     FLOAT (53) NOT NULL,
    [Premiu_la_avans_tot]           FLOAT (53) NOT NULL,
    [Debite_externe_tot]            FLOAT (53) NOT NULL,
    [Rate_tot]                      FLOAT (53) NOT NULL,
    [Debite_interne_tot]            FLOAT (53) NOT NULL,
    [Cont_curent_tot]               FLOAT (53) NOT NULL,
    [REST_DE_PLATA_tot]             FLOAT (53) NOT NULL,
    [CAS_tot]                       FLOAT (53) NOT NULL,
    [Somaj_5_tot]                   FLOAT (53) NOT NULL,
    [Fond_de_risc_1_tot]            FLOAT (53) NOT NULL,
    [Asig_sanatate_pl_unitate_tot]  FLOAT (53) NOT NULL,
    [VENIT_NET]                     FLOAT (53) NOT NULL,
    [Ded_baza]                      FLOAT (53) NOT NULL,
    [Ded_supl]                      FLOAT (53) NOT NULL,
    [Ch_prof_15]                    FLOAT (53) NOT NULL,
    [Ven_BAZA_IMPOZ]                FLOAT (53) NOT NULL,
    [Nr_pers_tot]                   INT        NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Data_Marca_Locm]
    ON [dbo].[totlocn]([Data_tot] ASC, [Marca_tot] ASC, [Loc_de_munca_tot] ASC);

