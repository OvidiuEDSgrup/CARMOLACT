CREATE TABLE [dbo].[SelectieFacturiPtCompensari] (
    [id]         INT             IDENTITY (1, 1) NOT NULL,
    [utilizator] VARCHAR (20)    NOT NULL,
    [tip]        VARCHAR (1)     NOT NULL,
    [tert]       VARCHAR (20)    NOT NULL,
    [factura]    VARCHAR (200)   NOT NULL,
    [suma]       DECIMAL (15, 2) NOT NULL,
    [valuta]     VARCHAR (3)     NULL,
    [curs]       DECIMAL (15, 2) NULL,
    CONSTRAINT [PK_SelectieFacturiPtCompensari] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [pSelectieFacturiPtCompensari]
    ON [dbo].[SelectieFacturiPtCompensari]([utilizator] ASC, [tip] ASC, [tert] ASC, [factura] ASC);

