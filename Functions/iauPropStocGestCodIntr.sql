create function [dbo].[iauPropStocGestCodIntr] (@identificator char(9), @codProprietate char(3)) returns float
as
begin
	return 
		ISNULL((SELECT TOP 1 CASE ISNUMERIC(pr.valoare) WHEN 1 THEN CONVERT(float,pr.valoare) ELSE 0 END 
			FROM proprietati pr WHERE pr.Tip='STOC' and pr.Cod=LTRIM(RTRIM(CONVERT(CHAR(20), @identificator)))
				and pr.Cod_proprietate=@codProprietate and pr.Valoare<>'' and pr.Valoare_tupla='' 
			ORDER BY Tip, Cod, Cod_proprietate, Valoare, Valoare_tupla), 0)
end
