CREATE TABLE [dbo].[bp] (
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
    [IdAntetBon]                INT          NULL,
    [IdPozitie]                 INT          IDENTITY (1, 1) NOT NULL,
    [lm_real]                   VARCHAR (9)  NULL,
    [Comanda_asis]              VARCHAR (20) NULL,
    [Contract]                  VARCHAR (20) NULL,
    [Gestiune]                  AS           (rtrim([loc_de_munca])),
    CONSTRAINT [FK_Bp_antetBonturi] FOREIGN KEY ([IdAntetBon]) REFERENCES [dbo].[antetBonuri] ([IdAntetBon])
);


GO
CREATE UNIQUE CLUSTERED INDEX [Numar_bon_Tip]
    ON [dbo].[bp]([Data] ASC, [Casa_de_marcat] ASC, [Vinzator] ASC, [Numar_bon] ASC, [Numar_linie] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_PentruFacturare]
    ON [dbo].[bp]([Casa_de_marcat] ASC, [Data] ASC, [Numar_bon] ASC)
    INCLUDE([Tip], [Cantitate], [Cota_TVA], [Tva], [Pret], [Total], [Discount]);


GO
CREATE NONCLUSTERED INDEX [IX_antetBon]
    ON [dbo].[bp]([IdAntetBon] ASC)
    INCLUDE([Tip], [Cod_produs], [Cantitate], [Tva], [Pret], [Total], [Discount], [Cota_TVA]);


GO


create TRIGGER [dbo].[_sterg_bp] ON [dbo].[bp] 
FOR  DELETE 
AS


begin 

insert into YSObpsters (Casa_de_marcat, Factura_chitanta, Numar_bon, numar_linie, Data, Ora, Tip, Vinzator, Client, Cod_citit_de_la_tastatura, CodPLU, Cod_produs, Categorie,
UM, Cantitate, Cota_TVA, Tva, Pret, Total, Retur, Inregistrare_valida, Operat, Numar_document_incasare, Data_documentului, Loc_de_munca, Discount)
select Casa_de_marcat, Factura_chitanta, Numar_bon, numar_linie, Data, Ora, Tip, Vinzator, Client, Cod_citit_de_la_tastatura, CodPLU, Cod_produs, Categorie,
UM, Cantitate, Cota_TVA, Tva, Pret, Total, Retur, Inregistrare_valida, Operat, Numar_document_incasare, Data_documentului, Loc_de_munca, Discount 
 from deleted

end

