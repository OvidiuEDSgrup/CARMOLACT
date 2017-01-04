CREATE TABLE [dbo].[stocuri] (
    [Subunitate]                CHAR (9)     NOT NULL,
    [Tip_gestiune]              CHAR (1)     NOT NULL,
    [Cod_gestiune]              CHAR (20)    NOT NULL,
    [Cod]                       CHAR (20)    NOT NULL,
    [Data]                      DATETIME     NOT NULL,
    [Cod_intrare]               CHAR (13)    NOT NULL,
    [Pret]                      FLOAT (53)   NOT NULL,
    [Stoc_initial]              FLOAT (53)   NOT NULL,
    [Intrari]                   FLOAT (53)   NOT NULL,
    [Iesiri]                    FLOAT (53)   NOT NULL,
    [Data_ultimei_iesiri]       DATETIME     NOT NULL,
    [Stoc]                      FLOAT (53)   NOT NULL,
    [Cont]                      VARCHAR (20) NULL,
    [Data_expirarii]            DATETIME     NOT NULL,
    [Stoc_ce_se_calculeaza]     FLOAT (53)   NOT NULL,
    [Are_documente_in_perioada] BIT          NOT NULL,
    [TVA_neexigibil]            REAL         NOT NULL,
    [Pret_cu_amanuntul]         FLOAT (53)   NOT NULL,
    [Locatie]                   CHAR (30)    NOT NULL,
    [Pret_vanzare]              FLOAT (53)   NOT NULL,
    [Loc_de_munca]              CHAR (9)     NOT NULL,
    [Comanda]                   CHAR (20)    NOT NULL,
    [Contract]                  CHAR (20)    NOT NULL,
    [Furnizor]                  CHAR (13)    NOT NULL,
    [Lot]                       CHAR (20)    NOT NULL,
    [Stoc_initial_UM2]          FLOAT (53)   NOT NULL,
    [Intrari_UM2]               FLOAT (53)   NOT NULL,
    [Iesiri_UM2]                FLOAT (53)   NOT NULL,
    [Stoc_UM2]                  FLOAT (53)   NOT NULL,
    [Stoc2_ce_se_calculeaza]    FLOAT (53)   NOT NULL,
    [Val1]                      FLOAT (53)   NOT NULL,
    [Alfa1]                     CHAR (30)    NOT NULL,
    [Data1]                     DATETIME     NOT NULL,
    [idIntrareFirma]            INT          NULL,
    [idIntrare]                 INT          NULL,
    CONSTRAINT [PK_Stocuri] PRIMARY KEY CLUSTERED ([Subunitate] ASC, [Tip_gestiune] ASC, [Cod_gestiune] ASC, [Cod] ASC, [Cod_intrare] ASC) ON [SYNTHESIS]
);


GO
CREATE NONCLUSTERED INDEX [Sub_Cod_Stoc]
    ON [dbo].[stocuri]([Subunitate] ASC, [Cod] ASC, [Stoc] ASC)
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [Pentru_preturi]
    ON [dbo].[stocuri]([Subunitate] ASC, [Cod] ASC, [Pret] ASC)
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [Locatie]
    ON [dbo].[stocuri]([Locatie] ASC, [Stoc] ASC)
    ON [SYNTHESIS];


