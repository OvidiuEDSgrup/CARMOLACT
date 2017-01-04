CREATE TABLE [dbo].[tmpExtinfop] (
    [HostID]   CHAR (10)  NULL,
    [Marca]    CHAR (6)   NOT NULL,
    [Cod_inf]  CHAR (13)  NOT NULL,
    [Val_inf]  CHAR (80)  NOT NULL,
    [Data_inf] DATETIME   NOT NULL,
    [Procent]  FLOAT (53) NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Marca_cod]
    ON [dbo].[tmpExtinfop]([HostID] ASC, [Marca] ASC, [Cod_inf] ASC, [Val_inf] ASC, [Data_inf] ASC);

