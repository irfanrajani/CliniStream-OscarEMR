CREATE TABLE `UAO` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `started` timestamp,
  `providerNo` varchar(25),
  `friendlyName` varchar(255),
  `name` varchar(255),
  `demographicNo` int(10),
  `resultCode` int(10),
  `defaultUAO` tinyint(1),
  `active` tinyint(1),
  `addedBy` varchar(25),
  `dateCreated` timestamp,
  `dateUpdated` timestamp,
  PRIMARY KEY (`id`)
  );
  
  alter table CVCImmunization add column shelfStatus varchar(255);
  
  