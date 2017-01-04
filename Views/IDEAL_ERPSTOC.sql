



CREATE VIEW [dbo].[IDEAL_ERPSTOC]
AS
SELECT     Cod_gestiune AS ECODGESTIUNE, Cod AS ECODPRODUS, SUM(Stoc) AS STOC
FROM         dbo.stocuri
GROUP BY Cod_gestiune, Cod






