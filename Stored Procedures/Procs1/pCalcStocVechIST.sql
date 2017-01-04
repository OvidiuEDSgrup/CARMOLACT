Create procedure [dbo].[pCalcStocVechIST] @parDRef datetime, @parSub char(9), @parTipGest char(1), @parGest char(9), @parCod char(20),@i1 int , @i2 int , @i3 int , @i4 int, @zileDif int, 
@parStoc1 float OUTPUT,@parStoc2 float OUTPUT,@parStoc3 float OUTPUT,@parStoc4 float OUTPUT,@parStoc5 float OUTPUT,
@parVal1 float OUTPUT,@parVal2 float OUTPUT,@parVal3 float OUTPUT,@parVal4 float OUTPUT,@parVal5 float OUTPUT
as

Declare @calcData datetime, @calcPret float, @calcStoc float, @calcFetch int, @interval int
Set @parStoc1 = 0 Set @parStoc2 = 0 Set @parStoc3 = 0 Set @parStoc4 = 0 Set @parStoc5 = 0
Set @parVal1 = 0  Set @parVal2 = 0 Set @parVal3 = 0 Set @parVal4 = 0 Set @parVal5 = 0
Declare tmpCalcul cursor for
Select data,pret,stoc from isstoc 
where subunitate = @parSub and tip_gestiune = @parTipGest and cod_gestiune = @parGest and cod = @parCod	
and (@parDRef - data) >= @zileDif

Open tmpCalcul
Fetch next from tmpCalcul into @calcData,@calcPret,@calcStoc
Set @calcFetch = @@Fetch_status
	while @calcFetch = 0
		Begin
			If @calcData >= @parDRef - @i1 and @calcData <= @parDRef 
				Begin 
					Set @parStoc1 = @parStoc1 + @calcStoc
					Set @parVal1 = @parVal1 + @calcStoc *@calcPret
				end
			If @calcData >= @parDRef - @i2 and  @calcData < @parDRef - @i1
				Begin 
					Set @parStoc2 = @parStoc2 + @calcStoc
					Set @parVal2 = @parVal2 + @calcStoc *@calcPret
				end
			If @calcData >= @parDRef - @i3 and  @calcData < @parDRef - @i2
				Begin 
					Set @parStoc3 = @parStoc3 + @calcStoc
					Set @parVal3 = @parVal3 + @calcStoc *@calcPret
				end
			If @calcData >= @parDRef - @i4 and  @calcData < @parDRef - @i3
				Begin 
					Set @parStoc4 = @parStoc4 + @calcStoc
					Set @parVal4 = @parVal4 + @calcStoc *@calcPret
				end
			If  @calcData < @parDRef - @i4
				Begin 
					Set @parStoc5 = @parStoc5 + @calcStoc
					Set @parVal5 = @parVal5 + @calcStoc *@calcPret
				end	
					
			Fetch next from tmpCalcul into @calcData,@calcPret,@calcStoc
			Set @calcFetch = @@Fetch_status
		End
Close tmpCalcul
Deallocate tmpCalcul
