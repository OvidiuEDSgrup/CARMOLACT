
CREATE procedure [dbo].[wStergPozRealizari] @sesiune varchar(50), @parXML XML    
as  
 declare  
  @nrCM varchar(20),@idPozRealizari int,@idRealizare int,@eroare varchar(256)  
    
 set @nrCM=ISNULL(@parXML.value('(/row/row/@numarCM)[1]', 'varchar(20)'), '')  
 
 set @idPozRealizari=ISNULL(@parXML.value('(/row/row/@id)[1]', 'int'), 0)  
 set @idRealizare=@parXML.value('(/row/@id)[1]','int')  
   
 begin try  
  delete from pozdoc where Subunitate='1' and tip='CM' and Numar=@nrCM and detalii.value('(/row/@idRealizare)[1]','int') = @idPozRealizari   
  delete from pozRealizari where id=@idPozRealizari  
 end try  
   
 begin catch  
  set @eroare='(wStergPozRealizari):'+  
     char(10)+rtrim(ERROR_MESSAGE())  
 end catch  
   
 if (@eroare<>'') raiserror(@eroare,16,1)  
   
 set @parXML='<row id="'+convert(varchar(20),@idRealizare)+'"/>'  
 exec wIaPozRealizari @sesiune=@sesiune, @parXML=@parXML