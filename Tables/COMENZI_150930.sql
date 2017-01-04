CREATE TABLE [dbo].[COMENZI_150930] (
    [Subunitate]              CHAR (9)   NOT NULL,
    [Comanda]                 CHAR (20)  NOT NULL,
    [Tip_comanda]             CHAR (1)   NOT NULL,
    [Descriere]               CHAR (80)  NOT NULL,
    [Data_lansarii]           DATETIME   NOT NULL,
    [Data_inchiderii]         DATETIME   NOT NULL,
    [Starea_comenzii]         CHAR (1)   NOT NULL,
    [Grup_de_comenzi]         BIT        NOT NULL,
    [Loc_de_munca]            CHAR (9)   NOT NULL,
    [Numar_de_inventar]       CHAR (13)  NOT NULL,
    [Beneficiar]              CHAR (13)  NOT NULL,
    [Loc_de_munca_beneficiar] CHAR (9)   NOT NULL,
    [Comanda_beneficiar]      CHAR (20)  NOT NULL,
    [Art_calc_benef]          CHAR (200) NOT NULL,
    [detalii]                 XML        NULL
);

