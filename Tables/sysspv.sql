CREATE TABLE [dbo].[sysspv] (
    [Host_id]           VARCHAR (10)  NULL,
    [Host_name]         VARCHAR (30)  NULL,
    [Aplicatia]         VARCHAR (30)  NULL,
    [Data_stergerii]    DATETIME2 (7) NULL,
    [Stergator]         VARCHAR (10)  NULL,
    [Data_operarii]     DATETIME2 (3) NULL,
    [Ora_operarii]      VARCHAR (6)   NULL,
    [Cod_produs]        VARCHAR (20)  NULL,
    [UM]                SMALLINT      NOT NULL,
    [Tip_pret]          VARCHAR (20)  NULL,
    [Data_inferioara]   DATETIME2 (3) NULL,
    [Ora_inferioara]    VARCHAR (13)  NULL,
    [Data_superioara]   DATETIME2 (3) NULL,
    [Ora_superioara]    VARCHAR (6)   NULL,
    [Pret_vanzare]      FLOAT (53)    NOT NULL,
    [Pret_cu_amanuntul] FLOAT (53)    NOT NULL,
    [Utilizator]        VARCHAR (10)  NULL
) ON [SYSS];

