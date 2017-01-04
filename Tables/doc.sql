CREATE TABLE [dbo].[doc] (
    [Subunitate]          VARCHAR (9)   NOT NULL,
    [Tip]                 CHAR (2)      NOT NULL,
    [Numar]               CHAR (8)      NOT NULL,
    [Cod_gestiune]        VARCHAR (9)   NOT NULL,
    [Data]                DATETIME2 (0) NOT NULL,
    [Cod_tert]            VARCHAR (13)  NOT NULL,
    [Factura]             VARCHAR (20)  NOT NULL,
    [Contractul]          VARCHAR (20)  NOT NULL,
    [Loc_munca]           VARCHAR (9)   NOT NULL,
    [Comanda]             VARCHAR (20)  NOT NULL,
    [Gestiune_primitoare] VARCHAR (20)  NULL,
    [Valuta]              VARCHAR (3)   NOT NULL,
    [Curs]                FLOAT (53)    NOT NULL,
    [Valoare]             FLOAT (53)    NOT NULL,
    [Tva_11]              FLOAT (53)    NOT NULL,
    [Tva_22]              FLOAT (53)    NOT NULL,
    [Valoare_valuta]      FLOAT (53)    NOT NULL,
    [Cota_TVA]            REAL          NOT NULL,
    [Discount_p]          REAL          NOT NULL,
    [Discount_suma]       FLOAT (53)    NOT NULL,
    [Pro_forma]           BINARY (1)    NOT NULL,
    [Tip_miscare]         CHAR (1)      NOT NULL,
    [Numar_DVI]           VARCHAR (30)  NOT NULL,
    [Cont_factura]        VARCHAR (20)  NULL,
    [Data_facturii]       DATETIME2 (0) NOT NULL,
    [Data_scadentei]      DATETIME2 (0) NOT NULL,
    [Jurnal]              VARCHAR (20)  NULL,
    [Numar_pozitii]       INT           NOT NULL,
    [Stare]               SMALLINT      NOT NULL,
    [detalii]             XML           NULL,
    [idplaja]             INT           NULL,
    CONSTRAINT [FK__doc__idplaja__477F1AB8] FOREIGN KEY ([idplaja]) REFERENCES [dbo].[docfiscale] ([Id])
);


GO
CREATE UNIQUE CLUSTERED INDEX [Principal]
    ON [dbo].[doc]([Subunitate] ASC, [Tip] ASC, [Data] ASC, [Numar] ASC);


GO
CREATE NONCLUSTERED INDEX [unic]
    ON [dbo].[doc]([Subunitate] ASC, [Tip] ASC, [Data] ASC, [Numar] ASC, [Jurnal] ASC);


GO
CREATE NONCLUSTERED INDEX [Facturare]
    ON [dbo].[doc]([Subunitate] ASC, [Cod_tert] ASC, [Factura] ASC, [Tip] ASC, [Pro_forma] ASC);


GO
CREATE NONCLUSTERED INDEX [Numar]
    ON [dbo].[doc]([Numar] ASC);


GO
CREATE NONCLUSTERED INDEX [Punct_livrare]
    ON [dbo].[doc]([Subunitate] ASC, [Cod_tert] ASC, [Gestiune_primitoare] ASC, [Tip] ASC, [Numar] ASC);


GO
CREATE NONCLUSTERED INDEX [missing_index_262]
    ON [dbo].[doc]([Subunitate] ASC, [Tip] ASC, [Factura] ASC);


GO
CREATE NONCLUSTERED INDEX [missing_index_1257]
    ON [dbo].[doc]([Cod_tert] ASC, [Factura] ASC);


GO
CREATE NONCLUSTERED INDEX [missing_index_1462]
    ON [dbo].[doc]([Subunitate] ASC, [Tip] ASC, [Contractul] ASC, [Stare] ASC);


GO
CREATE NONCLUSTERED INDEX [missing_index_1223]
    ON [dbo].[doc]([Tip] ASC, [Cod_tert] ASC, [Data_facturii] ASC)
    INCLUDE([Subunitate], [Numar], [Data], [Factura], [Contractul], [Gestiune_primitoare], [Valoare], [Tva_22], [Numar_DVI], [Data_scadentei]);


