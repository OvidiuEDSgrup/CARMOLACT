CREATE TABLE [dbo].[Contracte] (
    [idContract]             INT            IDENTITY (1, 1) NOT NULL,
    [tip]                    VARCHAR (2)    NULL,
    [numar]                  VARCHAR (20)   NULL,
    [data]                   DATETIME       NULL,
    [tert]                   VARCHAR (20)   NULL,
    [punct_livrare]          VARCHAR (20)   NULL,
    [gestiune]               VARCHAR (20)   NULL,
    [gestiune_primitoare]    VARCHAR (20)   NULL,
    [loc_de_munca]           VARCHAR (20)   NULL,
    [valuta]                 VARCHAR (3)    NULL,
    [curs]                   FLOAT (53)     NULL,
    [valabilitate]           DATETIME       NULL,
    [explicatii]             VARCHAR (8000) NULL,
    [detalii]                XML            NULL,
    [idContractCorespondent] INT            NULL,
    [AWB]                    VARCHAR (200)  NULL,
    PRIMARY KEY CLUSTERED ([idContract] ASC),
    CONSTRAINT [FK_Contracte_ContractCorespondent] FOREIGN KEY ([idContractCorespondent]) REFERENCES [dbo].[Contracte] ([idContract])
);


GO
CREATE NONCLUSTERED INDEX [missing_index_993]
    ON [dbo].[Contracte]([tip] ASC, [tert] ASC)
    INCLUDE([data], [detalii]);


GO
CREATE NONCLUSTERED INDEX [missing_index_990]
    ON [dbo].[Contracte]([tip] ASC, [tert] ASC, [data] ASC)
    INCLUDE([idContract], [valuta], [valabilitate]);


GO
CREATE NONCLUSTERED INDEX [missing_index_1021]
    ON [dbo].[Contracte]([tip] ASC)
    INCLUDE([idContract], [numar], [tert], [punct_livrare], [gestiune], [loc_de_munca], [valuta]);


GO
CREATE NONCLUSTERED INDEX [missing_index_125]
    ON [dbo].[Contracte]([tip] ASC, [tert] ASC)
    INCLUDE([data], [detalii]);


GO
CREATE NONCLUSTERED INDEX [missing_index_122]
    ON [dbo].[Contracte]([tip] ASC, [tert] ASC, [data] ASC)
    INCLUDE([idContract], [valuta], [valabilitate]);


GO
CREATE NONCLUSTERED INDEX [missing_index_441]
    ON [dbo].[Contracte]([tip] ASC)
    INCLUDE([idContract], [numar], [tert], [punct_livrare], [gestiune], [loc_de_munca], [valuta]);


GO
--***
create  trigger tr_ValidContracte on Contracte for insert,update,delete NOT FOR REPLICATION as

DECLARE @mesaj varchar(5000)
begin try	
	-- validare gestiune
	if update(gestiune)
	begin
		-- daca gestiunea nu e NULL, trebuie validata in catalogul de gestiuni
		select @mesaj = ISNULL(@mesaj+' ,', 'Gestiune necompletata sau invalida: ') + inserted.gestiune
		from inserted 
		where gestiune is not null 
		and not exists (select * from gestiuni g where Subunitate='1' and g.Cod_gestiune=inserted.gestiune)
		
		if @mesaj is not null
			raiserror(@mesaj,11, 1)
		end
	
	-- validare tert
	if update(tert)
	begin 
		-- daca tertul nu e NULL, trebuie validat in catalogul de terti
		select @mesaj = ISNULL(@mesaj+' ,', 'Tert necompletat sau invalid: ') + inserted.tert
		from inserted 
		where tert is not null
		and not exists (select * from terti t where Subunitate='1' and t.tert=inserted.tert)
		
		if @mesaj is not null
			raiserror(@mesaj,11, 1)		
	end
	
	-- validare punct livrare
	if update(punct_livrare)
	begin
		select @mesaj = ISNULL(@mesaj+' ,', 'Punct de livrare necompletat sau invalid: ') + inserted.punct_livrare
		from inserted 
		where punct_livrare is not null
		and not exists (select * from infotert it where Subunitate='1' and it.tert=inserted.tert and it.Identificator=punct_livrare and it.Identificator<>'')
		
		if @mesaj is not null
			raiserror(@mesaj,11, 1)
	end
	
	-- validare gestiune
	if update(gestiune_primitoare)
	begin
		-- daca gestiunea primitoare nu e NULL, trebuie validata in catalogul de gestiuni, daca nu e completat tertul
		select @mesaj = ISNULL(@mesaj+' ,', 'Gestiune primitoare necompletata sau invalida: ') + inserted.gestiune_primitoare
		from inserted 
		where gestiune_primitoare is not null
		and not exists (select * from gestiuni g where Subunitate='1' and g.Cod_gestiune=inserted.gestiune_primitoare)
		
		if @mesaj is not null
			raiserror(@mesaj,11, 1)	
	end
	
	-- validare loc de munca
	if update(loc_de_munca)
	begin
		-- daca lm nu e NULL, trebuie validat in catalogul de locuri de munca.
		select @mesaj = ISNULL(@mesaj+' ,', 'Loc de munca necompletat sau invalid: ') + inserted.loc_de_munca
		from inserted 
		where loc_de_munca is not null 
		and not exists (select * from lm where lm.Cod=inserted.loc_de_munca)
		
		if @mesaj is not null
			raiserror(@mesaj,11, 1)
	end
	
	-- validare valuta
	if update(valuta)
	begin
		-- la valuta permit momentan si ''. e corect?
		select @mesaj = ISNULL(@mesaj+' ,', 'Valuta introdusa nu exista in catalogul de valute: ') + inserted.gestiune_primitoare
		from inserted 
		where isnull(valuta,'')<>''
		and not exists (select * from valuta v where v.Valuta=inserted.valuta)
		
		if @mesaj is not null
			raiserror(@mesaj,11, 1)	
	end
	
	-- nu permitem valabilitate contract < data contract
	if update(valabilitate)
	begin
		if exists (select * from inserted where valabilitate<data)
			raiserror('Contractul trebuie sa aiba data valabilitatii ulterioara datei contractului.',11, 1)
	end
	
end try
begin catch
	--Daca exista erori
	ROLLBACK TRANSACTION
	set @mesaj = ERROR_MESSAGE()+ ' (tr_ValidContracte)'
	raiserror(@mesaj, 11, 1)
	RETURN
end catch
