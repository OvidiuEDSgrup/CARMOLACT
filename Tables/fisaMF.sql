CREATE TABLE [dbo].[fisaMF] (
    [Subunitate]                   CHAR (9)     NOT NULL,
    [Numar_de_inventar]            CHAR (13)    NOT NULL,
    [Categoria]                    SMALLINT     NOT NULL,
    [Data_lunii_operatiei]         DATETIME     NOT NULL,
    [Felul_operatiei]              CHAR (1)     NOT NULL,
    [Loc_de_munca]                 CHAR (9)     NOT NULL,
    [Gestiune]                     CHAR (9)     NOT NULL,
    [Comanda]                      CHAR (20)    NOT NULL,
    [Valoare_de_inventar]          FLOAT (53)   NOT NULL,
    [Valoare_amortizata]           FLOAT (53)   NOT NULL,
    [Valoare_amortizata_cont_8045] FLOAT (53)   NOT NULL,
    [Valoare_amortizata_cont_6871] FLOAT (53)   NOT NULL,
    [Amortizare_lunara]            FLOAT (53)   NOT NULL,
    [Amortizare_lunara_cont_8045]  FLOAT (53)   NOT NULL,
    [Amortizare_lunara_cont_6871]  FLOAT (53)   NOT NULL,
    [Durata]                       SMALLINT     NOT NULL,
    [Obiect_de_inventar]           BIT          NOT NULL,
    [Cont_mijloc_fix]              VARCHAR (20) NULL,
    [Numar_de_luni_pana_la_am_int] SMALLINT     NOT NULL,
    [Cantitate]                    FLOAT (53)   NOT NULL,
    [Cont_amortizare]              VARCHAR (40) NULL,
    [Cont_cheltuieli]              VARCHAR (40) NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Subunitate_Nrinv_Perioada]
    ON [dbo].[fisaMF]([Subunitate] ASC, [Numar_de_inventar] ASC, [Data_lunii_operatiei] ASC, [Felul_operatiei] ASC);


GO
CREATE NONCLUSTERED INDEX [Pentru_calcul]
    ON [dbo].[fisaMF]([Subunitate] ASC, [Data_lunii_operatiei] DESC, [Numar_de_inventar] ASC, [Felul_operatiei] DESC);


GO
CREATE NONCLUSTERED INDEX [Pentru_balanta]
    ON [dbo].[fisaMF]([Subunitate] ASC, [Data_lunii_operatiei] ASC, [Felul_operatiei] ASC, [Cont_mijloc_fix] ASC);


GO
CREATE NONCLUSTERED INDEX [missing_index_316]
    ON [dbo].[fisaMF]([Subunitate] ASC, [Data_lunii_operatiei] ASC, [Felul_operatiei] ASC, [Amortizare_lunara_cont_6871] ASC)
    INCLUDE([Numar_de_inventar], [Categoria], [Loc_de_munca]);


GO
CREATE NONCLUSTERED INDEX [missing_index_339]
    ON [dbo].[fisaMF]([Subunitate] ASC, [Data_lunii_operatiei] ASC, [Felul_operatiei] ASC, [Numar_de_luni_pana_la_am_int] ASC)
    INCLUDE([Numar_de_inventar], [Categoria], [Loc_de_munca], [Valoare_de_inventar], [Valoare_amortizata], [Amortizare_lunara], [Durata]);


GO
CREATE NONCLUSTERED INDEX [missing_index_318]
    ON [dbo].[fisaMF]([Subunitate] ASC, [Data_lunii_operatiei] ASC, [Felul_operatiei] ASC)
    INCLUDE([Numar_de_inventar], [Categoria], [Loc_de_munca], [Valoare_amortizata_cont_6871], [Amortizare_lunara_cont_6871]);


GO
CREATE NONCLUSTERED INDEX [missing_index_367]
    ON [dbo].[fisaMF]([Subunitate] ASC, [Data_lunii_operatiei] ASC, [Felul_operatiei] ASC, [Numar_de_luni_pana_la_am_int] ASC)
    INCLUDE([Numar_de_inventar], [Categoria], [Loc_de_munca]);


GO
CREATE NONCLUSTERED INDEX [missing_index_342]
    ON [dbo].[fisaMF]([Subunitate] ASC, [Data_lunii_operatiei] ASC, [Felul_operatiei] ASC, [Numar_de_luni_pana_la_am_int] ASC)
    INCLUDE([Numar_de_inventar], [Categoria], [Loc_de_munca], [Valoare_de_inventar], [Valoare_amortizata], [Amortizare_lunara]);


GO
CREATE NONCLUSTERED INDEX [missing_index_344]
    ON [dbo].[fisaMF]([Subunitate] ASC, [Data_lunii_operatiei] ASC, [Felul_operatiei] ASC, [Numar_de_luni_pana_la_am_int] ASC)
    INCLUDE([Numar_de_inventar], [Categoria], [Loc_de_munca], [Valoare_de_inventar], [Valoare_amortizata], [Obiect_de_inventar]);


