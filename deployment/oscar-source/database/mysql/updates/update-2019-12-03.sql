CREATE TABLE CVCImmunizationName (
    id int(11) auto_increment,
    language varchar(30),
    useSystem varchar(255),
    useCode varchar(255),
    useDisplay varchar(255),
    value varchar(255),
    PRIMARY KEY(id)
);

insert into secObjectName values ('_prevention.updateCVC',NULL,0);
insert into secObjPrivilege values('admin','_prevention.updateCVC','x',0,'999998');

create table DHIRTransactionLog (
  id int(11) auto_increment,
  started timestamp not null,
  initiatingProviderNo varchar(25),
  transactionType varchar(25),
  externalSystem varchar(50),
  demographicNo int(10),
  resultCode int(10),
  success tinyint(1),
  error mediumtext,
  headers mediumtext,
  PRIMARY KEY(id)
);

alter table CVCImmunization add typicalDose varchar(255);
alter table CVCImmunization add typicalDoseUofM varchar(255);
alter table CVCImmunization add strength varchar(255);
