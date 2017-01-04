CREATE VIEW AL_par AS
SELECT (SELECT RTRIM(MAX(val_alfanumerica)) from par where tip_parametru='GE' and parametru='NUME') AS NUME,
(SELECT RTRIM(MAX(val_alfanumerica)) from par where tip_parametru='GE' and parametru='CODFISC') AS CODFISC,
(SELECT RTRIM(MAX(val_alfanumerica)) from par where tip_parametru='GE' and parametru='ORDREG') AS ORDREG,
(SELECT RTRIM(MAX(val_alfanumerica)) from par where tip_parametru='GE' and parametru='JUDET') AS JUDET,
(SELECT RTRIM(MAX(val_alfanumerica)) from par where tip_parametru='GE' and parametru='SEDIU') AS SEDIU,
(SELECT RTRIM(MAX(val_alfanumerica)) from par where tip_parametru='GE' and parametru='ADRESA') AS ADRESA,
'Pct. lucru '+(SELECT 'Loc. '+RTRIM(MAX(val_alfanumerica)) from par where tip_parametru='PS' and parametru='LOCALIT') +
(SELECT ',str. '+RTRIM(MAX(val_alfanumerica)) from par where tip_parametru='PS' and parametru='STRADA') +
(SELECT ',nr. '+RTRIM(MAX(val_alfanumerica)) from par where tip_parametru='PS' and parametru='NUMAR') +
(SELECT ',jud. '+RTRIM(MAX(val_alfanumerica)) from par where tip_parametru='PS' and parametru='JUDET') AS PCTLUCRU,
(SELECT RTRIM(MAX(val_alfanumerica)) from par where tip_parametru='GE' and parametru='EMAIL') AS EMAIL,
(SELECT RTRIM(MAX(val_alfanumerica)) from par where tip_parametru='GE' and parametru='TELFAX') AS TELFAX, 
(SELECT RTRIM(MAX(val_alfanumerica)) from par where tip_parametru='AL' and parametru='CODFISC') AS CODFISCPCT,
(SELECT RTRIM(MAX(val_alfanumerica)) from par where tip_parametru='AL' and parametru='CUIREGCMP') AS CUIREGCMP, 
(SELECT RTRIM(MAX(val_alfanumerica)) from par where tip_parametru='AL' and parametru='REPRLEGAL') AS REPRLEGAL,
(SELECT RTRIM(MAX(val_alfanumerica)) from par where tip_parametru='AL' and parametru='SRBIREPR') AS SRBIREPR, 
(SELECT RTRIM(MAX(val_alfanumerica)) from par where tip_parametru='AL' and parametru='NRBIREPR') AS NRBIREPR,
(SELECT RTRIM(MAX(val_alfanumerica)) from par where tip_parametru='AL' and parametru='CNPREPR') AS CNPREPR,
(SELECT RTRIM(MAX(val_alfanumerica)) from par where tip_parametru='AL' and parametru='LABANALIZ') AS LABANALIZ,
(SELECT RTRIM(MAX(val_alfanumerica)) from par where tip_parametru='AL' and parametru='SEDIULAB') AS SEDIULAB