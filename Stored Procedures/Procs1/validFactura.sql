create procedure validFactura
as
begin try
	/*	Se lucreaza cu #facturi (tert, tip, factura, data)	*/
	declare
		@err varchar(1000)

	--return
	IF EXISTS (select 1 from facturi f 
		JOIN #facturi df on f.subunitate='1' and f.tert=df.tert and f.factura=df.factura and f.tip=(case df.tip when 'F' then 0x54 else 0x46 end) 
		where f.data<>df.data and df.factura<>'' and ABS(f.valoare)>0.01) 
		--Nu validam daca modificarea provine din operatia de Modificare antet pe tabela doc. Facem validare in procedura wOPModificareAntetDoc.
		and ISNULL(left(cast(CONTEXT_INFO() as varchar),18),'')<>'modificareantetdoc'
	begin
		select 
			top 1 @err = 'Factura cu numarul ' + rtrim(f.factura) + ' exista in sistem cu o alta data: ' + convert(varchar(10), f.data, 103)
			from facturi f 
			JOIN #facturi df on f.tert=df.tert and f.factura=df.factura and f.tip=(case df.tip when 'F' then 0x54 else 0x46 end) 
			where f.data<>df.data and ABS(f.valoare)>0.01 

		RAISERROR(@err, 16, 1)
	end

	/*	Pentru o validare mai stricta sau alte lucruri permitem SP (care nu inlocuieste)	*/
	if exists (select 1 from sys.objects where name='validFacturaSP' and type='P')  
		exec validFacturaSP 
		
end try
BEGIN CATCH
	declare
		@mesaj varchar(500)
	set @mesaj=ERROR_MESSAGE() + ' ('+OBJECT_NAME(@@PROCID)+')'
	raiserror (@mesaj, 15, 1)
END CATCH
