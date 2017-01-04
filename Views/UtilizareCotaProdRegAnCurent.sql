CREATE VIEW UtilizareCotaProdRegAnCurent AS
SELECT 
Cod_exploatatie
,CNP_CUI
,Producator
,DACL
,Tip_furnizor
,Centru_colectare
,Data_inc_an_cota
,Data_sf_an_cota
,An_cota
,Regiune
,Cant_UM
,Cant_UG
,Cant_STAS
,Cant_UM_cota
,Cant_UG_cota
,Cant_STAS_UM_cota
,Grad_actual
,Cota_actuala
,Cota_utilizata
,Proc_utiliz_cota
,Nr_luni_colecta_ramase
,Nr_luni_an_cota_ramase
,Cant_UM_rest_cota
,Gras_medie_rest_cota
FROM UtilizareCotaExplProdRegAnLuna(NULL,NULL,NULL,'P')