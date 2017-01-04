CREATE TABLE [dbo].[delegexp] (
    [Numele_delegatului] CHAR (30) NOT NULL,
    [Seria_buletin]      CHAR (10) NOT NULL,
    [Numar_buletin]      CHAR (10) NOT NULL,
    [Eliberat]           CHAR (30) NOT NULL,
    [Loc_de_munca]       CHAR (10) NOT NULL,
    [Marca]              CHAR (13) NOT NULL,
    [id]                 SMALLINT  IDENTITY (-1, -1) NOT NULL,
    PRIMARY KEY NONCLUSTERED ([id] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Delegat]
    ON [dbo].[delegexp]([Numele_delegatului] ASC);


GO
CREATE NONCLUSTERED INDEX [Marca]
    ON [dbo].[delegexp]([Marca] ASC);


GO
create trigger yso_tr_actualizeazaDelegatiTertGen on delegexp after insert, update, delete 
as
--if TRIGGER_NESTLEVEL()>2
	--return
BEGIN TRY
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 

	merge into infotert i using (
		select actiune=(case when i.id is null then 'DEL' when d.id is null then 'INS' else 'UPD' end)
			,Subunitate='C'+ltrim(rtrim(s.Val_alfanumerica))
			,Tert=ltrim(rtrim(t.Val_alfanumerica))
			,Identificator=rtrim(abs(isnull(i.id,d.id)))
			,Descriere=rtrim(i.Numele_delegatului)
			,Loc_munca=left(i.Loc_de_munca,9)
			,Pers_contact=substring(i.Numele_delegatului,1,charindex(' ',i.Numele_delegatului)-1)
			,Nume_delegat=substring(i.Numele_delegatului,charindex(' ',i.Numele_delegatului)+1,len(i.Numele_delegatului))
			,Buletin=left(rtrim(isnull(i.Seria_buletin, '')) + ',' + rtrim(isnull(i.Numar_buletin, '')),12)
			,Eliberat=rtrim(i.Eliberat) 
		from inserted i 
			full join deleted d on d.id=i.id
			inner join par s on s.Tip_parametru='GE' and s.Parametru='SUBPRO'
			inner join par t on t.Tip_parametru='UC' and t.Parametru='TERTGEN'
	) d on i.subunitate=d.subunitate and i.tert=d.tert and i.identificator=d.identificator
	when not matched and actiune<>'DEL' then
		insert (Subunitate,Tert,Identificator,Descriere,Loc_munca
				,Pers_contact,Nume_delegat,Buletin,Eliberat,Mijloc_tp,Adresa2,Telefon_fax2,e_mail,Banca2,Cont_in_banca2,Banca3,Cont_in_banca3,Indicator,Grupa13,Sold_ben,Discount,Zile_inc,Observatii,codRuta)
		values (Subunitate,Tert,Identificator,Descriere,Loc_munca
				,Pers_contact,Nume_delegat,Buletin,Eliberat
				,'','','','','','','','','','','','','','',null)
	when matched and actiune='DEL' then
		delete
	when matched then
		update set Subunitate=d.Subunitate
			,Tert=d.Tert
			,Identificator=d.Identificator
			,Descriere=d.Descriere
			,Loc_munca=d.Loc_munca
			,Pers_contact=d.Pers_contact
			,Nume_delegat=d.Nume_delegat
			,Buletin=d.Buletin
			,Eliberat=d.Eliberat;
END TRY
BEGIN CATCH
	declare @mesaj varchar(600)
	set @mesaj=ERROR_MESSAGE() + ' ('+OBJECT_NAME(@@PROCID)+')'
	raiserror (@mesaj, 15, 1)
END CATCH 
