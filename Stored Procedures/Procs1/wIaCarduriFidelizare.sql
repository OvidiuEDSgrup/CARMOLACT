--***
create procedure wIaCarduriFidelizare(@sesiune varchar(50), @parXML xml)
as
begin
	--> extragere parametri/filtre din xml si pregatire date:
	declare @subunitate varchar(20), @valoarePunct float
	exec luare_date_par @tip='PV', @par='VALPUNCTI', @val_l=0, @val_n=@valoarePunct output, @val_a=''
	
	select @subunitate=isnull((select top 1 val_alfanumerica from par where tip_parametru='GE' and parametru='SUBPRO'),'1')
	
	
	declare @tert varchar(100), @numePosesor varchar(100), @numeTert varchar(100)
	select @tert=@parXML.value('(/row/@tert)[1]','varchar(20)'),
			@numeTert='%'+@parXML.value('(/row/@numetert)[1]','varchar(20)')+'%',
			@numePosesor='%'+@parXML.value('(/row/@numeposesor)[1]','varchar(100)')+'%'

	--> select propriu-zis:
	select top 100 uid, rtrim(c.Tert) as tert, rtrim(Punct_livrare) as punctlivrare, rtrim(Id_Persoana_contact) as persoanacontact, rtrim(Mijloc_de_transport) as mijloctransport, 
			rtrim(Nume_posesor_card) as numeposesor, rtrim(Telefon_posesor_card) as telposesor, rtrim(Email_posesor_card) as emailposesor, --Detalii_xml,
				rtrim(t.Denumire) as numetert, '('+rtrim(Punct_livrare)+') '+rtrim(pl.Descriere) as numepunctlivrare, 
				'('+rtrim(Id_Persoana_contact)+') '+rtrim(pc.Descriere) as numepersoanacontact,
			isnull(convert(varchar(30), p.puncte)+'('+CONVERT(varchar(30),CONVERT(decimal(12,2), p.puncte * @valoarePunct))+' RON)',0) puncte
	from CarduriFidelizare c 
	left join terti t on c.Tert=t.Tert
	left join infotert pl on pl.Tert=c.Tert and pl.Identificator=c.Punct_livrare and pl.Subunitate=@subunitate
	left join infotert pc on pc.Tert=c.Tert and rtrim(pc.Identificator)=rtrim(c.Id_Persoana_contact) and rtrim(pc.Subunitate)='C'+@subunitate
	left join (select UID_card, sum((case when p.tip='D' then 1 else -1 end)*p.puncte) as puncte 
				from PvPuncte p 
				group by p.UID_card) p on p.UID_card=c.UID
	where (@tert is null or c.Tert=@tert)
		and (@numePosesor is null or Nume_posesor_card like @numePosesor)
		and (@numeTert is null or t.Denumire like @numeTert)
	for xml raw
end