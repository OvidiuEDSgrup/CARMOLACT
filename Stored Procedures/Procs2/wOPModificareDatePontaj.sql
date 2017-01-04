/* operatie pt. modificare date pozitie in macheta de pontaj, Pentru inceput vom trata tipul de salarizare si salar categoria lucrarii. */
create procedure wOPModificareDatePontaj (@sesiune varchar(50), @parXML xml) 
as     
declare @utilizator varchar(10), @Data datetime, @marca varchar(6), @lm varchar(9), @nrcrt int, @tipsal char(1), @salcatl decimal(12,4), @mesaj varchar(1000)
begin try
	exec wIaUtilizator @sesiune=@sesiune, @utilizator=@utilizator output

	select	@data = isnull(@parXML.value('(/*/@data)[1]','datetime'),''),
			@marca = isnull(@parXML.value('(/*/@marca)[1]', 'varchar(6)'),''),	
			@lm = isnull(@parXML.value('(/*/@lm)[1]', 'varchar(9)'),''),
			@nrcrt = @parXML.value('(/*/@nrcrt)[1]', 'int'),
			@tipsal = @parXML.value('(/*/@tipsal)[1]', 'char(1)'),
			@salcatl = @parXML.value('(/*/@salcatl)[1]', 'decimal(12,4)')

	if @nrcrt is null
		raiserror('Selectati pontajul unui salariat!',11,1)

	update pontaj set 
		tip_salarizare = isnull(@tipsal,tip_salarizare), 
		Salar_categoria_lucrarii=isnull(@salcatl,Salar_categoria_lucrarii)
	where data=@data and marca=@marca and Numar_curent=@nrcrt
  
end try

begin catch
	set @mesaj = ERROR_MESSAGE() + ' (' + object_name(@@PROCID) + ')'
	raiserror(@mesaj, 11, 1)	
end catch