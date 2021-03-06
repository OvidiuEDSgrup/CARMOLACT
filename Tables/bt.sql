﻿CREATE TABLE [dbo].[bt] (
    [Casa_de_marcat]            SMALLINT     NOT NULL,
    [Factura_chitanta]          BIT          NOT NULL,
    [Numar_bon]                 INT          NOT NULL,
    [Numar_linie]               SMALLINT     NOT NULL,
    [Data]                      DATETIME     NOT NULL,
    [Ora]                       CHAR (6)     NOT NULL,
    [Tip]                       CHAR (2)     NOT NULL,
    [Vinzator]                  CHAR (10)    NOT NULL,
    [Client]                    CHAR (13)    NOT NULL,
    [Cod_citit_de_la_tastatura] CHAR (20)    NOT NULL,
    [CodPLU]                    CHAR (20)    NOT NULL,
    [Cod_produs]                CHAR (20)    NOT NULL,
    [Categorie]                 SMALLINT     NOT NULL,
    [UM]                        SMALLINT     NOT NULL,
    [Cantitate]                 FLOAT (53)   NOT NULL,
    [Cota_TVA]                  REAL         NOT NULL,
    [Tva]                       FLOAT (53)   NOT NULL,
    [Pret]                      FLOAT (53)   NOT NULL,
    [Total]                     FLOAT (53)   NOT NULL,
    [Retur]                     BIT          NOT NULL,
    [Inregistrare_valida]       BIT          NOT NULL,
    [Operat]                    BIT          NOT NULL,
    [Numar_document_incasare]   CHAR (20)    NOT NULL,
    [Data_documentului]         DATETIME     NOT NULL,
    [Loc_de_munca]              CHAR (9)     NOT NULL,
    [Discount]                  FLOAT (53)   NOT NULL,
    [idAntetBon]                INT          NULL,
    [lm_real]                   VARCHAR (9)  NULL,
    [Comanda_asis]              VARCHAR (20) NULL,
    [Contract]                  VARCHAR (20) NULL,
    [Gestiune]                  AS           (rtrim([loc_de_munca])),
    CONSTRAINT [FK_Bt_antetBonturi] FOREIGN KEY ([idAntetBon]) REFERENCES [dbo].[antetBonuri] ([IdAntetBon])
);


GO
CREATE UNIQUE CLUSTERED INDEX [Numar_bon_Tip]
    ON [dbo].[bt]([Casa_de_marcat] ASC, [Data] ASC, [Vinzator] ASC, [Numar_bon] ASC, [Numar_linie] ASC);

