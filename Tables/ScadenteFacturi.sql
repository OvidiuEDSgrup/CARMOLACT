CREATE TABLE [dbo].[ScadenteFacturi] (
    [id]             INT             IDENTITY (1, 1) NOT NULL,
    [tip]            VARCHAR (1)     NOT NULL,
    [tert]           VARCHAR (20)    NOT NULL,
    [factura]        VARCHAR (200)   NOT NULL,
    [data_scadentei] DATETIME        NOT NULL,
    [suma]           DECIMAL (15, 2) NOT NULL,
    [tertf]          VARCHAR (20)    NULL,
    [facturaf]       VARCHAR (20)    NULL,
    [sumaf]          DECIMAL (15, 2) NULL,
    CONSTRAINT [PK_idScadenteFacturi] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [pScadenteFacturi]
    ON [dbo].[ScadenteFacturi]([tip] ASC, [tert] ASC, [factura] ASC);

