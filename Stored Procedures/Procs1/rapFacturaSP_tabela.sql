CREATE proc rapFacturaSP_tabela as 

if object_id('tempdb..#date_factura') is null 
		create table #date_factura(ct varchar(50), bc varchar(50))

alter table #date_factura add ct1 varchar(50) default null,  bc1 varchar(50) default null, 
 ct2 varchar(50) default null,  bc2 varchar(50) default null, 
 ct3 varchar(50) default null,  bc3 varchar(50) default null, 
 ct4 varchar(50) default null,  bc4 varchar(50) default null, 
 ct5 varchar(50) default null,  bc5 varchar(50) default null
