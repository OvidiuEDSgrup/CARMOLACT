CREATE TABLE [dbo].[fisaAmortizare] (
    [data]            DATETIME     NULL,
    [nrinv]           VARCHAR (20) NULL,
    [cantitate]       FLOAT (53)   NULL,
    [gestiune]        VARCHAR (9)  NULL,
    [loc_de_munca]    VARCHAR (9)  NULL,
    [comanda]         VARCHAR (20) NULL,
    [valinv]          FLOAT (53)   NULL,
    [valam]           FLOAT (53)   NULL,
    [valamned]        FLOAT (53)   NULL,
    [amlun]           FLOAT (53)   NULL,
    [amlunned]        FLOAT (53)   NULL,
    [iesit]           BIT          NULL,
    [contImobilizari] VARCHAR (40) NULL,
    [contAmortizare]  VARCHAR (40) NULL,
    [contCheltuiala]  VARCHAR (40) NULL,
    [reevaluare]      INT          DEFAULT ((0)) NOT NULL,
    [rezreev]         FLOAT (53)   NULL,
    [natura]          VARCHAR (1)  NULL,
    [patrimoniu]      VARCHAR (1)  NULL,
    [durata]          INT          NULL,
    [nrluniramase]    INT          NULL,
    [idIntrare]       INT          NULL,
    [difrezreev]      FLOAT (53)   NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Principal]
    ON [dbo].[fisaAmortizare]([data] ASC, [nrinv] ASC, [idIntrare] ASC);

