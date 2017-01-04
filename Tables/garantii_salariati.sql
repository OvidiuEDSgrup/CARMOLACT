CREATE TABLE [dbo].[garantii_salariati] (
    [marca]       VARCHAR (6)  NULL,
    [data]        DATETIME     NULL,
    [nr_salarii]  INT          NULL,
    [procent]     FLOAT (53)   NULL,
    [banca]       VARCHAR (30) NULL,
    [cont_bancar] VARCHAR (30) NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [unic]
    ON [dbo].[garantii_salariati]([marca] ASC, [data] ASC);

