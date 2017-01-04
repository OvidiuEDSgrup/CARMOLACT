CREATE TABLE [dbo].[facturi] (
    [Subunitate]            CHAR (9)     NOT NULL,
    [Loc_de_munca]          CHAR (9)     NOT NULL,
    [Tip]                   BINARY (1)   NOT NULL,
    [Factura]               CHAR (20)    NOT NULL,
    [Tert]                  CHAR (13)    NOT NULL,
    [Data]                  DATETIME     NOT NULL,
    [Data_scadentei]        DATETIME     NOT NULL,
    [Valoare]               FLOAT (53)   NOT NULL,
    [TVA_11]                FLOAT (53)   NOT NULL,
    [TVA_22]                FLOAT (53)   NOT NULL,
    [Valuta]                CHAR (3)     NOT NULL,
    [Curs]                  FLOAT (53)   NOT NULL,
    [Valoare_valuta]        FLOAT (53)   NOT NULL,
    [Achitat]               FLOAT (53)   NOT NULL,
    [Sold]                  FLOAT (53)   NOT NULL,
    [Cont_de_tert]          VARCHAR (20) NULL,
    [Achitat_valuta]        FLOAT (53)   NOT NULL,
    [Sold_valuta]           FLOAT (53)   NOT NULL,
    [Comanda]               CHAR (20)    NOT NULL,
    [Data_ultimei_achitari] DATETIME     NOT NULL,
    CONSTRAINT [PK_Facturi] PRIMARY KEY CLUSTERED ([Subunitate] ASC, [Tip] ASC, [Factura] ASC, [Tert] ASC) ON [SYNTHESIS]
);


