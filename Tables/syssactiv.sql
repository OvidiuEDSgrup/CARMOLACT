CREATE TABLE [dbo].[syssactiv] (
    [Host_id]       VARCHAR (10)  NULL,
    [Host_name]     VARCHAR (30)  NULL,
    [Aplicatia]     VARCHAR (30)  NULL,
    [Data_operarii] DATETIME2 (3) NULL,
    [Utilizator]    VARCHAR (10)  NULL,
    [Tip_act]       VARCHAR (1)   NULL,
    [Tip]           VARCHAR (2)   NULL,
    [Fisa]          VARCHAR (10)  NULL,
    [Data]          DATETIME2 (3) NULL,
    [Masina]        VARCHAR (20)  NULL,
    [Comanda]       VARCHAR (13)  NULL,
    [Loc_de_munca]  VARCHAR (9)   NULL,
    [Comanda_benef] VARCHAR (13)  NULL,
    [lm_benef]      VARCHAR (9)   NULL,
    [Tert]          VARCHAR (13)  NULL,
    [Marca]         VARCHAR (6)   NULL,
    [Marca_ajutor]  VARCHAR (6)   NULL,
    [Jurnal]        VARCHAR (3)   NULL
) ON [SYSS];

