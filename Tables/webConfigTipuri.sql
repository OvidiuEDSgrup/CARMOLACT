CREATE TABLE [dbo].[webConfigTipuri] (
    [Meniu]                VARCHAR (20)  NOT NULL,
    [Tip]                  VARCHAR (2)   NULL,
    [Subtip]               VARCHAR (2)   NULL,
    [Ordine]               INT           NULL,
    [Nume]                 VARCHAR (50)  NULL,
    [Descriere]            VARCHAR (500) NULL,
    [TextAdaugare]         VARCHAR (60)  NULL,
    [TextModificare]       VARCHAR (60)  NULL,
    [ProcDate]             VARCHAR (60)  NULL,
    [ProcScriere]          VARCHAR (60)  NULL,
    [ProcStergere]         VARCHAR (60)  NULL,
    [ProcDatePoz]          VARCHAR (60)  NULL,
    [ProcScrierePoz]       VARCHAR (60)  NULL,
    [ProcStergerePoz]      VARCHAR (60)  NULL,
    [Vizibil]              BIT           NULL,
    [Fel]                  VARCHAR (1)   NULL,
    [procPopulare]         VARCHAR (60)  NULL,
    [tasta]                VARCHAR (20)  NULL,
    [detalii]              XML           NULL,
    [ProcInchidereMacheta] VARCHAR (60)  NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [PrincwebConfigTipuri]
    ON [dbo].[webConfigTipuri]([Meniu] ASC, [Tip] ASC, [Subtip] ASC, [Ordine] ASC);

