CREATE TABLE [dbo].[sysscatop] (
    [Host_id]        VARCHAR (10)  NULL,
    [Host_name]      VARCHAR (30)  NULL,
    [Aplicatia]      VARCHAR (30)  NULL,
    [Data_operarii]  DATETIME2 (3) NULL,
    [Utilizator]     VARCHAR (10)  NULL,
    [Tip_act]        VARCHAR (1)   NULL,
    [Cod]            VARCHAR (20)  NULL,
    [Denumire]       VARCHAR (350) NULL,
    [UM]             VARCHAR (3)   NULL,
    [Tip_operatie]   VARCHAR (13)  NULL,
    [Numar_pozitii]  FLOAT (53)    NOT NULL,
    [Numar_persoane] FLOAT (53)    NOT NULL,
    [Tarif]          FLOAT (53)    NOT NULL,
    [Categorie]      VARCHAR (20)  NULL
) ON [SYSS];

