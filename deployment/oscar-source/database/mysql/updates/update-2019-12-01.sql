INSERT INTO measurementType (type, typeDisplayName, typeDescription, measuringInstruction, createDate, validation) values
( 'MDRC', 'Med Rec', 'Med Rec', 'Completed', now(),
(select id from validations where name='yes/no' limit 1));