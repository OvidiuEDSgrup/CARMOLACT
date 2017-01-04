CREATE TABLE [dbo].[masinexp] (
    [Numarul_mijlocului] CHAR (10) NOT NULL,
    [Descriere]          CHAR (30) NOT NULL,
    [Furnizor]           CHAR (13) NOT NULL,
    [Delegat]            CHAR (30) NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [idx_principal]
    ON [dbo].[masinexp]([Furnizor] ASC, [Numarul_mijlocului] ASC);


GO
create trigger yso_tr_masinExp on masinexp instead of insert, update, delete 
as
--if TRIGGER_NESTLEVEL()>2
	--return
BEGIN TRY
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 

	merge into masinexp i using (
		select actiune=(case when i.Numarul_mijlocului is null then 'DEL' when d.Numarul_mijlocului is null then 'INS' else 'UPD' end)
			,Numarul_mijlocului=isnull(i.Numarul_mijlocului,d.Numarul_mijlocului)
			,i.Descriere
			,Furnizor=isnull(i.Furnizor,d.Furnizor)
			,i.Delegat 
		from inserted i 
			full join deleted d on d.Numarul_mijlocului=i.Numarul_mijlocului and d.Furnizor=i.Furnizor
			inner join par t on t.Tip_parametru='UC' and t.Parametru='TERTGEN'
	) d on i.Numarul_mijlocului=d.Numarul_mijlocului and i.Furnizor=d.Furnizor
	when not matched then 
		insert (Numarul_mijlocului,Descriere,Furnizor,Delegat)
		values (Numarul_mijlocului,Descriere,Furnizor,Delegat)
	when matched and actiune='DEL' then
		delete
	when matched then
		update set Numarul_mijlocului=d.Numarul_mijlocului,Descriere=d.Descriere,Furnizor=d.Furnizor,Delegat=d.Delegat;

	merge into masinexp i using (
		select actiune=(case when i.Numarul_mijlocului is null then 'DEL' when d.Numarul_mijlocului is null then 'INS' else 'UPD' end)
			,Numarul_mijlocului=isnull(i.Numarul_mijlocului,d.Numarul_mijlocului)
			,i.Descriere
			,Furnizor=t.val_alfanumerica--isnull(i.Furnizor,d.Furnizor)
			,i.Delegat 
		from inserted i 
			full join deleted d on d.Numarul_mijlocului=i.Numarul_mijlocului and d.Furnizor=i.Furnizor
			inner join par t on t.Tip_parametru='UC' and t.Parametru='TERTGEN'
		where isnull(i.Furnizor,d.Furnizor)=''
	) d on i.Numarul_mijlocului=d.Numarul_mijlocului and i.Furnizor=d.Furnizor
	when not matched then 
		insert (Numarul_mijlocului,Descriere,Furnizor,Delegat)
		values (Numarul_mijlocului,Descriere,Furnizor,Delegat)
	when matched and actiune='DEL' then
		delete
	when matched then
		update set Numarul_mijlocului=d.Numarul_mijlocului,Descriere=d.Descriere,Furnizor=d.Furnizor,Delegat=d.Delegat;

END TRY
BEGIN CATCH
	declare @mesaj varchar(600)
	set @mesaj=ERROR_MESSAGE() + ' ('+OBJECT_NAME(@@PROCID)+')'
	raiserror (@mesaj, 15, 1)
END CATCH 
