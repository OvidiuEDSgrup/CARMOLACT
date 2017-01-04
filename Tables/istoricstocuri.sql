CREATE TABLE [dbo].[istoricstocuri] (
    [Subunitate]        CHAR (9)     NOT NULL,
    [Data_lunii]        DATETIME     NOT NULL,
    [Tip_gestiune]      CHAR (1)     NOT NULL,
    [Cod_gestiune]      CHAR (20)    NOT NULL,
    [Cod]               CHAR (20)    NOT NULL,
    [Data]              DATETIME     NOT NULL,
    [Cod_intrare]       CHAR (13)    NOT NULL,
    [Pret]              FLOAT (53)   NOT NULL,
    [TVA_neexigibil]    REAL         NOT NULL,
    [Pret_cu_amanuntul] FLOAT (53)   NOT NULL,
    [Stoc]              FLOAT (53)   NOT NULL,
    [Cont]              VARCHAR (20) NULL,
    [Locatie]           CHAR (30)    NOT NULL,
    [Data_expirarii]    DATETIME     NOT NULL,
    [Pret_vanzare]      FLOAT (53)   NOT NULL,
    [Loc_de_munca]      CHAR (9)     NOT NULL,
    [Comanda]           CHAR (20)    NOT NULL,
    [Contract]          CHAR (20)    NOT NULL,
    [Furnizor]          CHAR (13)    NOT NULL,
    [Lot]               CHAR (20)    NOT NULL,
    [Stoc_UM2]          FLOAT (53)   NOT NULL,
    [Val1]              FLOAT (53)   NOT NULL,
    [Alfa1]             CHAR (30)    NOT NULL,
    [Data1]             DATETIME     NOT NULL,
    [idIntrareFirma]    INT          NULL,
    [idIntrare]         INT          NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Principal]
    ON [dbo].[istoricstocuri]([Subunitate] ASC, [Data_lunii] ASC, [Tip_gestiune] ASC, [Cod_gestiune] ASC, [Cod] ASC, [Cod_intrare] ASC);


GO
CREATE NONCLUSTERED INDEX [missing_index_55]
    ON [dbo].[istoricstocuri]([Data_lunii] ASC);


GO
CREATE NONCLUSTERED INDEX [missing_index_53]
    ON [dbo].[istoricstocuri]([Subunitate] ASC, [Cod_gestiune] ASC, [Cod] ASC, [Cod_intrare] ASC);


GO
CREATE NONCLUSTERED INDEX [missing_index_160]
    ON [dbo].[istoricstocuri]([Data_lunii] ASC)
    INCLUDE([Tip_gestiune], [Cod_gestiune], [Cod], [Data], [Cod_intrare], [Pret], [Stoc], [Cont], [Data_expirarii], [Furnizor], [Lot]);


GO
CREATE STATISTICS [_dta_stat_2137058649_5_4_7]
    ON [dbo].[istoricstocuri]([Cod], [Cod_gestiune], [Cod_intrare]);


GO
CREATE STATISTICS [_dta_stat_2137058649_11_5_1]
    ON [dbo].[istoricstocuri]([Stoc], [Cod], [Subunitate]);


GO
CREATE STATISTICS [_dta_stat_2137058649_5_2_11_1]
    ON [dbo].[istoricstocuri]([Cod], [Data_lunii], [Stoc], [Subunitate]);


GO
CREATE STATISTICS [_dta_stat_2137058649_1_5_4_7_2]
    ON [dbo].[istoricstocuri]([Subunitate], [Cod], [Cod_gestiune], [Cod_intrare], [Data_lunii]);


GO
CREATE STATISTICS [_dta_stat_2137058649_2_11_1_4_7]
    ON [dbo].[istoricstocuri]([Data_lunii], [Stoc], [Subunitate], [Cod_gestiune], [Cod_intrare]);


GO
CREATE STATISTICS [_dta_stat_2137058649_7_5_1_2_11]
    ON [dbo].[istoricstocuri]([Cod_intrare], [Cod], [Subunitate], [Data_lunii], [Stoc]);


GO
CREATE STATISTICS [_dta_stat_2137058649_4_5_1_2_11_7]
    ON [dbo].[istoricstocuri]([Cod_gestiune], [Cod], [Subunitate], [Data_lunii], [Stoc], [Cod_intrare]);

