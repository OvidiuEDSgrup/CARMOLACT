CREATE VIEW PredariSemifabrLapte AS
select p.Subunitate, p.Tip, p.Data, p.Comanda, 
	g.Tip_gestiune, p.Gestiune, p.Cod, p.Cod_intrare, 
	ltrim(rtrim(convert(char(20),ISNULL(rs.identificator,0)))) as identificator,
	p.Cantitate, p.Pret_de_stoc,
	CONVERT(DECIMAL(17,3),COALESCE((select TOP 1 (CASE ISNUMERIC(prs.Valoare) WHEN 1 THEN prs.Valoare ELSE NULL END) from proprietati prs 
			where prs.Tip=rs.tip and prs.Cod=ltrim(rtrim(convert(char(20),rs.identificator))) and prs.Cod_proprietate='G' and prs.Valoare_tupla=''), 
		(select TOP 1 (CASE ISNUMERIC(prc.Valoare) WHEN 1 THEN prc.Valoare ELSE NULL END) from proprietati prc 
			where prc.Tip='COMANDA' and prc.Cod=p.comanda and prc.Cod_proprietate='G' and prc.Valoare_tupla=''),
		(select TOP 1 (CASE ISNUMERIC(prn.Valoare) WHEN 1 THEN prn.Valoare ELSE NULL END) from proprietati prn 
			where prn.Tip='NOMENCL' and prn.Cod=p.cod and prn.Cod_proprietate='G' and prn.Valoare_tupla=''),'0')) as proc_grasime,
	p.Numar, p.Numar_pozitie
from pozdoc p 
	inner join ProdSemifabrLapte psl on psl.cod=p.cod
	left join gestiuni g on g.cod_gestiune= p.gestiune
	left join recodif rs on rs.tip='STOC' and rs.Alfa1= g.Tip_gestiune and rs.Alfa2= p.Gestiune and rs.Alfa3= p.cod and rs.Alfa4= p.Cod_intrare
		and rs.Alfa5='' and rs.Alfa6='' and rs.Alfa7='' and rs.Alfa8='' and rs.Alfa9='' and rs.Alfa10=''
where p.tip='PP'