CREATE TABLE [dbo].[selfactachit] (
    [HostID]     CHAR (8)   NOT NULL,
    [Subunitate] CHAR (9)   NOT NULL,
    [Tip]        BINARY (1) NOT NULL,
    [Tert]       CHAR (13)  NOT NULL,
    [Factura]    CHAR (20)  NOT NULL,
    [Selectat]   BIT        NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Principal]
    ON [dbo].[selfactachit]([HostID] ASC, [Subunitate] ASC, [Tip] ASC, [Factura] ASC, [Tert] ASC);


GO
CREATE NONCLUSTERED INDEX [Sub_Tert_Tip]
    ON [dbo].[selfactachit]([HostID] ASC, [Subunitate] ASC, [Tert] ASC, [Tip] ASC);


GO
CREATE NONCLUSTERED INDEX [missing_index_936]
    ON [dbo].[selfactachit]([HostID] ASC, [Factura] ASC, [Selectat] ASC)
    INCLUDE([Subunitate], [Tip], [Tert]);


GO
CREATE NONCLUSTERED INDEX [missing_index_955]
    ON [dbo].[selfactachit]([HostID] ASC, [Subunitate] ASC, [Tip] ASC, [Tert] ASC, [Selectat] ASC)
    INCLUDE([Factura]);


GO
CREATE NONCLUSTERED INDEX [missing_index_957]
    ON [dbo].[selfactachit]([HostID] ASC, [Selectat] ASC)
    INCLUDE([Subunitate], [Tip], [Tert], [Factura]);


GO
CREATE NONCLUSTERED INDEX [missing_index_951]
    ON [dbo].[selfactachit]([HostID] ASC, [Subunitate] ASC, [Selectat] ASC)
    INCLUDE([Tip], [Tert], [Factura]);

