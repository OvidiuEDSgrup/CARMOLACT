--***
/**	functie fDiagnostic CM	*/
Create function fDiagnostic_CM()
returns @diagnostic_cm table
	(Tip_diagnostic char(2), Denumire char(40), tip_diagnostic_certificat varchar(2))
as
	begin
	insert @diagnostic_cm
	select '0-', 'Ingrij. copil 2 ani', '0-'
	union all 
	select '1-', 'Boala obisnuita', '01'
	union all
	select '2-', 'Acc. depl. munca', '02'
	union all 
	select '3-', 'Acc. Munca', '03'
	union all
	select '4-', 'Boala profesionala', '04'
	union all
	select '5-', 'Boala infecto-contagioasa din grupa A', '05'
	union all
	select '6-', 'Urgenta medico-chirurgicala', '06'
	union all 
	select '7-', 'Carantina', '07'
	union all
	select '8-', 'Sarcina si lahuzie', '08'
	union all
	select '9-', 'Ingrijire copil bolnav', '09'
	union all
	select '10', 'Reducerea cu 1/4 reg.lucru', '10'
	union all 
	select '11', 'Trecere in alt locm', '11' 
	union all
	select '12', 'Tuberculoza', '12' 
	union all
	select '13', 'Boala cardio-vasculara', '13' 
	union all
	select '14', 'Cancer, HIV, SIDA', '14' 
	union all
	select '15', 'Risc maternal', '15' 

	return 
end
