
CREATE PROCEDURE wIaFormuleContabile @sesiune varchar(50), @parXML xml
AS
BEGIN
	
	DECLARE @f_cont_debit varchar(100), @f_cont_credit varchar(100), @f_tipdoc varchar(50)
	
	SELECT @f_cont_debit = '%' + REPLACE(ISNULL(@parXML.value('(/row/@f_cont_debit)[1]', 'varchar(100)'), '%'), ' ', '%') + '%',
		@f_cont_credit = '%' + REPLACE(ISNULL(@parXML.value('(/row/@f_cont_credit)[1]', 'varchar(100)'), '%'), ' ', '%') + '%',
		@f_tipdoc = ISNULL(@parXML.value('(/row/@f_tipdoc)[1]', 'varchar(50)'), '')

	SELECT fc.tip AS tipdoc, fc.utilizator AS utilizator,
		fc.cont_debit AS cont_debit, RTRIM(cd.Denumire_cont) AS dencont_debit,
		fc.cont_credit AS cont_credit, RTRIM(cc.Denumire_cont) AS dencont_credit,
		CONVERT(varchar(10), fc.data_operarii, 103) + ' ' + CONVERT(varchar(8), fc.data_operarii, 108) AS data_operarii
	FROM FormuleContabile fc
	INNER JOIN conturi cd ON cd.Cont = fc.cont_debit
	INNER JOIN conturi cc ON cc.Cont = fc.cont_credit
	WHERE (@f_tipdoc = '' OR fc.tip LIKE @f_tipdoc + '%')
		AND (ISNULL(cd.Cont, '') LIKE @f_cont_debit OR ISNULL(cd.Denumire_cont, '') LIKE @f_cont_debit)
		AND (ISNULL(cc.Cont, '') LIKE @f_cont_credit OR ISNULL(cc.Denumire_cont, '') LIKE @f_cont_credit)
	ORDER BY fc.tip, fc.data_operarii
	FOR XML RAW, ROOT('Date')

END
