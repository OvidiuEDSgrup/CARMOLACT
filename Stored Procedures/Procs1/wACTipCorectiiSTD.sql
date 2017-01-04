--***
Create procedure wACTipCorectiiSTD @sesiune varchar(50), @parXML XML
as
begin
	declare @searchText varchar(100)
	set @searchText=replace(isnull(@parXML.value('(/row/@searchText)[1]','varchar(100)'),'%'),' ','%')

	select 'A-' as tipcor, 'CM CAS' as denumire
	into #tipcorstd
	union all select 'B-' as tipcor, 'CM unitate' as denumire
	union all select 'C-' as tipcor, 'CM incasat' as denumire
	union all select 'D-' as tipcor, 'CO' as denumire
	union all select 'E-' as tipcor, 'CO incasat' as denumire
	union all select 'F-' as tipcor, 'Restituiri' as denumire
	union all select 'G-' as tipcor, 'Diminuari' as denumire
	union all select 'H-' as tipcor, 'Suma impozabila' as denumire
	union all select 'I-' as tipcor, 'Premiu' as denumire
	union all select 'J-' as tipcor, 'Diurna' as denumire
	union all select 'K-' as tipcor, 'Cons. adm' as denumire
	union all select 'L-' as tipcor, 'Procent lucrat acord' as denumire
	union all select 'M-' as tipcor, 'Suma incasata' as denumire
	union all select 'N-' as tipcor, 'Suma neimpozabila' as denumire
	union all select 'N2' as tipcor, 'Suma neimpozabila2' as denumire
	union all select 'O-' as tipcor, 'Suma impozabila' as denumire
	union all select 'P-' as tipcor, 'Diferenta impozit' as denumire
	union all select 'Q-' as tipcor, 'Avantaje materiale' as denumire
	union all select 'R-' as tipcor, 'Ajutor deces' as denumire
	union all select 'S-' as tipcor, 'Premiu brut/net' as denumire
	union all select 'T-' as tipcor, 'Pensii facultative' as denumire
	union all select 'U-' as tipcor, 'Premii neimpozabile' as denumire
	union all select 'X-' as tipcor, 'Premiu2' as denumire
	union all select 'Y-' as tipcor, 'Diurna2' as denumire
	union all select 'Z-' as tipcor, 'CO2' as denumire
	union all select 'AI' as tipcor, 'Avantaje materiale impozabile' as denumire

	if exists (select * from sysobjects where name ='wACTipCorectiiSTDSP')
		exec wACTipCorectiiSTDSP @sesiune=@sesiune, @parXML=@parXML

	select tipcor as cod, denumire
	from #tipcorstd
	for xml raw
end