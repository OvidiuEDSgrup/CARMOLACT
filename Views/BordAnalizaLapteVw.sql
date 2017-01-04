CREATE VIEW [dbo].[BordAnalizaLapteVw] AS
SELECT 
	ban.Data_lunii,
	ban.Tip,
	ban.Producator,
	ban.Centru_colectare,
	ban.Tip_lapte,
	ban.Indicator,
	CONVERT(decimal(15,5),AVG(ban.Valoare)) as Valoare
FROM BordAnalizaLapte ban
WHERE ban.Valoare<>0
GROUP BY ban.Data_lunii, ban.Tip, ban.Producator, ban.Centru_colectare, ban.Tip_lapte, ban.Indicator