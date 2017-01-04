CREATE VIEW dbo.IDEAL_ERPCLIENTI
AS
SELECT        TOP (100) PERCENT dbo.terti.Denumire, CASE WHEN infotert.identificator = '' THEN rtrim(terti.adresa) ELSE rtrim(infotert.Descriere) END AS ADRESA, dbo.terti.Localitate, dbo.terti.Judet, 
                         ISNULL(dbo.infotert.Identificator, ' ') AS ECODSEDIU, dbo.terti.Cod_fiscal AS CUI, dbo.terti.Banca, dbo.terti.Cont_in_banca AS CONT, dbo.terti.Telefon_fax AS TELEFON, '' AS CONTACT, 
                         dbo.terti.Disccount_acordat AS DISCOUNT, dbo.infotert.Discount AS TERMENPLATA, dbo.terti.Sold_ca_beneficiar AS CATEGPRET, dbo.terti.Grupa AS ECODGRUPA, dbo.terti.Tert AS ECOD, 
                         dbo.infotert.Loc_munca AS ECODAGENT, dbo.infotert.Zile_inc AS ZIROUTING, CASE WHEN infotert.identificator = '' THEN 'XX' ELSE infotert.identificator END AS Expr1, dbo.infotert.Observatii AS GESTIUNE, 
                         dbo.terti.Sold_maxim_ca_beneficiar AS credit_maxim
FROM            dbo.terti LEFT OUTER JOIN
                         dbo.IDEAL_ERPAGENTI RIGHT OUTER JOIN
                         dbo.infotert ON dbo.IDEAL_ERPAGENTI.ECOD = dbo.infotert.Loc_munca ON dbo.terti.Tert = dbo.infotert.Tert

GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[24] 4[20] 2[15] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1[49] 4[26] 3) )"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1[23] 4) )"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = -48
      End
      Begin Tables = 
         Begin Table = "terti"
            Begin Extent = 
               Top = 7
               Left = 653
               Bottom = 320
               Right = 859
            End
            DisplayFlags = 280
            TopColumn = 5
         End
         Begin Table = "IDEAL_ERPAGENTI"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 249
               Right = 189
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "infotert"
            Begin Extent = 
               Top = 5
               Left = 347
               Bottom = 446
               Right = 505
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 21
         Width = 284
         Width = 1860
         Width = 2040
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 7380
         Alias = 3090
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'IDEAL_ERPCLIENTI';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N' = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'IDEAL_ERPCLIENTI';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'IDEAL_ERPCLIENTI';

