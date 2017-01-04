CREATE TABLE [dbo].[syssret] (
    [Host_id]                     VARCHAR (10)  NULL,
    [Host_name]                   VARCHAR (30)  NULL,
    [Aplicatia]                   VARCHAR (30)  NULL,
    [Data_operarii]               DATETIME2 (3) NULL,
    [Utilizator]                  VARCHAR (10)  NULL,
    [Tip_act]                     VARCHAR (1)   NULL,
    [Data]                        DATETIME2 (3) NULL,
    [Marca]                       VARCHAR (6)   NULL,
    [Cod_beneficiar]              VARCHAR (13)  NULL,
    [Numar_document]              VARCHAR (10)  NULL,
    [Data_document]               DATETIME2 (3) NULL,
    [Valoare_totala_pe_doc]       FLOAT (53)    NOT NULL,
    [Valoare_retinuta_pe_doc]     FLOAT (53)    NOT NULL,
    [Retinere_progr_la_avans]     FLOAT (53)    NOT NULL,
    [Retinere_progr_la_lichidare] FLOAT (53)    NOT NULL,
    [Procent_progr_la_lichidare]  REAL          NOT NULL,
    [Retinut_la_avans]            FLOAT (53)    NOT NULL,
    [Retinut_la_lichidare]        FLOAT (53)    NOT NULL
) ON [SYSS];

