CREATE TABLE [dbo].[XMLFormular] (
    [Numar_formular]     CHAR (9)       NOT NULL,
    [Versiune]           INT            NOT NULL,
    [Continut]           NVARCHAR (MAX) NULL,
    [Nume_fisier]        VARCHAR (500)  NULL,
    [Last_modified_date] VARCHAR (500)  NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [PXMLFormular]
    ON [dbo].[XMLFormular]([Numar_formular] ASC, [Nume_fisier] ASC);

