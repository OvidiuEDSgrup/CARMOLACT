﻿CREATE TABLE [dbo].[webTraduceri] (
    [Limba]        VARCHAR (50)  NOT NULL,
    [Textoriginal] VARCHAR (500) NOT NULL,
    [Texttradus]   VARCHAR (500) NOT NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [PwebTraduceri]
    ON [dbo].[webTraduceri]([Limba] ASC, [Textoriginal] ASC);