GO
CREATE UNIQUE NONCLUSTERED INDEX [FIFO_dataexp]
    ON [dbo].[stocuri]([Subunitate] ASC, [Tip_gestiune] ASC, [Cod_gestiune] ASC, [Cod] ASC, [Data_expirarii] ASC, [Cod_intrare] ASC)
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [yso_cod_intrare]
    ON [dbo].[stocuri]([Cod_intrare] ASC, [Cod_gestiune] ASC)
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [missing_index_664]
    ON [dbo].[stocuri]([Cod_gestiune] ASC, [Cod] ASC, [Cod_intrare] ASC)
    INCLUDE([Stoc])
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [missing_index_666]
    ON [dbo].[stocuri]([Cod_gestiune] ASC, [Cod] ASC, [Cod_intrare] ASC, [Stoc] ASC)
    INCLUDE([Subunitate], [Tip_gestiune], [Data])
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [missing_index_984]
    ON [dbo].[stocuri]([Subunitate] ASC, [Cod] ASC)
    INCLUDE([Tip_gestiune], [Cod_gestiune], [Cod_intrare], [Pret], [Stoc], [Stoc_UM2])
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [missing_index_959]
    ON [dbo].[stocuri]([Cod] ASC)
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [missing_index_1221]
    ON [dbo].[stocuri]([Cod] ASC, [Cod_intrare] ASC, [Stoc] ASC)
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [missing_index_1063]
    ON [dbo].[stocuri]([Subunitate] ASC, [Cod] ASC, [Stoc] ASC)
    INCLUDE([Tip_gestiune], [Cod_gestiune], [Data], [Cod_intrare], [Pret])
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [missing_index_1176]
    ON [dbo].[stocuri]([Subunitate] ASC, [Cod] ASC)
    INCLUDE([Tip_gestiune], [Cod_gestiune], [Data], [Cod_intrare], [Pret], [Stoc], [Cont], [Pret_cu_amanuntul], [Locatie], [Comanda], [Contract], [Furnizor], [Lot])
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [missing_index_1219]
    ON [dbo].[stocuri]([Subunitate] ASC, [Cod] ASC, [Data_expirarii] ASC)
    INCLUDE([Tip_gestiune], [Cod_gestiune], [Data], [Cod_intrare], [Pret], [Stoc], [Cont], [TVA_neexigibil], [Pret_cu_amanuntul], [Locatie], [Loc_de_munca], [Comanda], [Contract], [Furnizor], [Lot])
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [missing_index_1724]
    ON [dbo].[stocuri]([Tip_gestiune] ASC)
    INCLUDE([Subunitate], [Cod_gestiune], [Cod], [Cod_intrare])
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [missing_index_1172]
    ON [dbo].[stocuri]([Subunitate] ASC, [Tip_gestiune] ASC, [Cod] ASC, [Cod_gestiune] ASC, [Stoc] ASC)
    INCLUDE([Data], [Cod_intrare], [Pret], [Cont], [Data_expirarii], [Pret_cu_amanuntul], [Locatie], [Pret_vanzare], [Loc_de_munca], [Comanda], [Contract], [Furnizor], [Lot])
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [missing_index_64]
    ON [dbo].[stocuri]([Subunitate] ASC, [Tip_gestiune] ASC, [Cod_gestiune] ASC, [Cod] ASC, [Data] ASC)
    INCLUDE([Cod_intrare], [Pret], [Stoc], [Cont], [Data_expirarii], [Pret_cu_amanuntul], [Locatie], [Pret_vanzare], [Loc_de_munca], [Comanda], [Contract], [Furnizor], [Lot])
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [missing_index_447]
    ON [dbo].[stocuri]([Subunitate] ASC, [Cod] ASC, [Cod_gestiune] ASC)
    INCLUDE([Tip_gestiune], [Data], [Cod_intrare], [Pret], [Stoc], [Cont], [Pret_cu_amanuntul], [Locatie], [Comanda], [Contract], [Furnizor], [Lot])
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [missing_index_6140]
    ON [dbo].[stocuri]([Cod_gestiune] ASC, [Cod] ASC)
    INCLUDE([Subunitate], [Tip_gestiune], [Data], [Cod_intrare], [Pret], [Stoc_initial], [Intrari], [Iesiri], [Data_ultimei_iesiri], [Stoc], [Cont], [Data_expirarii], [Stoc_ce_se_calculeaza], [Are_documente_in_perioada], [TVA_neexigibil], [Pret_cu_amanuntul], [Locatie], [Pret_vanzare], [Loc_de_munca], [Comanda], [Contract], [Furnizor], [Lot], [Stoc_initial_UM2], [Intrari_UM2], [Iesiri_UM2], [Stoc_UM2], [Stoc2_ce_se_calculeaza], [Val1], [Alfa1], [Data1], [idIntrareFirma], [idIntrare])
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [missing_index_423]
    ON [dbo].[stocuri]([Subunitate] ASC, [Cod_gestiune] ASC, [Cod] ASC)
    INCLUDE([Tip_gestiune], [Cod_intrare], [Stoc_ce_se_calculeaza], [Locatie])
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [missing_index_6137]
    ON [dbo].[stocuri]([Cod] ASC)
    INCLUDE([Subunitate], [Tip_gestiune], [Cod_gestiune], [Data], [Cod_intrare], [Pret], [Stoc_initial], [Intrari], [Iesiri], [Data_ultimei_iesiri], [Stoc], [Cont], [Data_expirarii], [Stoc_ce_se_calculeaza], [Are_documente_in_perioada], [TVA_neexigibil], [Pret_cu_amanuntul], [Locatie], [Pret_vanzare], [Loc_de_munca], [Comanda], [Contract], [Furnizor], [Lot], [Stoc_initial_UM2], [Intrari_UM2], [Iesiri_UM2], [Stoc_UM2], [Stoc2_ce_se_calculeaza], [Val1], [Alfa1], [Data1], [idIntrareFirma], [idIntrare])
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [missing_index_3919]
    ON [dbo].[stocuri]([Subunitate] ASC, [Cod_gestiune] ASC, [Cod] ASC, [Tip_gestiune] ASC)
    INCLUDE([Data], [Cod_intrare], [Pret], [Stoc], [Cont], [Stoc_ce_se_calculeaza], [Pret_cu_amanuntul])
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [missing_index_6142]
    ON [dbo].[stocuri]([Cod_gestiune] ASC, [Cod] ASC, [Stoc] ASC)
    INCLUDE([Subunitate], [Tip_gestiune], [Data], [Cod_intrare], [Pret], [Stoc_initial], [Intrari], [Iesiri], [Data_ultimei_iesiri], [Cont], [Data_expirarii], [Stoc_ce_se_calculeaza], [Are_documente_in_perioada], [TVA_neexigibil], [Pret_cu_amanuntul], [Locatie], [Pret_vanzare], [Loc_de_munca], [Comanda], [Contract], [Furnizor], [Lot], [Stoc_initial_UM2], [Intrari_UM2], [Iesiri_UM2], [Stoc_UM2], [Stoc2_ce_se_calculeaza], [Val1], [Alfa1], [Data1], [idIntrareFirma], [idIntrare])
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [missing_index_3917]
    ON [dbo].[stocuri]([Subunitate] ASC, [Tip_gestiune] ASC, [Cod_gestiune] ASC, [Cod] ASC, [Stoc_ce_se_calculeaza] ASC)
    INCLUDE([Data], [Cod_intrare], [Stoc])
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [missing_index_944]
    ON [dbo].[stocuri]([Cod_gestiune] ASC, [Cod] ASC, [Cod_intrare] ASC, [Stoc] ASC)
    INCLUDE([Subunitate], [Tip_gestiune], [Data])
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [missing_index_732]
    ON [dbo].[stocuri]([Subunitate] ASC, [Tip_gestiune] ASC, [Cod_gestiune] ASC, [Cod] ASC, [Stoc] ASC)
    INCLUDE([Data], [Cod_intrare], [Pret], [Cont], [Data_expirarii], [TVA_neexigibil], [Pret_cu_amanuntul], [Locatie], [Contract], [Lot])
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [missing_index_217]
    ON [dbo].[stocuri]([Subunitate] ASC, [Tip_gestiune] ASC, [Cod_gestiune] ASC, [Cod] ASC, [Stoc] ASC)
    INCLUDE([Data], [Cod_intrare], [Pret], [Stoc_initial], [Intrari], [Iesiri], [Data_ultimei_iesiri], [Cont], [Data_expirarii], [Pret_cu_amanuntul], [Locatie], [Pret_vanzare], [Comanda], [Contract], [Stoc_UM2])
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [missing_index_779]
    ON [dbo].[stocuri]([Subunitate] ASC, [Tip_gestiune] ASC, [Cod_gestiune] ASC, [Cod] ASC, [Comanda] ASC, [Data] ASC, [Stoc] ASC)
    INCLUDE([Cod_intrare], [Locatie])
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [missing_index_3975]
    ON [dbo].[stocuri]([Subunitate] ASC, [Cod] ASC, [Cod_intrare] ASC)
    INCLUDE([Tip_gestiune], [Cod_gestiune], [Data], [Pret], [Stoc], [Cont], [Pret_cu_amanuntul], [Locatie], [Comanda], [Contract], [Furnizor], [Lot])
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [missing_index_6152]
    ON [dbo].[stocuri]([Subunitate] ASC, [Stoc_ce_se_calculeaza] ASC)
    INCLUDE([Tip_gestiune], [Cod_gestiune], [Cod], [Data], [Cod_intrare], [Furnizor])
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [missing_index_65]
    ON [dbo].[stocuri]([Cod_gestiune] ASC, [Cod] ASC, [Cod_intrare] ASC, [Stoc] ASC)
    INCLUDE([Data], [Pret])
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [missing_index_12]
    ON [dbo].[stocuri]([Subunitate] ASC, [Tip_gestiune] ASC, [Cod_gestiune] ASC, [Cod] ASC, [Stoc] ASC)
    INCLUDE([Data], [Cod_intrare], [Pret], [Stoc_initial], [Intrari], [Iesiri], [Data_ultimei_iesiri], [Cont], [Data_expirarii], [Pret_cu_amanuntul], [Locatie], [Pret_vanzare], [Comanda], [Contract], [Stoc_UM2])
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [missing_index_103]
    ON [dbo].[stocuri]([Subunitate] ASC, [Tip_gestiune] ASC, [Cod_gestiune] ASC, [Cod] ASC, [Stoc] ASC)
    INCLUDE([Data], [Cod_intrare], [Pret], [Cont], [Data_expirarii], [TVA_neexigibil], [Pret_cu_amanuntul], [Locatie], [Contract], [Lot])
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [missing_index_154]
    ON [dbo].[stocuri]([idIntrareFirma] ASC)
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [missing_index_345]
    ON [dbo].[stocuri]([Subunitate] ASC, [Cod] ASC, [Stoc] ASC)
    INCLUDE([Tip_gestiune], [Cod_gestiune], [Data], [Cod_intrare], [Pret], [Cont], [Pret_cu_amanuntul], [Locatie], [Comanda], [Contract], [Furnizor], [Lot])
    ON [SYNTHESIS];


GO
CREATE STATISTICS [_dta_stat_1957582012_4_12]
    ON [dbo].[stocuri]([Cod], [Stoc]);

