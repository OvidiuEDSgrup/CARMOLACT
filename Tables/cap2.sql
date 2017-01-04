CREATE TABLE [dbo].[cap2] (
    [Data]       DATETIME   NOT NULL,
    [LD]         SMALLINT   NOT NULL,
    [AD]         SMALLINT   NOT NULL,
    [DEN]        CHAR (30)  NOT NULL,
    [CF]         FLOAT (53) NOT NULL,
    [CFANT]      FLOAT (53) NOT NULL,
    [CNPA]       FLOAT (53) NOT NULL,
    [CNPAANT]    FLOAT (53) NOT NULL,
    [LOC]        CHAR (30)  NOT NULL,
    [STR]        CHAR (30)  NOT NULL,
    [NRA]        CHAR (10)  NOT NULL,
    [BL]         CHAR (10)  NOT NULL,
    [SC]         CHAR (4)   NOT NULL,
    [ET]         CHAR (2)   NOT NULL,
    [AP]         CHAR (4)   NOT NULL,
    [SECT]       SMALLINT   NOT NULL,
    [JUD]        CHAR (15)  NOT NULL,
    [TEL]        INT        NOT NULL,
    [FAX]        INT        NOT NULL,
    [MAIL]       CHAR (30)  NOT NULL,
    [FS]         FLOAT (53) NOT NULL,
    [DED80REC]   FLOAT (53) NOT NULL,
    [DED80RES]   FLOAT (53) NOT NULL,
    [DED85REC]   FLOAT (53) NOT NULL,
    [DED85RES]   FLOAT (53) NOT NULL,
    [DED58REC]   FLOAT (53) NOT NULL,
    [DED58RES]   FLOAT (53) NOT NULL,
    [DED116REC]  FLOAT (53) NOT NULL,
    [DED116RES]  FLOAT (53) NOT NULL,
    [RED9394REC] FLOAT (53) NOT NULL,
    [RED9394RES] FLOAT (53) NOT NULL,
    [NUMEA]      CHAR (15)  NOT NULL,
    [PRENUMEA]   CHAR (15)  NOT NULL,
    [FUNCTIA]    CHAR (15)  NOT NULL,
    [MOD]        CHAR (1)   NOT NULL,
    [NRD]        SMALLINT   NOT NULL,
    [REC]        CHAR (1)   NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [CAP11]
    ON [dbo].[cap2]([Data] ASC);

