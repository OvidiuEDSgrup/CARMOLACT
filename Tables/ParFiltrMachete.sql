CREATE TABLE [dbo].[ParFiltrMachete] (
    [Terminal]         CHAR (8) NOT NULL,
    [Producator]       CHAR (9) NOT NULL,
    [Centru_colectare] CHAR (9) NOT NULL,
    [Data_operarii]    DATETIME NOT NULL,
    [Ora_operarii]     CHAR (6) NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Unic]
    ON [dbo].[ParFiltrMachete]([Terminal] ASC);

