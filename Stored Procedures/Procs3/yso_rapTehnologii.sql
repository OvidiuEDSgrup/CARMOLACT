
CREATE PROCEDURE yso_rapTehnologii @codTehnologie varchar(20), @peNivele INT
AS
select * from tehnologii t
where (ISNULL(@codTehnologie,'')='' or t.cod=@codTehnologie)