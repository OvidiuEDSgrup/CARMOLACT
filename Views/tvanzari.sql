create view [dbo].[tvanzari] as
select pozdoc.tip, year(pozdoc.data) as 'Anul', month(pozdoc.data) as 'Luna', terti.judet, terti.localitate, terti.grupa as Gr_Terti, terti.denumire as Tert,
isnull(lm.denumire,'') as 'lm', isnull(gestiuni.denumire_gestiune,'') as 'Gestiune', 
nomencl.grupa, 
nomencl.denumire as 'Produs', 
pozdoc.cantitate, 
pozdoc.cantitate*pozdoc.pret_vanzare as 'valoare' 
from pozdoc, terti, gestiuni, lm, nomencl 
where pozdoc.tip in ('AP','AS') and pozdoc.tert=terti.tert and pozdoc.cod=nomencl.cod 
and pozdoc.gestiune*=gestiuni.cod_gestiune and pozdoc.loc_de_munca*=lm.cod
union 
select pozadoc.tip, year(pozadoc.data) as 'Anul', month(pozadoc.data) as 'Luna', terti.judet, terti.localitate,terti.grupa as Gr_Terti, terti.denumire,
isnull(lm.denumire,'') as 'lm', '', 'Valoric', 'Valoric', 1, pozadoc.suma+pozadoc.tva11+pozadoc.tva22 as 'valoare'
from pozadoc, terti, lm where pozadoc.tip='FB' and pozadoc.loc_munca=lm.cod and pozadoc.tert=terti.tert
