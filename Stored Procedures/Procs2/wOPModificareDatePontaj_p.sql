create procedure wOPModificareDatePontaj_p @sesiune varchar(50), @parXML xml
as
begin try
	declare @utilizator varchar(10), @data datetime, @marca varchar(6), @lm varchar(9), @nrcrt int, @mesaj varchar(1000)

	select	@data = isnull(@parXML.value('(/*/@data)[1]','datetime'),''),
			@marca = isnull(@parXML.value('(/*/row/@marca)[1]', 'varchar(6)'),''),	
			@lm = isnull(@parXML.value('(/*/row/@lm)[1]', 'varchar(9)'),''),	
			@nrcrt = @parXML.value('(/*/row/@nrcrt)[1]', 'int')

	if @nrcrt is null
	begin
		raiserror( 'Operatie de modificare date pozitie nepermisa pe antetul machetei de pontaj, selectati un pontaj!',11,1)
	end  

	select rtrim(po.marca) marca, RTRIM(p.nume) densalariat, convert(varchar(10),po.data,101) data, 
		rtrim(p.loc_de_munca) as lm, rtrim(lm.denumire) as denlm, 
		po.numar_curent as nrcrt, po.Tip_salarizare as tipsal, convert(decimal(12,4),po.Salar_categoria_lucrarii) as salcatl
	from pontaj po
		left join personal p on p.marca=po.Marca
		left join lm on lm.cod=po.Loc_de_munca
	where po.data=@data and po.marca=@marca and po.Loc_de_munca=@lm and po.Numar_curent=@nrcrt
	for xml raw

	select 1 as areDetaliiXml for xml raw, root('Mesaje')
end try 

begin catch
	set @mesaj=ERROR_MESSAGE() + ' (' + object_name(@@PROCID) + ')'
	select 1 as inchideFereastra for xml raw,root('Mesaje')
	raiserror(@mesaj,16,1)
end catch