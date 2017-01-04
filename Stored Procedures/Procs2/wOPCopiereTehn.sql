--***
create procedure wOPCopiereTehn @sesiune varchar(50), @parXML XML      
as
begin try    
 declare    
  @codNomencl varchar(20), @idTehn int, @codNomencl_vechi varchar(20),@struct xml,@denumire varchar(80),@tip varchar(20),@id int,    
  @codTehn varchar(20)    , @mesaj varchar(max)
     
 set @idTehn=isnull(@parXML.value('(/parametri/@id)[1]', 'int'), 0)    
 set @codNomencl=isnull(@parXML.value('(/parametri/@codNou)[1]', 'varchar(20)'), '')    
 set @codNomencl_vechi=isnull(@parXML.value('(/parametri/@codNomencl)[1]', 'varchar(20)'), '')    
 set @denumire=isnull(@parXML.value('(/parametri/@descriereNou)[1]', 'varchar(80)'), '')    
 set @codTehn=isnull(@parXML.value('(/parametri/@codTehnNou)[1]', 'varchar(20)'), '')    
 set @tip= ISNULL(@parXML.value('(/parametri/@tip_tehn)[1]', 'varchar(1)'),'')    
     
     
     
 --Validari    
 if @codNomencl = ''    
 begin    
  raiserror('Cod nomenclator invalid!',11,1)  
 end    
     
 if @codNomencl_vechi = @codNomencl    
 begin    
  raiserror('S-a introdus acelasi cod de nomenclator!',11,1)      
 end    
     
 if @codTehn=''    
  set @codTehn= @codNomencl    
 if exists (select 1 from tehnologii where cod=@codNomencl )    
 begin    
  raiserror('Exista tehnologie pentru acest cod!',11,1)       
 end    
     
 if @denumire=''    
    select @denumire=denumire from nomencl where cod=@codNomencl    
     
 set @tip=SUBSTRING(@tip,1,1)    
 insert     
  into tehnologii (cod,Denumire,tip,Data_operarii,detalii,codNomencl)    
  values(@codNomencl,@denumire,@tip,GETDATE(),null,@codNomencl)    
 
 declare @tabId table (id int)
 insert    
  into pozTehnologii (tip,cod,cantitate,pret,resursa,idp,detalii,cantitate_i,ordine_o,parinteTop) 
  output inserted.id into @tabId   
  values('T',@codNomencl,0,0,'',null,null,0,null,null)    
 select @id=id from @tabId
    
 --Se ia arborele de structua a tehnologiei pentru copy. Copiere structura tehnologie    
  declare @f xml    
  set @f =  
 (  
 select     
     rtrim(p.cod) as cod, p.id as id, p.idp as idp,p.tip as tip,    
     (case when p.tip in ('M','Z') then  rtrim(n.denumire) when p.tip='O' then  rtrim(c.Denumire) when p.tip in ('R','T') then RTRIM(t.denumire) end ) as denumire,    
     convert(decimal(15,6),  p.cantitate) as cantitate,convert(decimal(15,6),  p.cantitate_i) as cant_i,p.ordine_o as ordine,     
     (case when p.tip='O' then 'Operatie' when p.tip='R' then 'Reper'  when (p.tip='M' and n.tip ='P' )then 'Semifabricat' when p.tip='Z' then 'Rezultat' else 'Material' end )as _grupare,     
     (case when p.tip in ('M','Z') then rtrim(n.um) when p.tip='O' then  rtrim(c.um)  end ) as um,    
     ((case when p.tip in ('M','Z') then rtrim(n.denumire) when p.tip='O' then  rtrim(c.Denumire)else '' end) +' ('+rtrim(p.cod)+')') as denumireCod    
     from pozTehnologii p  
     left join nomencl n on p.tip='M' and n.cod=p.cod    
     left join catop c on p.tip='O' and c.Cod=p.cod    
     left join tehnologii t on p.tip='T' and p.cod=t.cod    
     where p.parinteTop=@idTehn  
     for xml raw  
 )    
  declare     
   @count int, @c int,@rand xml,@listaID xml,@child xml,    
   @idVechi int,@idParinteVechi int,@idParinteNou int,@idNou int    
      
  set @count= @f.value('count (/row)','INT')     
  set @c=1    
  --ID-ul antecalculatiei introduse anterior (Antetul antecalculatiei tip 'A') in pozzTehnologii    
  set @idNou=@id      
    
  set @rand=(select convert(int,@idTehn) as idV, @idNou as id for xml raw)     
  set @listaID='<list />'    
  set @listaID.modify('insert sql:variable("@rand") as last into (/list)[1]')    
    
    
  while @c <= @count    
  begin    
   set @child = @f.query('/row[position()=sql:variable("@c")]')     
   set @idVechi=@child.value('(/row/@id)[1]','int')    
   set @idParinteVechi=@child.value('(/row/@idp)[1]','int')    
       
   set @idParinteNou= @listaID.query('/list/row[@idV = sql:variable("@idParinteVechi")] ').value('(/row/@id)[1]','int')     
   insert    
    into pozTehnologii (tip,cod,cantitate,pret,resursa,idp,detalii,cantitate_i,ordine_o,parinteTop)    
    values(@child.value('(/row/@tip)[1]','varchar(1)'),@child.value('(/row/@cod)[1]','varchar(20)'),@child.value('(/row/@cantitate)[1]','varchar(20)'),@child.value('(/row/@pret)[1]','float'),'',@idParinteNou,null,@child.value('(/row/@cant_i)[1]','float'),
  
@child.value('(/row/@ordine)[1]','float'),@id)    
       
   set @idNou=(select IDENT_CURRENT('pozTehnologii'))     
   set @rand=(select @idVechi as idV, @idNou as id for xml raw)    
   set @listaID.modify('insert sql:variable("@rand") as last into (/list)[1]')     
   set @c=@c+1    
  end    
  --GATA copiere structura tehnologie
end try
begin catch
	set @mesaj=error_message()+ ' (wOPCopiereTehn)'
	raiserror(@mesaj, 11, 1)
end catch 