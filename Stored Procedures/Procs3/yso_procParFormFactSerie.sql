
create procedure [dbo].[yso_procParFormFactSerie] @chostid varchar(25) as
begin

SET TRANSACTION ISOLATION LEVEL READ COMMITTED 

if OBJECT_ID('tmpformfactserie') is null
begin
	SELECT top 0 @chostid as terminal,
	doc.*,
	0 as avize,
	convert(varchar(2048),'') AS lista_avize 
	into tmpformfactserie
	FROM doc --inner join avnefac a on a.Subunitate=doc.Subunitate and a.Tip=doc.Tip and a.Numar=doc.Numar and a.Data=a.Data where a.Terminal=@chostid
	
	create unique nonclustered index idxdoc on tmpformfactserie (terminal,subunitate,tip,numar,data)
	create unique nonclustered index idxfact on tmpformfactserie (terminal,subunitate,cod_tert,gestiune_primitoare,factura)
end
else
begin
	delete tmpformfactserie where terminal=@chostid
	
	insert tmpformfactserie
	SELECT a.Terminal, 
		doc.*,
		(SELECT count(*) 
		FROM doc d 
		WHERE doc.subunitate=d.subunitate and doc.tip=d.tip and doc.cod_tert=d.cod_tert and doc.cod_gestiune=d.cod_gestiune 
			and doc.gestiune_primitoare=d.gestiune_primitoare and doc.factura=d.factura) AS avize,
		REPLACE((SELECT RTRIM(numar)+'/'+RTRIM((CONVERT(CHAR,data,4))) AS [data()] 
		FROM doc d 
		WHERE doc.subunitate=d.subunitate and doc.tip=d.tip and doc.cod_tert=d.cod_tert and doc.cod_gestiune=d.cod_gestiune 
			and doc.gestiune_primitoare=d.gestiune_primitoare and doc.factura=d.factura  
		ORDER BY doc.data, doc.numar FOR XML PATH ('')),' ','; ') AS lista_avize 
	--into ##tmpformfactserie
	FROM doc inner join avnefac a on a.Subunitate=doc.Subunitate and a.Tip=doc.Tip and a.Numar=doc.Numar and a.Data=a.Data
	where a.Terminal=@chostid
end

end 

