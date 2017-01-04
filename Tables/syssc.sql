CREATE TABLE [dbo].[syssc] (
    [Host_id]                    VARCHAR (10)  NULL,
    [Host_name]                  VARCHAR (30)  NULL,
    [Aplicatia]                  VARCHAR (30)  NULL,
    [Data_stergerii]             DATETIME2 (7) NULL,
    [Stergator]                  VARCHAR (10)  NULL,
    [Subunitate]                 VARCHAR (9)   NULL,
    [Cont]                       VARCHAR (20)  NULL,
    [Denumire_cont]              VARCHAR (80)  NULL,
    [Tip_cont]                   VARCHAR (1)   NULL,
    [Cont_parinte]               VARCHAR (20)  NULL,
    [Are_analitice]              BIT           NOT NULL,
    [Apare_in_balanta_sintetica] BIT           NOT NULL,
    [Sold_debit]                 FLOAT (53)    NOT NULL,
    [Sold_credit]                FLOAT (53)    NOT NULL,
    [Nivel]                      SMALLINT      NOT NULL,
    [Articol_de_calculatie]      VARCHAR (9)   NULL,
    [Logic]                      BIT           NOT NULL
) ON [SYSS];

