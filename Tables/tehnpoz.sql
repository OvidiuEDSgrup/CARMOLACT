﻿CREATE TABLE [dbo].[tehnpoz] (
    [Cod_tehn]     CHAR (20)  NOT NULL,
    [Tip]          CHAR (1)   NOT NULL,
    [Cod]          CHAR (20)  NOT NULL,
    [Cod_operatie] CHAR (20)  NOT NULL,
    [Nr]           FLOAT (53) NOT NULL,
    [Subtip]       CHAR (1)   NOT NULL,
    [Supr]         FLOAT (53) NOT NULL,
    [Coef_consum]  FLOAT (53) NOT NULL,
    [Randament]    FLOAT (53) NOT NULL,
    [Specific]     FLOAT (53) NOT NULL,
    [Cod_inlocuit] CHAR (20)  NOT NULL,
    [Loc_munca]    CHAR (20)  NOT NULL,
    [Obs]          CHAR (200) NOT NULL,
    [Utilaj]       CHAR (20)  NOT NULL,
    [Timp_preg]    FLOAT (53) NOT NULL,
    [Timp_util]    FLOAT (53) NOT NULL,
    [Categ_salar]  CHAR (20)  NOT NULL,
    [Norma_timp]   FLOAT (53) NOT NULL,
    [Tarif_unitar] FLOAT (53) NOT NULL,
    [Lungime]      FLOAT (53) NOT NULL,
    [Latime]       FLOAT (53) NOT NULL,
    [Inaltime]     FLOAT (53) NOT NULL,
    [Comanda]      CHAR (20)  NOT NULL,
    [Alfa1]        CHAR (20)  NOT NULL,
    [Alfa2]        CHAR (20)  NOT NULL,
    [Alfa3]        CHAR (20)  NOT NULL,
    [Alfa4]        CHAR (20)  NOT NULL,
    [Alfa5]        CHAR (20)  NOT NULL,
    [Val1]         FLOAT (53) NOT NULL,
    [Val2]         FLOAT (53) NOT NULL,
    [Val3]         FLOAT (53) NOT NULL,
    [Val4]         FLOAT (53) NOT NULL,
    [Val5]         FLOAT (53) NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Tehnpoz1]
    ON [dbo].[tehnpoz]([Cod_tehn] ASC, [Tip] ASC, [Nr] ASC, [Cod] ASC, [Loc_munca] ASC);


GO
CREATE NONCLUSTERED INDEX [Tehnpoz2]
    ON [dbo].[tehnpoz]([Cod_tehn] ASC, [Tip] ASC, [Cod] ASC, [Loc_munca] ASC);


GO
CREATE NONCLUSTERED INDEX [Tehnpoz3]
    ON [dbo].[tehnpoz]([Cod_tehn] ASC, [Tip] ASC, [Cod_inlocuit] ASC);


GO
CREATE NONCLUSTERED INDEX [Tehnpoz4]
    ON [dbo].[tehnpoz]([Cod_tehn] ASC, [Tip] ASC, [Cod_inlocuit] DESC);


GO
CREATE NONCLUSTERED INDEX [Tehnpoz5]
    ON [dbo].[tehnpoz]([Cod_tehn] ASC, [Tip] ASC, [Nr] ASC);


GO
CREATE NONCLUSTERED INDEX [Tehnpoz6]
    ON [dbo].[tehnpoz]([Cod_tehn] ASC, [Tip] ASC, [Cod] ASC);


GO
CREATE NONCLUSTERED INDEX [Tehnpoz7]
    ON [dbo].[tehnpoz]([Cod_tehn] ASC, [Tip] ASC, [Lungime] ASC, [Latime] ASC, [Nr] ASC);


GO
CREATE NONCLUSTERED INDEX [Tehnpoz9]
    ON [dbo].[tehnpoz]([Tip] ASC, [Cod] ASC, [Nr] ASC, [Cod_tehn] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Tehnpoz11]
    ON [dbo].[tehnpoz]([Cod_tehn] ASC, [Tip] ASC, [Loc_munca] ASC, [Cod] ASC, [Nr] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Tehnpoz12]
    ON [dbo].[tehnpoz]([Cod_tehn] ASC, [Tip] ASC, [Loc_munca] ASC, [Nr] ASC, [Cod] ASC);


GO
CREATE NONCLUSTERED INDEX [Tehnpoz13]
    ON [dbo].[tehnpoz]([Tip] ASC, [Subtip] ASC, [Cod] ASC, [Nr] ASC, [Cod_tehn] ASC);


GO
CREATE NONCLUSTERED INDEX [Tehnpoz14]
    ON [dbo].[tehnpoz]([Cod_tehn] ASC, [Tip] ASC, [Subtip] ASC, [Cod] ASC, [Nr] ASC);

