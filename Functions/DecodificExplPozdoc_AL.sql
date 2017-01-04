CREATE FUNCTION [dbo].[DecodificExplPozdoc_AL] 
(
	-- Add the parameters for the function here
	@inf char(1),
	@txtexpl char(4000)
)
RETURNS char(20)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @valinf char(20), @rtxtexpl char(4000)

	SET @txtexpl= UPPER(@txtexpl)

	IF RTRIM(@inf)=''
	BEGIN
		SET @valinf= SUBSTRING( @txtexpl, PATINDEX('%[0-9][0-9][0-9][0-9][0-9]%',@txtexpl), 
								CASE PATINDEX('%[0-9][0-9][0-9][0-9][0-9]%',@txtexpl) WHEN 0 THEN 0 ELSE 5 END)
	END
	ELSE
	BEGIN
		SET @rtxtexpl= SUBSTRING( @txtexpl, CHARINDEX(@inf,@txtexpl)+1, CASE CHARINDEX(@inf,@txtexpl) WHEN 0 THEN 0 ELSE 4000 END)
		
		IF @inf<>'R'
		SET @valinf= REPLACE(SUBSTRING( @rtxtexpl, 1, 
								CASE PATINDEX(/*'%['+REPLACE('CGSDAP',@inf,'')+']%'*/'%[A-Z]%',@rtxtexpl) WHEN 0 THEN LEN(RTRIM(@rtxtexpl)) 
									ELSE PATINDEX(/*'%['+REPLACE('CGSDAP',@inf,'')+']%'*/'%[A-Z]%',@rtxtexpl)-1 END),' ','')
		ELSE
		SET @valinf= REPLACE(SUBSTRING( @rtxtexpl, 1, 
								CASE PATINDEX(/*'%['+REPLACE('CGSDAP',@inf,'')+']%'*/'%[A-Z]%',@rtxtexpl) WHEN 0 THEN 'P'--LEN(RTRIM(@rtxtexpl)) 
									ELSE PATINDEX(/*'%['+REPLACE('CGSDAP',@inf,'')+']%'*/'%[A-Z]%',@rtxtexpl)-1 END),' ','')		
		SET @valinf= REPLACE(@valinf, ',', '.')
		IF ISNUMERIC(@valinf)=0 
			SET @valinf='0'
	END
	-- Add the T-SQL statements to compute the return value here
	
	--select isnumeric('2,9')
	-- Return the result of the function
	RETURN RTRIM(LTRIM(@valinf))

END