CREATE TABLE [dbo].[tmpFundamentareLansare] (
    [utilizator] VARCHAR (20)    NULL,
    [denumire]   VARCHAR (80)    NULL,
    [cod]        VARCHAR (20)    NULL,
    [necesar]    DECIMAL (15, 6) NULL,
    [Tip]        VARCHAR (20)    NULL,
    [inProd]     DECIMAL (15, 6) NULL,
    [lans]       DECIMAL (15, 6) NULL,
    [cont]       VARCHAR (20)    NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_tmpFundamentareLansare]
    ON [dbo].[tmpFundamentareLansare]([utilizator] ASC, [cod] ASC);

