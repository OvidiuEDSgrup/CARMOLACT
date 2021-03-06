﻿--***
/*	functie Calcul medie zilnica */
Create function fPSCalculMedieZilnicaCM 
	(@Data datetime, @Marca char(6), @TipDiagnostic char(2), @DataInceput datetime, @ZileCMAnt int, @Continuare int, @AccMunca int, @NrCertificatCMInitial char(10))
returns decimal(10,4)
As
Begin
	declare @MediaZilnica decimal(10,5), @bazaStagiu decimal(10), @zileStagiu int
	set @MediaZilnica=0

--	preluare medie zilnica de pe concediul medical din luna anterioara
	If @ZileCMAnt<>0 or @NrCertificatCMInitial<>''
	Begin
		Select @MediaZilnica=isnull(a.Indemnizatia_zi,0)
		from conmed a
			left outer join infoconmed b on a.Data=b.Data and a.Marca=b.Marca and a.Data_inceput=b.Data_inceput
		where a.Data=dbo.eom(DateAdd(month,-1,@DataInceput)) and a.Marca=@Marca and Data_sfarsit=DateAdd(day,-1,@DataInceput)
			and @NrCertificatCMInitial<>'' and (b.Nr_certificat_CM=@NrCertificatCMInitial or b.Nr_certificat_CM_initial=@NrCertificatCMInitial)
	End

--	preluare medie zilnica de pe concediul medical anterior
	if (@ZileCMAnt>0 or @NrCertificatCMInitial<>'') and @MediaZilnica=0
	Begin
		Select @MediaZilnica=isnull(a.Indemnizatia_zi,0)
		from conmed a
			left outer join infoconmed b on a.Data=b.Data and a.Marca=b.Marca and a.Data_inceput=b.Data_inceput
		where a.Data=@Data and a.Marca=@Marca and Data_sfarsit=DateAdd(day,-1,@DataInceput)
			and @NrCertificatCMInitial<>'' and (b.Nr_certificat_CM=@NrCertificatCMInitial or b.Nr_certificat_CM_initial=@NrCertificatCMInitial)
	End 

--	calcul medie zilnica tinand cont de stagiul de cotizare
	if @ZileCMAnt=0 and @TipDiagnostic<>'0-' and @MediaZilnica=0
	Begin
		select	@bazaStagiu=nullif(detalii.value('(/row/@bazastagiu)[1]','decimal(10)'),0), 
				@zileStagiu=nullif(detalii.value('(/row/@zilestagiu)[1]','int'),0)
		from conmed where data=@data and marca=@marca and data_inceput=@DataInceput
		Select @MediaZilnica=isnull(@bazaStagiu,sum(Baza_cci_plaf))/(case when isnull(@zileStagiu,sum(Zile_asig))=0 and isnull(@bazaStagiu,sum(Baza_cci_plaf))=0 then 1 else isnull(@zileStagiu,sum(Zile_asig)) end)
		from dbo.fIstoric_cm(@Data, @Marca, @TipDiagnostic, @DataInceput, @Continuare, @AccMunca, 0) 
	End
	if @DataInceput<'02/01/2011'
		select @MediaZilnica=convert(decimal(10,4),@MediaZilnica)
	else 
		select @MediaZilnica=convert(decimal(10,2),convert(decimal(10,5),@MediaZilnica))
	return isnull(@MediaZilnica,0)
End
