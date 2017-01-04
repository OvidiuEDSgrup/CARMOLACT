CREATE TABLE [dbo].[cons_tmp] (
    [Numar]             CHAR (8)   NOT NULL,
    [Data]              DATETIME   NOT NULL,
    [Schimb]            FLOAT (53) NOT NULL,
    [Loc_de_munca]      CHAR (9)   NOT NULL,
    [Cod]               CHAR (20)  NOT NULL,
    [Intrari]           FLOAT (53) NOT NULL,
    [Normat]            FLOAT (53) NOT NULL,
    [Consum]            FLOAT (53) NOT NULL,
    [Stoc]              FLOAT (53) NOT NULL,
    [Numar_pozitie]     INT        NOT NULL,
    [Gest_mat]          CHAR (9)   NOT NULL,
    [Comanda]           CHAR (13)  NOT NULL,
    [Cod_produs]        CHAR (20)  NOT NULL,
    [Alfa1]             CHAR (20)  NOT NULL,
    [Alfa2]             CHAR (20)  NOT NULL,
    [Consum_repartizat] FLOAT (53) NOT NULL,
    [Consum_suplim]     FLOAT (53) NOT NULL,
    [Cod_tata]          CHAR (20)  NOT NULL,
    [Cod_inlocuit]      CHAR (20)  NOT NULL,
    [Nr_material]       INT        NOT NULL,
    [Rezerva]           CHAR (30)  NOT NULL,
    [Consum_unitar]     FLOAT (53) NOT NULL,
    [Utilizator]        CHAR (10)  NOT NULL,
    [Data_operarii]     DATETIME   NOT NULL,
    [Ora_operarii]      CHAR (6)   NOT NULL,
    [Val1]              FLOAT (53) NOT NULL,
    [Val2]              FLOAT (53) NOT NULL,
    [Data2]             DATETIME   NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Neccons1]
    ON [dbo].[cons_tmp]([Loc_de_munca] ASC, [Cod] ASC, [Data] DESC, [Schimb] DESC, [Numar_pozitie] DESC, [Numar] DESC, [Gest_mat] ASC, [Cod_tata] ASC, [Cod_inlocuit] ASC, [Nr_material] ASC, [Rezerva] ASC);


GO
CREATE NONCLUSTERED INDEX [Neccons2]
    ON [dbo].[cons_tmp]([Numar] ASC, [Data] ASC, [Cod] ASC, [Gest_mat] ASC, [Rezerva] ASC, [Numar_pozitie] ASC);


GO
CREATE NONCLUSTERED INDEX [Neccons3]
    ON [dbo].[cons_tmp]([Numar] ASC, [Data] ASC, [Comanda] ASC, [Cod_produs] ASC, [Cod] ASC, [Numar_pozitie] ASC);


GO
CREATE NONCLUSTERED INDEX [Neccons4]
    ON [dbo].[cons_tmp]([Numar] ASC, [Data] ASC, [Cod_produs] ASC, [Comanda] ASC, [Cod] ASC, [Numar_pozitie] ASC);

