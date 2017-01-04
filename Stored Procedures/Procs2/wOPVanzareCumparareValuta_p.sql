--***
create procedure wOPVanzareCumparareValuta_p @sesiune varchar(50), @parXML xml 
as  
begin try
	declare @cont_disp_valuta varchar(40), @cont_disp_lei varchar(40), @cont_trecere varchar(40), @lm varchar(13),@mesaj varchar(200),
		@denCont_disp_valuta varchar(100), @denCont_disp_lei varchar(100), @denCont_trecere varchar(100), @denLm varchar(100),
		@cont_dif_curs varchar(40),@denCont_chelt_dif_curs varchar(100),@denCont_venit_dif_curs varchar(100),
		@cu_dif_curs_cont_valuta int,@subtip varchar(2),@curs_BC float,
		@curs_BNR float,@ctCheltDifCF varchar(40),@CtVenDifcF varchar(40)
		
	exec luare_date_par 'GE','CDISPVAL','',0,@cont_disp_valuta output
	exec luare_date_par 'GE','CDISPRON','',0,@cont_disp_lei output
	exec luare_date_par 'GE','CTRVCVAL','',0,@cont_trecere output
	exec luare_date_par 'GE','LMVCVAL','',0,@lm output
	exec luare_date_par 'GE','DIFCVAL',@cu_dif_curs_cont_valuta output,0,'' 
	exec luare_date_par 'GE', 'DIFCH', 0, 0, @CtCheltDifcF output  
	exec luare_date_par 'GE', 'DIFVE', 0, 0, @CtVenDifcF output  
	
	/*IF (NOT (Cumparare (par)) AND Curs BNR (v)>Curs BC (v) OR Cumparare (par) AND Curs BNR (v)<Curs BC (v),'665','765')*/
	
	select @subtip=ISNULL(@parXML.value('(/row/row/@subtip)[1]', 'varchar(2)'), ''),
		@curs_BC=ISNULL(@parXML.value('(/row/row/@curs_BC)[1]', 'float'), 0),
		@curs_BNR=ISNULL(@parXML.value('(/row/row/@curs_BNR)[1]', 'float'), 0)
	
	select @denCont_disp_valuta=rtrim(cont)+'-'+rtrim(Denumire_cont) 
	from conturi where cont=@cont_disp_valuta
	
	select @denCont_disp_lei=rtrim(cont)+'-'+rtrim(Denumire_cont) 
	from conturi where cont=@cont_disp_lei

	select @denCont_trecere=rtrim(cont)+'-'+rtrim(Denumire_cont) 
	from conturi where cont=@cont_trecere

	select @denCont_chelt_dif_curs=rtrim(cont)+'-'+rtrim(Denumire_cont) 
	from conturi where cont=@ctCheltDifCF

	select @denCont_venit_dif_curs=rtrim(cont)+'-'+rtrim(Denumire_cont) 
	from conturi where cont=@CtVenDifcF

	select @denLm=rtrim(cod)+'-'+rtrim(Denumire) 
	from lm where cod=@lm	
	
	select  rtrim(@cont_disp_valuta) cont_disp_valuta,rtrim(@cont_disp_lei) cont_disp_lei,rtrim(@cont_trecere) cont_trecere,rtrim(@lm) lm,
		rtrim(@denCont_disp_valuta) denCont_disp_valuta,rtrim(@denCont_disp_lei) denCont_disp_lei,rtrim(@denCont_trecere) denCont_trecere,rtrim(@denLm) denLm,
		@cu_dif_curs_cont_valuta cu_dif_curs_cont_valuta, CONVERT(char(10),GETDATE(),101) as data, 
		@ctCheltDifCF as cont_chelt_dif_curs, rtrim(@denCont_chelt_dif_curs) as denCont_chelt_dif_curs, @CtVenDifcF as cont_venit_dif_curs, rtrim(@denCont_venit_dif_curs) as denCont_venit_dif_curs
	for xml raw

end try	
begin catch
set @mesaj = ERROR_MESSAGE()
	raiserror(@mesaj, 11, 1)	
end catch
--select * from conturi
