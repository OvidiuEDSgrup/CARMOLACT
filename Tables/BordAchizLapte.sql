CREATE TABLE [dbo].[BordAchizLapte] (
    [Data_lunii]       DATETIME   NOT NULL,
    [Tip]              CHAR (1)   NOT NULL,
    [Producator]       CHAR (9)   NOT NULL,
    [Centru_colectare] CHAR (9)   NOT NULL,
    [Tip_lapte]        CHAR (20)  NOT NULL,
    [Cant_UM]          FLOAT (53) NOT NULL,
    [Grasime_1]        REAL       NOT NULL,
    [Grasime_2]        REAL       NOT NULL,
    [Grasime]          REAL       NOT NULL,
    [Cant_UG]          FLOAT (53) NOT NULL,
    [Cant_STAS]        FLOAT (53) NOT NULL,
    [Pret]             FLOAT (53) NOT NULL,
    [Valoare]          FLOAT (53) NOT NULL,
    [Nr_doc]           CHAR (20)  DEFAULT ('') NOT NULL,
    [Data_doc]         DATETIME   DEFAULT ('') NOT NULL,
    [Data_operarii]    DATETIME   NOT NULL,
    [Ora_operarii]     CHAR (6)   NOT NULL,
    [Utilizator]       CHAR (10)  NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Unic]
    ON [dbo].[BordAchizLapte]([Data_lunii] ASC, [Tip] ASC, [Producator] ASC, [Centru_colectare] ASC, [Tip_lapte] ASC);


GO
CREATE NONCLUSTERED INDEX [Data]
    ON [dbo].[BordAchizLapte]([Data_lunii] DESC, [Tip] ASC, [Producator] ASC, [Centru_colectare] ASC, [Tip_lapte] ASC);


GO
CREATE NONCLUSTERED INDEX [missing_index_87]
    ON [dbo].[BordAchizLapte]([Producator] ASC);


GO
CREATE NONCLUSTERED INDEX [missing_index_85]
    ON [dbo].[BordAchizLapte]([Producator] ASC)
    INCLUDE([Data_lunii], [Tip], [Centru_colectare], [Tip_lapte], [Cant_UM], [Grasime]);


GO
CREATE NONCLUSTERED INDEX [missing_index_124]
    ON [dbo].[BordAchizLapte]([Tip] ASC, [Producator] ASC, [Centru_colectare] ASC, [Tip_lapte] ASC, [Data_lunii] ASC);


GO
CREATE NONCLUSTERED INDEX [missing_index_167]
    ON [dbo].[BordAchizLapte]([Producator] ASC)
    INCLUDE([Data_lunii], [Tip], [Centru_colectare], [Tip_lapte], [Cant_UM], [Grasime]);


GO
CREATE NONCLUSTERED INDEX [missing_index_107]
    ON [dbo].[BordAchizLapte]([Centru_colectare] ASC, [Tip_lapte] ASC, [Data_lunii] ASC)
    INCLUDE([Tip], [Producator], [Cant_UM], [Grasime], [Cant_UG]);


GO
CREATE NONCLUSTERED INDEX [missing_index_431]
    ON [dbo].[BordAchizLapte]([Producator] ASC, [Data_lunii] ASC)
    INCLUDE([Centru_colectare]);


GO
CREATE NONCLUSTERED INDEX [missing_index_235]
    ON [dbo].[BordAchizLapte]([Data_lunii] ASC, [Producator] ASC, [Tip_lapte] ASC)
    INCLUDE([Tip], [Centru_colectare], [Cant_UM], [Grasime]);


GO
CREATE NONCLUSTERED INDEX [missing_index_237]
    ON [dbo].[BordAchizLapte]([Data_lunii] ASC, [Producator] ASC, [Tip_lapte] ASC);


GO
CREATE NONCLUSTERED INDEX [missing_index_366]
    ON [dbo].[BordAchizLapte]([Tip] ASC, [Centru_colectare] ASC, [Tip_lapte] ASC, [Data_lunii] ASC, [Producator] ASC)
    INCLUDE([Cant_UM], [Grasime_1], [Grasime_2], [Grasime], [Cant_UG], [Cant_STAS], [Pret], [Valoare], [Data_operarii], [Ora_operarii], [Utilizator]);

