create view __WHITELAND_EXPORT_CLIENTI 
AS
select top 100 percent Denumire as [DENUMIRE CLIENT] ,
'' as [Atribut fiscal], Cod_fiscal as [COD FISCAL], ii.Banca3 as [CodUnic2 (J)], '' AS [Vizibilitate (Global)], 
i.Descriere as [Denumire Punct de Lucru], case when i.Identificator='' then 'DA'else 'NU' end as [Sediu (Da / Nu)], i.Identificator as [Cod PUNCT DE LUCRU],
i.e_mail as Adresa, i.Pers_contact as localitate, i.Telefon_fax2 as judet, ii.Observatii, t.Cont_in_banca

 from terti t inner join dbo.infotert i on t.Tert = i.Tert 
 inner join dbo.infotert ii on t.Tert = ii.Tert 
 where 
 ii.Identificator = '' and
 i.Loc_munca in ('020020904', '020020903')
 
 order by i.Telefon_fax2,  i.Pers_contact , [DENUMIRE CLIENT]