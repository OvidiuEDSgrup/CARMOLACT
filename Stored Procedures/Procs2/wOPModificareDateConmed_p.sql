create procedure wOPModificareDateConmed_p @sesiune varchar(50), @parXML xml
as
begin try
	declare @utilizator varchar(10), @data datetime, @marca varchar(6), @tip_diagnostic varchar(2), @data_inceput datetime, @mesaj varchar(1000)

	select	@data = isnull(@parXML.value('(/row/@data)[1]','datetime'),''),
			@marca = isnull(@parXML.value('(/row/row/@marca)[1]', 'varchar(6)'),''),	
			@tip_diagnostic = isnull(@parXML.value('(/row/row/@tipconcediu)[1]', 'varchar(2)'),''),	
			@data_inceput = @parXML.value('(/row/row/@datainceput)[1]', 'datetime')

	if @data_inceput is null
	begin
		raiserror( 'Operatie de modificare date pozitie nepermisa pe antetul documentului, selectati un concediu medical!',11,1)
	end  

	select rtrim(cm.marca) marca, RTRIM(p.nume) densalariat, convert(varchar(10),cm.data,101) data, 
		convert(varchar(10),cm.data_inceput,101) datainceput, convert(varchar(10),cm.data_sfarsit,101) datasfarsit, 
		cm.Tip_diagnostic as tipconcediu, rtrim(d.Denumire) as denconcediu, 
		rtrim(icm.Serie_certificat_CM) as seriecm, rtrim(icm.Nr_certificat_CM) as numarcm, 
		rtrim(rtrim(icm.Serie_certificat_CM_initial)+' '+rtrim(icm.Nr_certificat_CM_initial)) as cminitial, 
		cm.detalii
	from conmed cm
		left join personal p on p.marca=cm.Marca
		left join infoconmed icm on icm.marca=cm.Marca and icm.data=cm.data and icm.data_inceput=cm.data_inceput
		left outer join dbo.fDiagnostic_CM() d on d.tip_diagnostic=cm.Tip_diagnostic
	where cm.data=@data and cm.marca=@marca and cm.data_inceput=@data_inceput
	for xml raw

	select 1 as areDetaliiXml for xml raw, root('Mesaje')
end try 

begin catch
	set @mesaj=ERROR_MESSAGE() + ' (' + object_name(@@PROCID) + ')'
	select 1 as inchideFereastra for xml raw,root('Mesaje')
	raiserror(@mesaj,16,1)
end catch