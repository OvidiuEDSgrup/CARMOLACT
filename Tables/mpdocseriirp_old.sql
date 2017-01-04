CREATE TABLE [dbo].[mpdocseriirp_old] (
    [Subunitate]       CHAR (9)    NOT NULL,
    [Tip]              VARCHAR (2) NOT NULL,
    [Numar]            CHAR (8)    NOT NULL,
    [Data]             DATETIME    NOT NULL,
    [Gestiune]         CHAR (9)    NOT NULL,
    [Cod]              CHAR (20)   NOT NULL,
    [cod_intrare]      CHAR (13)   NOT NULL,
    [Serie]            CHAR (20)   NOT NULL,
    [cantitate]        FLOAT (53)  NOT NULL,
    [tip_miscare]      CHAR (1)    NOT NULL,
    [numar_pozitie]    INT         NOT NULL,
    [Nr_pozitie_serie] INT         IDENTITY (1, 1) NOT NULL
);

