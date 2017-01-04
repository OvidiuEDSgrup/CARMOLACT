CREATE TABLE [dbo].[nomspec] (
    [Tert]        CHAR (14)  NOT NULL,
    [Cod]         CHAR (20)  NOT NULL,
    [Cod_special] CHAR (20)  NOT NULL,
    [Denumire]    CHAR (30)  NOT NULL,
    [Pret]        FLOAT (53) NOT NULL,
    [Pret_valuta] FLOAT (53) NOT NULL,
    [Discount]    REAL       NOT NULL,
    [detalii]     XML        NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Nomsp]
    ON [dbo].[nomspec]([Tert] ASC, [Cod_special] ASC, [Cod] ASC);


GO
CREATE NONCLUSTERED INDEX [Nomsp2]
    ON [dbo].[nomspec]([Tert] ASC, [Cod] ASC);


GO
CREATE NONCLUSTERED INDEX [Nomsp3]
    ON [dbo].[nomspec]([Tert] ASC, [Denumire] ASC);


GO
CREATE NONCLUSTERED INDEX [missing_index_247]
    ON [dbo].[nomspec]([Pret] ASC)
    INCLUDE([Tert], [Cod]);


GO
CREATE STATISTICS [_dta_stat_933578364_2_3]
    ON [dbo].[nomspec]([Cod], [Cod_special]);

