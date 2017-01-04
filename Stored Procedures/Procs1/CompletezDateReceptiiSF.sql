CREATE procedure CompletezDateReceptiiSF @Sub char(9), @Tip char(2), @Numar char(8), @Data datetime AS

if OBJECT_ID('tempdb..#yso_pozdocsf') is not null drop table #yso_pozdocsf

select p.idPozDoc
	,f.Valoare, f.TVA_22
into #yso_pozdocsf
from pozdoc p 
	inner join facturi f on f.Subunitate=p.Subunitate and f.Tip=0x54 and f.Tert=p.Tert and f.Factura=p.Cod_intrare
where p.Subunitate=@Sub and p.Tip=@Tip and p.Numar=@Numar and p.Data=@Data 
	and p.Cod='SOF' and p.Cont_de_stoc like '408%' and p.Cod_intrare<>'' 
	and p.Pret_de_stoc<>f.Valoare and p.Pret_valuta<>f.Valoare and p.TVA_deductibil<>f.TVA_22

if @@ROWCOUNT>0
	update p set Pret_valuta=t.Valoare, Pret_de_stoc=t.TVA_22, TVA_deductibil=t.TVA_22
	from pozdoc p inner join #yso_pozdocsf t on t.idPozDoc=p.idPozDoc