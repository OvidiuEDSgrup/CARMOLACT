CREATE TABLE [dbo].[ConfigurareContareImobilizari] (
    [tip]                        VARCHAR (2)  NULL,
    [subtip]                     VARCHAR (2)  NULL,
    [codcl]                      VARCHAR (20) NULL,
    [cont_imobilizari]           VARCHAR (20) NULL,
    [cont_amortizare]            VARCHAR (20) NULL,
    [cont_cheltuieli_amortizare] VARCHAR (20) NULL,
    [cont_corespondent]          VARCHAR (20) NULL,
    [cont_factura]               VARCHAR (20) NULL,
    [cont_cheltuieli]            VARCHAR (20) NULL,
    [cont_venituri]              VARCHAR (20) NULL,
    [analitic21ca]               INT          NULL,
    [nrord]                      INT          NULL,
    [idPozitie]                  INT          IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [PK_idPozitieCCI] PRIMARY KEY NONCLUSTERED ([idPozitie] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [idx_ConfigurareContare]
    ON [dbo].[ConfigurareContareImobilizari]([tip] ASC, [subtip] ASC, [codcl] ASC, [cont_imobilizari] ASC, [nrord] ASC);