GO
CREATE NONCLUSTERED INDEX [missing_index_348]
    ON [dbo].[fisaMF]([Subunitate] ASC, [Data_lunii_operatiei] ASC, [Felul_operatiei] ASC)
    INCLUDE([Numar_de_inventar], [Categoria], [Loc_de_munca], [Valoare_de_inventar], [Valoare_amortizata], [Durata], [Numar_de_luni_pana_la_am_int]);


GO
CREATE NONCLUSTERED INDEX [missing_index_350]
    ON [dbo].[fisaMF]([Subunitate] ASC, [Data_lunii_operatiei] ASC, [Felul_operatiei] ASC)
    INCLUDE([Numar_de_inventar], [Categoria], [Loc_de_munca], [Durata], [Numar_de_luni_pana_la_am_int]);


GO
CREATE NONCLUSTERED INDEX [missing_index_322]
    ON [dbo].[fisaMF]([Subunitate] ASC, [Data_lunii_operatiei] ASC, [Felul_operatiei] ASC)
    INCLUDE([Numar_de_inventar], [Categoria], [Loc_de_munca], [Valoare_amortizata_cont_8045], [Amortizare_lunara_cont_8045]);


GO
CREATE NONCLUSTERED INDEX [missing_index_353]
    ON [dbo].[fisaMF]([Subunitate] ASC, [Data_lunii_operatiei] ASC, [Felul_operatiei] ASC)
    INCLUDE([Numar_de_inventar], [Categoria], [Loc_de_munca], [Valoare_de_inventar]);


GO
CREATE NONCLUSTERED INDEX [missing_index_312]
    ON [dbo].[fisaMF]([Subunitate] ASC, [Data_lunii_operatiei] ASC, [Felul_operatiei] ASC)
    INCLUDE([Numar_de_inventar], [Categoria], [Loc_de_munca], [Amortizare_lunara]);


GO
CREATE NONCLUSTERED INDEX [missing_index_355]
    ON [dbo].[fisaMF]([Subunitate] ASC, [Data_lunii_operatiei] ASC, [Felul_operatiei] ASC)
    INCLUDE([Numar_de_inventar], [Categoria], [Loc_de_munca], [Valoare_amortizata], [Amortizare_lunara]);


GO
CREATE NONCLUSTERED INDEX [missing_index_335]
    ON [dbo].[fisaMF]([Subunitate] ASC, [Data_lunii_operatiei] ASC, [Felul_operatiei] ASC)
    INCLUDE([Numar_de_inventar], [Categoria], [Loc_de_munca], [Gestiune], [Comanda], [Valoare_de_inventar], [Valoare_amortizata], [Valoare_amortizata_cont_8045], [Valoare_amortizata_cont_6871], [Amortizare_lunara], [Amortizare_lunara_cont_8045], [Amortizare_lunara_cont_6871], [Durata], [Obiect_de_inventar], [Cont_mijloc_fix], [Numar_de_luni_pana_la_am_int], [Cantitate], [Cont_amortizare], [Cont_cheltuieli]);


GO
CREATE NONCLUSTERED INDEX [missing_index_337]
    ON [dbo].[fisaMF]([Subunitate] ASC, [Data_lunii_operatiei] ASC, [Felul_operatiei] ASC)
    INCLUDE([Numar_de_inventar], [Categoria]);


GO
CREATE NONCLUSTERED INDEX [missing_index_297]
    ON [dbo].[fisaMF]([Subunitate] ASC, [Data_lunii_operatiei] ASC, [Felul_operatiei] ASC)
    INCLUDE([Numar_de_inventar], [Categoria], [Loc_de_munca]);


GO
CREATE NONCLUSTERED INDEX [missing_index_362]
    ON [dbo].[fisaMF]([Subunitate] ASC, [Data_lunii_operatiei] ASC, [Felul_operatiei] ASC)
    INCLUDE([Numar_de_inventar], [Durata]);


GO
CREATE NONCLUSTERED INDEX [missing_index_365]
    ON [dbo].[fisaMF]([Subunitate] ASC, [Data_lunii_operatiei] ASC, [Felul_operatiei] ASC)
    INCLUDE([Numar_de_inventar], [Numar_de_luni_pana_la_am_int]);


GO
CREATE NONCLUSTERED INDEX [missing_index_958]
    ON [dbo].[fisaMF]([Subunitate] ASC, [Felul_operatiei] ASC)
    INCLUDE([Numar_de_inventar], [Categoria], [Data_lunii_operatiei], [Loc_de_munca], [Gestiune], [Comanda], [Valoare_de_inventar], [Valoare_amortizata], [Valoare_amortizata_cont_8045], [Valoare_amortizata_cont_6871], [Amortizare_lunara], [Amortizare_lunara_cont_6871], [Durata], [Obiect_de_inventar], [Cont_mijloc_fix], [Numar_de_luni_pana_la_am_int], [Cantitate], [Cont_amortizare]);

