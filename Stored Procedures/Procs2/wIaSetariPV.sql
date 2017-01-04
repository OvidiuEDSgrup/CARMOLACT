/* 
procedura folosita pentru a citi setari de PV de pe server.
Pentru inceput se citeste doar setarea de ping server daca nu se lucreaza cu aplicatia, 
dar in viitor vom trimite setarile aplicatiei PV de pe server. */
create procedure wIaSetariPV @sesiune varchar(50), @parXML xml
as
if exists(select * from sysobjects where name='wIaSetariPVSP' and type='P')      
begin
	exec wIaSetariPVSP @sesiune,@parXML      
	return 
end

set transaction isolation level read uncommitted

declare @ping int, @textButonConfigurabil varchar(50), @codIncasareConfigurabila int, @descarcarePrioritara bit, @bonCuFormular bit,
		@fidelizare bit, @idIncasareCard bit, @cereDetaliiBon bit, @nivelProcesarePeServer int, @incasariPeFacturi int

exec luare_date_par 'PV','PING',0, @ping output, ''
--exec luare_date_par 'PV','INCCONF3',0, @codIncasareConfigurabila output, @textButonConfigurabil output
--exec luare_date_par 'PV','CERDETBON', @cereDetaliiBon output, 0 , '' 
exec luare_date_par 'PV','DESCPRIOR', @descarcarePrioritara output, 0, ''
exec luare_date_par 'PV','BONCUFORM', @bonCuFormular output, 0, ''
exec luare_date_par 'PV','FIDELIZ', @fidelizare output, 0 , '' 
exec luare_date_par 'PV','IDINCCARD', @idIncasareCard output, 0 , '' 
exec luare_date_par 'PV','PROCESARE',0, @nivelProcesarePeServer output, ''
exec luare_date_par 'PV','INCPEFACT',0, @incasariPeFacturi output, ''

select @ping secundePing, @descarcarePrioritara descarcarePrioritara, @bonCuFormular as bonCuFormular, @fidelizare carduriFidelizare,
	@idIncasareCard idIncasareCard, @cereDetaliiBon cereDetaliiBon, @nivelProcesarePeServer nivelProcesarePeServer,
	@incasariPeFacturi incasariPeFacturi
for xml raw, root('Date')

