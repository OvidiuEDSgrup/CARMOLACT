--***
create procedure wScriuCarduriFidelizare(@sesiune varchar(50), @parXML xml)
as

declare @eroare varchar(1000)
set @eroare=''
begin try
	--> extragere date xml
	declare @uid varchar(36), @tert varchar(20), @punctlivrare varchar(20), @persoanacontact varchar(20), @mijloctransport varchar(20),
		@numeposesor varchar(200), @telposesor varchar(20), @emailposesor varchar(200), @update bit, @o_uid varchar(36)
	select @uid=@parXML.value('(/row/@uid)[1]','varchar(36)'),
		@tert=@parXML.value('(/row/@tert)[1]','varchar(20)'),
		@punctlivrare=@parXML.value('(/row/@punctlivrare)[1]','varchar(20)'),
		@persoanacontact=@parXML.value('(/row/@persoanacontact)[1]','varchar(20)'),
		@mijloctransport=@parXML.value('(/row/@mijloctransport)[1]','varchar(20)'),
		@numeposesor=@parXML.value('(/row/@numeposesor)[1]','varchar(200)'),
		@telposesor=@parXML.value('(/row/@telposesor)[1]','varchar(20)'),
		@emailposesor=@parXML.value('(/row/@emailposesor)[1]','varchar(20)'),
		@update=isnull(@parXML.value('(/row/@update)[1]','bit'),0),
		@o_uid=@parXML.value('(/row/@o_uid)[1]','varchar(36)')
	--> scrierea
	if (@update=0)
	begin
		if (isnull(@uid,'')='')	select @uid=newid()	--> numar nou de identificare (daca nu s-a furnizat unul)
		if exists (select 1 from CarduriFidelizare c where c.UID=@uid)
			raiserror('Numarul unic de identificare s-a folosit deja! Incercati din nou sau nu il completati!',16,1)
		insert into CarduriFidelizare(UID, Tert, Punct_livrare, Id_Persoana_contact, Mijloc_de_transport, Nume_posesor_card, Telefon_posesor_card, Email_posesor_card, Detalii_xml)
			select @uid, @tert, @punctlivrare, @persoanacontact, @mijloctransport, @numeposesor, @telposesor, @emailposesor, null
	end
	--> modificarea
	else
	begin
		if (isnull(@uid,'')='') raiserror('Numarul unic de indentificare nu este valid!',16,1)
		if (@uid<>@o_uid) raiserror('Numarul unic de identificare nu este modificabil!',16,1)
		if not exists (select 1 from CarduriFidelizare c where c.UID=@uid) raiserror ('Linia de modificat nu exista!',16,1)
		update CarduriFidelizare set uid=@uid, tert=@tert, Punct_livrare=@punctlivrare, Id_Persoana_contact=@persoanacontact, Mijloc_de_transport=@mijloctransport,
			Nume_posesor_card=@numeposesor, Telefon_posesor_card=@telposesor, Email_posesor_card=@emailposesor
		where UID=@uid
	end
end try
begin catch
	set @eroare='wScriuCarduriFidelizare (linia '+convert(varchar(20),ERROR_LINE())+'):'+char(13)+ERROR_MESSAGE()
end catch

if len(@eroare)>0 raiserror(@eroare,16,1)