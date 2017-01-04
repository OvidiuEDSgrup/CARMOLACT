﻿CREATE TABLE [dbo].[TEMP_3527840] (
    [FLD1] BINARY (50) NOT NULL,
    [FLD2] CHAR (9)    NOT NULL,
    [FLD3] CHAR (13)   NOT NULL,
    [FLD4] CHAR (25)   NOT NULL,
    [FLD5] DATETIME    NOT NULL,
    [FLD6] CHAR (8)    NOT NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [KEY001TEMP_3527840]
    ON [dbo].[TEMP_3527840]([FLD2] ASC, [FLD3] ASC, [FLD4] ASC, [FLD5] ASC, [FLD6] ASC, [FLD1] ASC);