GO
CREATE NONCLUSTERED INDEX [missing_index_1237]
    ON [dbo].[doc]([Tip] ASC, [Cod_tert] ASC, [Data] ASC)
    INCLUDE([Subunitate], [Numar], [Factura], [Contractul], [Gestiune_primitoare], [Valoare], [Tva_22], [Numar_DVI], [Data_facturii], [Data_scadentei]);


GO
CREATE NONCLUSTERED INDEX [missing_index_1225]
    ON [dbo].[doc]([Tip] ASC, [Factura] ASC, [Data_facturii] ASC)
    INCLUDE([Subunitate], [Numar], [Data], [Cod_tert], [Contractul], [Gestiune_primitoare], [Valoare], [Tva_22], [Numar_DVI], [Data_scadentei]);


GO
CREATE NONCLUSTERED INDEX [missing_index_1239]
    ON [dbo].[doc]([Tip] ASC, [Data] ASC, [Factura] ASC)
    INCLUDE([Subunitate], [Numar], [Cod_tert], [Contractul], [Gestiune_primitoare], [Valoare], [Tva_22], [Numar_DVI], [Data_facturii], [Data_scadentei]);


GO
CREATE NONCLUSTERED INDEX [missing_index_1009]
    ON [dbo].[doc]([Cod_tert] ASC, [Factura] ASC, [Data_facturii] ASC)
    INCLUDE([Gestiune_primitoare]);


GO
CREATE NONCLUSTERED INDEX [missing_index_1314]
    ON [dbo].[doc]([Cod_tert] ASC, [Gestiune_primitoare] ASC, [Tip] ASC, [Data] ASC)
    INCLUDE([Subunitate], [Numar]);


GO
CREATE NONCLUSTERED INDEX [missing_index_1319]
    ON [dbo].[doc]([Cod_tert] ASC, [Tip] ASC, [Data] ASC)
    INCLUDE([Subunitate], [Numar], [Gestiune_primitoare]);


GO
CREATE NONCLUSTERED INDEX [missing_index_1764]
    ON [dbo].[doc]([Tip] ASC, [Factura] ASC);


GO
CREATE NONCLUSTERED INDEX [missing_index_1004]
    ON [dbo].[doc]([Subunitate] ASC, [Cod_tert] ASC)
    INCLUDE([Factura], [Gestiune_primitoare]);


GO
CREATE NONCLUSTERED INDEX [missing_index_4027]
    ON [dbo].[doc]([Subunitate] ASC, [Tip] ASC, [Cod_tert] ASC, [Data] ASC)
    INCLUDE([Numar], [Cod_gestiune], [Factura], [Contractul], [Loc_munca], [Comanda], [Gestiune_primitoare], [Valuta], [Curs], [Valoare], [Tva_11], [Tva_22], [Valoare_valuta], [Cota_TVA], [Discount_p], [Discount_suma], [Pro_forma], [Tip_miscare], [Numar_DVI], [Cont_factura], [Data_facturii], [Data_scadentei], [Jurnal], [Numar_pozitii], [Stare]);


GO
CREATE NONCLUSTERED INDEX [missing_index_867]
    ON [dbo].[doc]([Subunitate] ASC, [Tip] ASC, [Cod_tert] ASC, [Numar] ASC, [Data] ASC)
    INCLUDE([Cod_gestiune], [Factura], [Contractul], [Loc_munca], [Comanda], [Gestiune_primitoare], [Valuta], [Curs], [Valoare], [Tva_11], [Tva_22], [Valoare_valuta], [Cota_TVA], [Discount_p], [Discount_suma], [Pro_forma], [Tip_miscare], [Numar_DVI], [Cont_factura], [Data_facturii], [Data_scadentei], [Jurnal], [Numar_pozitii], [Stare]);


