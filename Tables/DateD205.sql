CREATE TABLE [dbo].[DateD205] (
    [An]                 SMALLINT    NOT NULL,
    [Tip_venit]          CHAR (2)    NOT NULL,
    [Tip_impozit]        CHAR (1)    NOT NULL,
    [Marca]              CHAR (6)    NOT NULL,
    [CNP]                CHAR (13)   NOT NULL,
    [Nume]               CHAR (100)  NOT NULL,
    [Tip_functie]        CHAR (1)    NOT NULL,
    [Venit_brut]         FLOAT (53)  NOT NULL,
    [Deduceri_personale] FLOAT (53)  NOT NULL,
    [Deduceri_alte]      FLOAT (53)  NOT NULL,
    [Baza_impozit]       FLOAT (53)  NOT NULL,
    [Impozit]            FLOAT (53)  NOT NULL,
    [Loc_de_munca]       VARCHAR (9) DEFAULT ('') NOT NULL,
    [Venit_net]          FLOAT (53)  NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Principal]
    ON [dbo].[DateD205]([An] ASC, [Loc_de_munca] ASC, [Tip_venit] ASC, [Tip_impozit] ASC, [Marca] ASC, [CNP] ASC, [Tip_functie] ASC);

