CREATE VIEW CalculPretPredariSemifabrLapte AS 
SELECT
Subunitate, Tip, dbo.EOM(Data) AS Data_lunii, Cod, '' AS Comanda,
CONVERT(DECIMAL(17,2),SUM(CONVERT(DECIMAL(17,2),Cantitate))) AS Cantitate,
CONVERT(DECIMAL(17,2),SUM(CONVERT(DECIMAL(17,2),Cantitate* Pret_de_stoc))) AS Valoare,
CONVERT(DECIMAL(17,2),SUM(CONVERT(DECIMAL(17,2),Cantitate* proc_grasime))) AS UG,
CONVERT(DECIMAL(17,3), ISNULL(SUM(CONVERT(DECIMAL(17,2),Cantitate* proc_grasime))
/NULLIF(SUM(CONVERT(DECIMAL(17,2),Cantitate)),0),0)) AS medie_UG,
CONVERT(DECIMAL(17,5), ISNULL(SUM(CONVERT(DECIMAL(17,2),Cantitate* Pret_de_stoc))
/NULLIF(SUM(CONVERT(DECIMAL(17,2),Cantitate)),0),0)) AS pret_UM
FROM PredariSemifabrLapte
--WHERE data between '2010-06-01' and '2010-06-30'
GROUP BY Subunitate, Tip, dbo.EOM(Data), Cod