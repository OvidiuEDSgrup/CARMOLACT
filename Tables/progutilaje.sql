﻿CREATE TABLE [dbo].[progutilaje] (
    [hostid]    CHAR (8)  NOT NULL,
    [masina]    CHAR (20) NOT NULL,
    [int1]      INT       NOT NULL,
    [comanda1]  CHAR (13) NOT NULL,
    [tip1]      CHAR (2)  NOT NULL,
    [nr_fisa1]  CHAR (20) NOT NULL,
    [data1]     DATETIME  NOT NULL,
    [nr_poz1]   INT       NOT NULL,
    [start1]    REAL      NOT NULL,
    [stop1]     REAL      NOT NULL,
    [int2]      INT       NOT NULL,
    [comanda2]  CHAR (13) NOT NULL,
    [tip2]      CHAR (2)  NOT NULL,
    [nr_fisa2]  CHAR (20) NOT NULL,
    [data2]     DATETIME  NOT NULL,
    [nr_poz2]   INT       NOT NULL,
    [start2]    REAL      NOT NULL,
    [stop2]     REAL      NOT NULL,
    [int3]      INT       NOT NULL,
    [comanda3]  CHAR (13) NOT NULL,
    [tip3]      CHAR (2)  NOT NULL,
    [nr_fisa3]  CHAR (20) NOT NULL,
    [data3]     DATETIME  NOT NULL,
    [nr_poz3]   INT       NOT NULL,
    [start3]    REAL      NOT NULL,
    [stop3]     REAL      NOT NULL,
    [int4]      INT       NOT NULL,
    [comanda4]  CHAR (13) NOT NULL,
    [tip4]      CHAR (2)  NOT NULL,
    [nr_fisa4]  CHAR (20) NOT NULL,
    [data4]     DATETIME  NOT NULL,
    [nr_poz4]   INT       NOT NULL,
    [start4]    REAL      NOT NULL,
    [stop4]     REAL      NOT NULL,
    [int5]      INT       NOT NULL,
    [comanda5]  CHAR (13) NOT NULL,
    [tip5]      CHAR (2)  NOT NULL,
    [nr_fisa5]  CHAR (20) NOT NULL,
    [data5]     DATETIME  NOT NULL,
    [nr_poz5]   INT       NOT NULL,
    [start5]    REAL      NOT NULL,
    [stop5]     REAL      NOT NULL,
    [int6]      INT       NOT NULL,
    [comanda6]  CHAR (13) NOT NULL,
    [tip6]      CHAR (2)  NOT NULL,
    [nr_fisa6]  CHAR (20) NOT NULL,
    [data6]     DATETIME  NOT NULL,
    [nr_poz6]   INT       NOT NULL,
    [start6]    REAL      NOT NULL,
    [stop6]     REAL      NOT NULL,
    [int7]      INT       NOT NULL,
    [comanda7]  CHAR (13) NOT NULL,
    [tip7]      CHAR (2)  NOT NULL,
    [nr_fisa7]  CHAR (20) NOT NULL,
    [data7]     DATETIME  NOT NULL,
    [nr_poz7]   INT       NOT NULL,
    [start7]    REAL      NOT NULL,
    [stop7]     REAL      NOT NULL,
    [int8]      INT       NOT NULL,
    [comanda8]  CHAR (13) NOT NULL,
    [tip8]      CHAR (2)  NOT NULL,
    [nr_fisa8]  CHAR (20) NOT NULL,
    [data8]     DATETIME  NOT NULL,
    [nr_poz8]   INT       NOT NULL,
    [start8]    REAL      NOT NULL,
    [stop8]     REAL      NOT NULL,
    [int9]      INT       NOT NULL,
    [comanda9]  CHAR (13) NOT NULL,
    [tip9]      CHAR (2)  NOT NULL,
    [nr_fisa9]  CHAR (20) NOT NULL,
    [data9]     DATETIME  NOT NULL,
    [nr_poz9]   INT       NOT NULL,
    [start9]    REAL      NOT NULL,
    [stop9]     REAL      NOT NULL,
    [int10]     INT       NOT NULL,
    [comanda10] CHAR (13) NOT NULL,
    [tip10]     CHAR (2)  NOT NULL,
    [nr_fisa10] CHAR (20) NOT NULL,
    [data10]    DATETIME  NOT NULL,
    [nr_poz10]  INT       NOT NULL,
    [start10]   REAL      NOT NULL,
    [stop10]    REAL      NOT NULL,
    CONSTRAINT [Pincipal] PRIMARY KEY NONCLUSTERED ([hostid] ASC, [masina] ASC)
);

