﻿CREATE TABLE [dbo].[TEMP_6275678] (
    [FLD1] BINARY (70) NOT NULL,
    [FLD2] CHAR (9)    NOT NULL,
    [FLD3] CHAR (13)   NOT NULL,
    [FLD4] DATETIME    NOT NULL,
    [FLD5] CHAR (10)   NOT NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [KEY001TEMP_6275678]
    ON [dbo].[TEMP_6275678]([FLD2] ASC, [FLD3] ASC, [FLD4] ASC, [FLD5] ASC, [FLD1] ASC);