GO
CREATE NONCLUSTERED INDEX [missing_index_794]
    ON [dbo].[doc]([Subunitate] ASC, [Tip] ASC, [Loc_munca] ASC, [Data] ASC, [Jurnal] ASC)
    INCLUDE([Numar], [Cod_gestiune], [Cod_tert], [Factura], [Contractul], [Comanda], [Gestiune_primitoare], [Valuta], [Curs], [Valoare], [Tva_11], [Tva_22], [Valoare_valuta], [Cota_TVA], [Discount_p], [Discount_suma], [Pro_forma], [Tip_miscare], [Numar_DVI], [Cont_factura], [Data_facturii], [Data_scadentei], [Numar_pozitii], [Stare]);


GO
CREATE NONCLUSTERED INDEX [missing_index_46]
    ON [dbo].[doc]([Tip] ASC)
    INCLUDE([Numar], [Cod_gestiune]);


GO
CREATE NONCLUSTERED INDEX [missing_index_1720]
    ON [dbo].[doc]([Subunitate] ASC, [Tip] ASC, [Cod_gestiune] ASC, [Data] ASC)
    INCLUDE([Numar], [Cod_tert], [Factura], [Contractul], [Loc_munca], [Comanda], [Gestiune_primitoare], [Valuta], [Curs], [Valoare], [Tva_11], [Tva_22], [Valoare_valuta], [Cota_TVA], [Discount_p], [Discount_suma], [Pro_forma], [Tip_miscare], [Numar_DVI], [Cont_factura], [Data_facturii], [Data_scadentei], [Jurnal], [Numar_pozitii], [Stare]);


GO
CREATE NONCLUSTERED INDEX [missing_index_2021]
    ON [dbo].[doc]([Subunitate] ASC, [Tip] ASC, [Cod_gestiune] ASC, [Numar] ASC, [Data] ASC)
    INCLUDE([Cod_tert], [Factura], [Contractul], [Loc_munca], [Comanda], [Gestiune_primitoare], [Valuta], [Curs], [Valoare], [Tva_11], [Tva_22], [Valoare_valuta], [Cota_TVA], [Discount_p], [Discount_suma], [Pro_forma], [Tip_miscare], [Numar_DVI], [Cont_factura], [Data_facturii], [Data_scadentei], [Jurnal], [Numar_pozitii], [Stare]);


GO
CREATE NONCLUSTERED INDEX [missing_index_2013]
    ON [dbo].[doc]([Tip] ASC, [Data] ASC)
    INCLUDE([Subunitate], [Numar], [Cod_tert], [Factura], [Gestiune_primitoare], [Cont_factura]);


GO
CREATE NONCLUSTERED INDEX [missing_index_225]
    ON [dbo].[doc]([Subunitate] ASC, [Tip] ASC, [Cod_gestiune] ASC, [Data] ASC)
    INCLUDE([Numar], [Cod_tert], [Factura], [Contractul], [Loc_munca], [Comanda], [Gestiune_primitoare], [Valuta], [Curs], [Valoare], [Tva_11], [Tva_22], [Valoare_valuta], [Cota_TVA], [Discount_p], [Discount_suma], [Pro_forma], [Tip_miscare], [Numar_DVI], [Cont_factura], [Data_facturii], [Data_scadentei], [Jurnal], [Numar_pozitii], [Stare]);


GO
CREATE NONCLUSTERED INDEX [missing_index_146]
    ON [dbo].[doc]([Tip] ASC)
    INCLUDE([Numar], [Cod_gestiune]);


GO
CREATE NONCLUSTERED INDEX [missing_index_307]
    ON [dbo].[doc]([Subunitate] ASC, [Tip] ASC, [Cod_gestiune] ASC, [Cod_tert] ASC, [Data] ASC)
    INCLUDE([Numar], [Factura], [Contractul], [Loc_munca], [Comanda], [Gestiune_primitoare], [Valuta], [Curs], [Valoare], [Tva_11], [Tva_22], [Valoare_valuta], [Cota_TVA], [Discount_p], [Discount_suma], [Pro_forma], [Tip_miscare], [Numar_DVI], [Cont_factura], [Data_facturii], [Data_scadentei], [Jurnal], [Numar_pozitii], [Stare]);

