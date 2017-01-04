CREATE 
PROCEDURE [PropStocGestIntrariLapte] 
	@hostid char(10) AS

IF @hostid IS NULL
	SET @hostid = HOST_ID()
/*
UPDATE pozdoc
SET cantitate=cantitate+1 
FROM pozdoc,avnefac
WHERE pozdoc.subunitate=avnefac.subunitate AND pozdoc.tip=avnefac.tip AND pozdoc.numar=avnefac.numar AND pozdoc.data=avnefac.data AND pozdoc.gestiune=avnefac.cod_gestiune
	and avnefac.terminal=@hostid
*/




DECLARE docIntrariLapte CURSOR FOR
	Select p.Subunitate, MAX(p.Tip), MAX(p.Numar), p.Data--, Cod_gestiune
	from avnefac a 
		inner join IntrariLapte p 
			on a.subunitate=p.subunitate and a.tip=p.tip and left(a.numar,8)=p.numar and a.data=p.data
	where terminal=@hostid and a.tip IN ('RM', 'AI') AND p.cod LIKE 'L[VCOB].' 
	group by p.subunitate, p.data, p.comanda, p.tura

OPEN docIntrariLapte
DECLARE @sub char(9), @tip char(2), @numar char(8), @data datetime, @gest char(9)

FETCH NEXT FROM docIntrariLapte
INTO @sub, @tip, @numar, @data--, @gest 

WHILE @@FETCH_STATUS=0
	BEGIN

		IF exists (select 1 from pozdoc p
				WHERE p.subunitate=@sub AND p.tip=@tip AND p.numar=@numar AND p.data=@data 
					/*AND p.gestiune=@gest*/ AND p.cod LIKE 'L[VCOB]%')
			/*and exists (select 1 from pozdoc p
				WHERE p.subunitate=@sub AND p.tip=@tip AND p.numar=@numar AND p.data=@data 
					/*AND p.gestiune=a.@gest*/ AND p.cod LIKE 'L[VCOB].')*/
		BEGIN
			/*select TOP 1 
			@sub=p.subunitate,
			@tip=p.tip,
			@numar=p.numar,
			@data=p.data 
			from pozdoc p, avnefac a 
						WHERE p.subunitate=a.subunitate AND p.tip=a.tip AND p.numar=a.numar AND p.data=a.data 
							AND p.gestiune=a.cod_gestiune AND a.terminal=@hostid AND a.tip IN ('RM', 'AI')
							AND (p.cod LIKE 'L[VCOB]' OR p.cod LIKE 'L[VCOB].')*/
			
			EXEC PropStocGestDocIntrariLapte @sub, @tip, @numar, @data
		END
		FETCH NEXT FROM docIntrariLapte
		INTO @sub, @tip, @numar, @data--, @gest 

/*
declare @hostid char(8)
set @hostid=left(convert(char,convert(numeric,HOST_ID())),8)

delete avnefac
where terminal=@hostid

insert avnefac
select distinct
@hostid,--Terminal	char	no	8	     
'1',--Subunitate	char	no	9	     
p.tip,--Tip	char	no	2	     
p.numar,--Numar	char	no	20	     
'',--Cod_gestiune	char	no	9	     
p.data,--Data	datetime	no	8	     
'',--Cod_tert	char	no	13	     
'',--Factura	char	no	20	     
'',--Contractul	char	no	20	     
'',--Data_facturii	datetime	no	8	     
'',--Loc_munca	char	no	9	     
'',--Comanda	char	no	13	     
'',--Gestiune_primitoare	char	no	9	     
'',--Valuta	char	no	3	     
0,--Curs	float	no	8	53   
0,--Valoare	float	no	8	53   
0,--Valoare_valuta	float	no	8	53   
0,--Tva_11	float	no	8	53   
0,--Tva_22	float	no	8	53   
'',--Cont_beneficiar	char	no	13	     
0--Discount	real	no	4	24   
from pozdoc p
where p.tip IN ('RM', 'AI')
--and numar='03r2'
and exists (select 1 from pozdoc p1
				WHERE p1.subunitate=p.subunitate AND p1.tip=p.tip AND p1.numar=p.numar AND p1.data=p.data 
					 AND p1.cod LIKE 'L[VCOB]%')
and exists (select 1 from pozdoc p1
				WHERE p1.subunitate=p.subunitate AND p1.tip=p.tip AND p1.numar=p.numar AND p1.data=p.data 
					 AND p1.cod LIKE 'L[VCOB].')
and p.data between '2010-06-01' and '2010-06-30'

set nocount on
EXEC [PropStocGestIntrariLapte] @hostid
delete avnefac
where terminal=@hostid
GO
*/
		

END

CLOSE docIntrariLapte
DEALLOCATE docIntrariLapte