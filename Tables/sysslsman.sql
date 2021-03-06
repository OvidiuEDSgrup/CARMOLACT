﻿CREATE TABLE [dbo].[sysslsman] (
    [Host_id]            VARCHAR (10)  NULL,
    [Host_name]          VARCHAR (30)  NULL,
    [Aplicatia]          VARCHAR (30)  NULL,
    [Data_operarii]      DATETIME2 (3) NULL,
    [Utilizator]         VARCHAR (10)  NULL,
    [Tip_act]            VARCHAR (1)   NULL,
    [Subunitate]         VARCHAR (9)   NULL,
    [Comanda]            VARCHAR (13)  NULL,
    [Cod_produs]         VARCHAR (20)  NULL,
    [Cod_tata]           VARCHAR (20)  NULL,
    [Cod_operatie]       VARCHAR (20)  NULL,
    [Numar_operatie]     SMALLINT      NOT NULL,
    [Cantitate_necesara] FLOAT (53)    NOT NULL,
    [Pret]               FLOAT (53)    NOT NULL,
    [Numar_fisa]         VARCHAR (8)   NULL,
    [Loc_de_munca]       VARCHAR (9)   NULL,
    [Numar_de_inventar]  VARCHAR (13)  NULL,
    [Cod_material]       VARCHAR (20)  NULL,
    [Alfa1]              VARCHAR (20)  NULL,
    [Alfa2]              VARCHAR (20)  NULL,
    [Val1]               FLOAT (53)    NOT NULL,
    [Val2]               FLOAT (53)    NOT NULL,
    [Data]               DATETIME2 (3) NULL
) ON [SYSS];

