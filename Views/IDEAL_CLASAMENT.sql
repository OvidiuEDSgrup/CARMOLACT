




CREATE VIEW [dbo].[IDEAL_CLASAMENT]
AS
SELECT     Cod
FROM         dbo.pozdoc p
WHERE     (Tip IN ('ap', 'ac')) AND (Subunitate = '1        ')
GROUP BY Cod
HAVING      (SUM(Cantitate) >= 1)







