create view [dbo].[lista_intrari_lapte] as
SELECT  pozdoc.Cod,nomencl.Denumire as Denumire,pozdoc.Data,pozdoc.Cantitate,pozdoc.Tert,pozdoc.Loc_de_munca,lm.Denumire as lm_denumire
FROM CARMOLACT.dbo.lm, CARMOLACT.dbo.nomencl, CARMOLACT.dbo.pozdoc
WHERE lm.Cod = pozdoc.loc_de_munca 
AND nomencl.Cod = pozdoc.Cod  
AND pozdoc.Cod='L'
And pozdoc.Tip!='CM'
