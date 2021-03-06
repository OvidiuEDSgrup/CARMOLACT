﻿CREATE TABLE [dbo].[MPdocndseriirp_old] (
    [Tip]              CHAR (2)   NOT NULL,
    [Numar]            CHAR (20)  NOT NULL,
    [Data]             DATETIME   NOT NULL,
    [Schimb]           FLOAT (53) NOT NULL,
    [Sarja]            FLOAT (53) NOT NULL,
    [Ordonare]         FLOAT (53) NOT NULL,
    [Loc_munca]        CHAR (20)  NOT NULL,
    [Utilaj]           CHAR (20)  NOT NULL,
    [Cod]              CHAR (20)  NOT NULL,
    [Intrari]          FLOAT (53) NOT NULL,
    [Normat]           FLOAT (53) NOT NULL,
    [Efectiv]          FLOAT (53) NOT NULL,
    [Stoc]             FLOAT (53) NOT NULL,
    [Nr_pozitie]       INT        NOT NULL,
    [Nr_pozitie_DN]    INT        NOT NULL,
    [Gestiune]         CHAR (20)  NOT NULL,
    [Comanda]          CHAR (20)  NOT NULL,
    [Cod_produs]       CHAR (20)  NOT NULL,
    [Alfa1]            CHAR (20)  NOT NULL,
    [Lot]              CHAR (20)  NOT NULL,
    [Locatie]          CHAR (30)  NOT NULL,
    [Repartizat]       FLOAT (53) NOT NULL,
    [Abateri]          FLOAT (53) NOT NULL,
    [Cod_parinte]      CHAR (20)  NOT NULL,
    [Cod_inlocuit]     CHAR (20)  NOT NULL,
    [Nr_mat]           FLOAT (53) NOT NULL,
    [Alfa2]            CHAR (30)  NOT NULL,
    [Specific]         FLOAT (53) NOT NULL,
    [Utilizator]       CHAR (10)  NOT NULL,
    [Data_operarii]    DATETIME   NOT NULL,
    [Ora_operarii]     CHAR (6)   NOT NULL,
    [Val1]             FLOAT (53) NOT NULL,
    [Val2]             FLOAT (53) NOT NULL,
    [Pret]             FLOAT (53) NOT NULL,
    [Data_expirarii]   DATETIME   NOT NULL,
    [Serie]            CHAR (30)  DEFAULT ('') NOT NULL,
    [Nr_pozitie_serie] INT        IDENTITY (1, 1) NOT NULL
);

