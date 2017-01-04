CREATE TABLE [dbo].[tmpDenD394] (
    [rand_decl]        VARCHAR (20) NULL,
    [denumire_macheta] CHAR (800)   NULL,
    [denumire_raport]  CHAR (800)   NULL,
    [ordine]           SMALLINT     NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Principal]
    ON [dbo].[tmpDenD394]([rand_decl] ASC);

