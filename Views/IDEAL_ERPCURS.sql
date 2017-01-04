




CREATE VIEW [dbo].[IDEAL_ERPCURS]
AS
SELECT     Valuta, Curs
FROM         dbo.curs
WHERE     (Data IN
                          (SELECT     MAX(c.DATA)
                            FROM          CURS C
                            WHERE      C.VALUTA = CURS.VALUTA))