GO
CREATE NONCLUSTERED INDEX [Sub_Tip_Tert]
    ON [dbo].[facturi]([Subunitate] ASC, [Tert] ASC, [Tip] ASC)
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [Jurnale_TVA]
    ON [dbo].[facturi]([Subunitate] ASC, [Tip] ASC, [Data] ASC)
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [missing_index_266]
    ON [dbo].[facturi]([Subunitate] ASC, [Tert] ASC)
    INCLUDE([Tip], [Factura], [Sold], [Sold_valuta])
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [missing_index_298]
    ON [dbo].[facturi]([Subunitate] ASC, [Tip] ASC, [Tert] ASC, [Data] ASC, [Sold] ASC)
    INCLUDE([Factura])
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [missing_index_367]
    ON [dbo].[facturi]([Subunitate] ASC, [Factura] ASC, [Tip] ASC, [Tert] ASC)
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [missing_index_300]
    ON [dbo].[facturi]([Subunitate] ASC, [Tip] ASC, [Tert] ASC, [Data_scadentei] ASC)
    INCLUDE([Loc_de_munca], [Factura], [Data], [Valoare], [TVA_11], [TVA_22], [Valuta], [Curs], [Valoare_valuta], [Achitat], [Sold], [Cont_de_tert], [Achitat_valuta], [Sold_valuta], [Comanda], [Data_ultimei_achitari])
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [missing_index_331]
    ON [dbo].[facturi]([Factura] ASC, [Tert] ASC)
    INCLUDE([Tip], [Data], [Cont_de_tert])
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [missing_index_317]
    ON [dbo].[facturi]([Factura] ASC, [Tert] ASC)
    INCLUDE([Tip], [Data])
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [missing_index_465]
    ON [dbo].[facturi]([Tip] ASC, [Factura] ASC, [Tert] ASC)
    INCLUDE([Loc_de_munca], [Comanda])
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [missing_index_307]
    ON [dbo].[facturi]([Subunitate] ASC, [Tip] ASC, [Tert] ASC, [Data] ASC)
    INCLUDE([Loc_de_munca], [Factura], [Data_scadentei], [Valoare], [TVA_11], [TVA_22], [Valuta], [Curs], [Valoare_valuta], [Achitat], [Sold], [Cont_de_tert], [Achitat_valuta], [Sold_valuta], [Comanda], [Data_ultimei_achitari])
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [missing_index_467]
    ON [dbo].[facturi]([Tip] ASC)
    INCLUDE([Loc_de_munca], [Factura], [Tert], [Comanda])
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [missing_index_268]
    ON [dbo].[facturi]([Subunitate] ASC, [Tip] ASC, [Tert] ASC)
    INCLUDE([Loc_de_munca], [Factura], [Data], [Data_scadentei], [Valoare], [TVA_11], [TVA_22], [Valuta], [Curs], [Valoare_valuta], [Achitat], [Sold], [Cont_de_tert], [Achitat_valuta], [Sold_valuta], [Comanda], [Data_ultimei_achitari])
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [missing_index_915]
    ON [dbo].[facturi]([Tert] ASC, [Valuta] ASC, [Sold] ASC)
    INCLUDE([Loc_de_munca], [Tip], [Factura], [Data_scadentei], [Curs], [Cont_de_tert], [Sold_valuta], [Comanda])
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [missing_index_369]
    ON [dbo].[facturi]([Tip] ASC)
    INCLUDE([Subunitate], [Loc_de_munca], [Factura], [Tert])
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [missing_index_980]
    ON [dbo].[facturi]([Subunitate] ASC, [Tert] ASC, [Data] ASC, [Cont_de_tert] ASC)
    INCLUDE([Loc_de_munca], [Tip], [Factura], [Data_scadentei], [Valoare], [TVA_11], [TVA_22], [Achitat], [Sold], [Data_ultimei_achitari])
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [missing_index_978]
    ON [dbo].[facturi]([Subunitate] ASC, [Tert] ASC)
    INCLUDE([Tip], [Factura], [Valoare], [TVA_11], [TVA_22], [Achitat])
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [missing_index_1429]
    ON [dbo].[facturi]([Subunitate] ASC, [Tip] ASC, [Tert] ASC, [Sold] ASC)
    INCLUDE([Factura], [Data])
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [missing_index_917]
    ON [dbo].[facturi]([Sold] ASC)
    INCLUDE([Loc_de_munca], [Tip], [Factura], [Tert], [Data_scadentei], [Valuta], [Curs], [Cont_de_tert], [Sold_valuta], [Comanda])
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [missing_index_1056]
    ON [dbo].[facturi]([Subunitate] ASC, [Tert] ASC, [Data] ASC)
    INCLUDE([Loc_de_munca], [Tip], [Factura], [Data_scadentei], [Valoare], [TVA_11], [TVA_22], [Achitat], [Sold], [Cont_de_tert], [Data_ultimei_achitari])
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [missing_index_1011]
    ON [dbo].[facturi]([Tip] ASC)
    INCLUDE([Loc_de_munca], [Factura], [Tert], [Data], [Data_scadentei], [Valoare], [TVA_22], [Sold])
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [missing_index_1760]
    ON [dbo].[facturi]([Tip] ASC, [Tert] ASC)
    INCLUDE([Factura], [Data], [Data_scadentei], [Sold])
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [missing_index_1756]
    ON [dbo].[facturi]([Tip] ASC, [Factura] ASC)
    INCLUDE([Tert], [Data_scadentei], [Sold])
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [missing_index_1758]
    ON [dbo].[facturi]([Tip] ASC, [Factura] ASC, [Sold] ASC)
    INCLUDE([Tert], [Data_scadentei])
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [missing_index_1762]
    ON [dbo].[facturi]([Tip] ASC)
    INCLUDE([Factura], [Tert], [Data], [Data_scadentei], [Sold])
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [missing_index_1005]
    ON [dbo].[facturi]([Subunitate] ASC, [Tert] ASC, [Data] ASC)
    INCLUDE([Loc_de_munca], [Tip], [Factura], [Data_scadentei], [Valoare], [TVA_11], [TVA_22], [Achitat], [Sold], [Cont_de_tert], [Comanda], [Data_ultimei_achitari])
    ON [SYNTHESIS];


GO
CREATE NONCLUSTERED INDEX [missing_index_229]
    ON [dbo].[facturi]([Subunitate] ASC, [Tert] ASC, [Data] ASC)
    INCLUDE([Loc_de_munca], [Tip], [Factura], [Data_scadentei], [Valoare], [TVA_11], [TVA_22], [Achitat], [Sold], [Cont_de_tert], [Comanda], [Data_ultimei_achitari])
    ON [SYNTHESIS];

