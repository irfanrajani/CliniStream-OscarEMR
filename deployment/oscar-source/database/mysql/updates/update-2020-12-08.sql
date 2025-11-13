CREATE TABLE IF NOT EXIST `rbt_groups` (
  `id` int(11) AUTO_INCREMENT,
  `tid` int(11) ,
  `group_name` varchar(255) ,
  PRIMARY KEY (`id`)
);

-- the following are unrelated changes that are not implimented in OSCAR 19
-- ALTER TABLE document ADD COLUMN abnormal int(1);
-- ALTER TABLE document ADD COLUMN receivedDate date;
-- UPDATE document SET abnormal = 0 WHERE abnormal IS NULL;

-- ALTER TABLE `FaxClientLog` ADD COLUMN `transactionType` varchar(25) NULL AFTER `faxId`;

-- INSERT INTO `secObjectName`(`objectName`, `description`, `orgapplicable`) VALUES ('_fax', 'Send and Receive Faxes', 0);
-- INSERT INTO `secObjPrivilege`(`roleUserGroup`, `objectName`, `privilege`, `priority`, `provider_no`) VALUES ('-1', '_fax', 'x', 0, '999999');
-- INSERT INTO `secObjPrivilege`(`roleUserGroup`, `objectName`, `privilege`, `priority`, `provider_no`) VALUES ('admin', '_fax', 'x', 0, '999998');
-- INSERT INTO `secObjPrivilege`(`roleUserGroup`, `objectName`, `privilege`, `priority`, `provider_no`) VALUES ('doctor', '_fax', 'x', 0, '999998');