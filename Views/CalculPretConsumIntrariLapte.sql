CREATE VIEW CalculPretConsumIntrariLapte AS 
SELECT
Subunitate, Tip, dbo.EOM(Data) AS Data_lunii, '' AS Comanda,
CONVERT(DECIMAL(17,2),SUM(CONVERT(DECIMAL(17,2),Cantitate))) AS Cantitate,
CONVERT(DECIMAL(17,2),SUM(CONVERT(DECIMAL(17,2),Cantitate* Pret_de_stoc))) AS Valoare,
CONVERT(DECIMAL(17,2),SUM(CONVERT(DECIMAL(17,2),Cantitate* proc_grasime))) AS UG,
CONVERT(DECIMAL(17,5), ISNULL(SUM(CONVERT(DECIMAL(17,2),Cantitate* Pret_de_stoc))
/NULLIF(SUM(CONVERT(DECIMAL(17,2),Cantitate* proc_grasime)),0),0)) AS pret_UG
-- select *
FROM ConsumIntrariLapte
--WHERE data between '2010-06-01' and '2010-06-30' --and proc_grasime<=0
GROUP BY Subunitate, Tip, dbo.EOM(Data)