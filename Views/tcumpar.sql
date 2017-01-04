create view [dbo].[tcumpar] as 
SELECT day(data) as 'zi', month(data) as 'luna', year(data) as 'an', terti.Judet, 
terti.Localitate,terti.Grupa as Gr_terti, terti.Denumire as 'denumire_tert',nomencl.Grupa, nomencl.Denumire , 
pozdoc.Cantitate, cantitate*pret_de_stoc as 'Valoare_cumparare', pozdoc.Cont_corespondent,
 pozdoc.Cont_de_stoc,isnull(lm.cod,'Fara loc de munca') as 'Cod_loc_de_munca',
isnull(lm.denumire,'Fara loc de munca') as 'Denumire_loc_de_munca'
FROM nomencl, pozdoc, terti,lm
WHERE pozdoc.loc_de_munca*=lm.cod and pozdoc.Cod = nomencl.Cod AND
 pozdoc.Tert = terti.Tert AND pozdoc.Tip In ('RM','RS')
