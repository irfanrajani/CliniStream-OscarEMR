CREATE TABLE AppointmentDxLink (
			id int(10)  NOT NULL auto_increment primary key,
			providerNo varchar(6),
			code varchar(20),
			codeType varchar(20),
			ageRange varchar(20),
			symbol varchar(20),
			colour varchar(20),
			message varchar(255),
			link varchar(255),
			updateDate datetime,
			createDate datetime,
			active boolean,
			KEY(code)
);
