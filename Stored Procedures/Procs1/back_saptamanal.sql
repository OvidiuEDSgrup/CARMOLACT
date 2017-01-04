CREATE 
Procedure [dbo].[back_saptamanal]
As

exec CARMOLACT..back_zilnic 'E:\ARHIVA_BAZA_DATE\SISTEM\', 'master'
exec CARMOLACT..back_zilnic 'E:\ARHIVA_BAZA_DATE\SISTEM\', 'model'
exec CARMOLACT..back_zilnic 'E:\ARHIVA_BAZA_DATE\SISTEM\', 'msdb'
exec CARMOLACT..back_zilnic 'E:\ARHIVA_BAZA_DATE\SISTEM\', 'tempdb'
exec CARMOLACT..back_zilnic 'E:\ARHIVA_BAZA_DATE\SISTEM\', 'ReportServer'
exec CARMOLACT..back_zilnic 'E:\ARHIVA_BAZA_DATE\SISTEM\', 'ReportServertempDB'
