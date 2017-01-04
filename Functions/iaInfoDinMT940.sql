
create function iaInfoDinMT940 (@continut varchar(max), @separator varchar(20))
--> functie care extrage o secventa de caractere care incepe cu un separator si se finalizeaza cu primul caracter al acelui separator

	--> folosita pentru importul operatiunilor extraselor de cont in format mt940
returns varchar(8000)
as 
begin
	return (case when charindex(@separator,@continut)=0 then '' else	--> limitele intervalului nu se iau, doar continutul relevant
				substring(@continut,
					charindex(@separator,@continut)+len(@separator),
					charindex(left(@separator,1),@continut,charindex(@separator,@continut)+1)-(charindex(@separator,@continut)+len(@separator)))
			end)
end
