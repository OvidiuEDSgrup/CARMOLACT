create view  [dbo].[export_produse] as

select * from nomencl
where tip='P'
