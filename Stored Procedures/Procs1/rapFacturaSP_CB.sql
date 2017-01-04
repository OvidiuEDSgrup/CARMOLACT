
create proc rapFacturaSP_CB as 

;with ct as (
	select [ct1],[ct2],[ct3],[ct4],[ct5] from
		(
		select nrcont='ct'+isnull(nullif(rtrim(row_number() over (order by c.numar_pozitie)),'0'),'')
			,cont_in_banca=rtrim(cont_in_banca) from contbanci c 
		where c.subunitate='1' and c.tert=''
		) as s 
	pivot
		(max(cont_in_banca) for nrcont in ([ct1],[ct2],[ct3],[ct4],[ct5])) as p
	)
	, bc as (
	select [bc1],[bc2],[bc3],[bc4],[bc5] from
		(
		select nrcont='bc'+isnull(nullif(rtrim(row_number() over (order by c.numar_pozitie)),'0'),'')
			,banca=rtrim(banca) from contbanci c 
		where c.subunitate='1' and c.tert=''
		) as s 
	pivot
		(max(banca) for nrcont in ([bc1],[bc2],[bc3],[bc4],[bc5])) as p
	)
	, cb as (
	select * from ct,bc
	)
update #date_factura set ct1=cb.ct1, bc1=cb.bc1, 
ct2=cb.ct2, bc2=cb.bc2, 
ct3=cb.ct3, bc3=cb.bc3, 
ct4=cb.ct4, bc4=cb.bc4, 
ct5=cb.ct5, bc5=cb.bc5
from cb
--select * from cb