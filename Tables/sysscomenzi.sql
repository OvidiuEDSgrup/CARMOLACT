CREATE TABLE [dbo].[sysscomenzi] (
    [Host_id]                 VARCHAR (10)  NULL,
    [Host_name]               VARCHAR (30)  NULL,
    [Aplicatia]               VARCHAR (30)  NULL,
    [Data_operarii]           DATETIME2 (3) NULL,
    [Utilizator]              VARCHAR (10)  NULL,
    [Tip_act]                 VARCHAR (1)   NULL,
    [Subunitate]              VARCHAR (9)   NULL,
    [Comanda]                 VARCHAR (20)  NULL,
    [Tip_comanda]             VARCHAR (1)   NULL,
    [Descriere]               VARCHAR (80)  NULL,
    [Data_lansarii]           DATETIME2 (3) NULL,
    [Data_inchiderii]         DATETIME2 (3) NULL,
    [Starea_comenzii]         VARCHAR (1)   NULL,
    [Grup_de_comenzi]         BIT           NOT NULL,
    [Loc_de_munca]            VARCHAR (9)   NULL,
    [Numar_de_inventar]       VARCHAR (13)  NULL,
    [Beneficiar]              VARCHAR (13)  NULL,
    [Loc_de_munca_beneficiar] VARCHAR (9)   NULL,
    [Comanda_beneficiar]      VARCHAR (20)  NULL,
    [Art_calc_benef]          VARCHAR (200) NULL
) ON [SYSS];

