CREATE TABLE [dbo].[CheltLM] (
    [Loc_de_munca]      CHAR (9)   NOT NULL,
    [Denumire]          CHAR (30)  NOT NULL,
    [Lm]                FLOAT (53) NOT NULL,
    [Valoare]           FLOAT (53) NOT NULL,
    [ventot]            FLOAT (53) NOT NULL,
    [somaj_1]           FLOAT (53) NOT NULL,
    [CCI]               FLOAT (53) NOT NULL,
    [as_plun]           FLOAT (53) NOT NULL,
    [fdrisc]            FLOAT (53) NOT NULL,
    [camm]              FLOAT (53) NOT NULL,
    [penssup]           FLOAT (53) NOT NULL,
    [somaj]             FLOAT (53) NOT NULL,
    [impoz]             FLOAT (53) NOT NULL,
    [assal]             FLOAT (53) NOT NULL,
    [as_cas]            FLOAT (53) NOT NULL,
    [cas]               FLOAT (53) NOT NULL,
    [cm_cas]            FLOAT (53) NOT NULL,
    [cm_unit]           FLOAT (53) NOT NULL,
    [ven_net]           FLOAT (53) NOT NULL,
    [Fond_de_garantare] FLOAT (53) NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Unic]
    ON [dbo].[CheltLM]([Loc_de_munca] ASC);

