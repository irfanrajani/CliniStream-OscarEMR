-- update-2022-01-01.sql adds TOTP columns to security and SecurityArchive

ALTER TABLE `security`
ADD COLUMN (
  `totp_enabled` TINYINT(1) COMMENT 'controls 2-factor authentication; 0=off; 1=enabled',
  `totp_secret` VARCHAR(254)  COMMENT '2-factor authetication BASE32-encoded secret',
  `totp_digits` SMALLINT(4)  COMMENT 'number of digits the 2FA token defaults to 6',
  `totp_algorithm` VARCHAR(50) COMMENT 'encryption algorithm for 2FA either defaults to sha1',
  `totp_period` SMALLINT COMMENT 'duration of validity for each TOTP code in seconds defaults to 30');

ALTER TABLE `SecurityArchive`
ADD COLUMN (
  `oneIdKey` varchar(255),
  `oneIdEmail` varchar(255),
  `delegateOneIdEmail` varchar(255),
  `totp_enabled` smallint(1) NOT NULL,
  `totp_secret` varchar(254) NOT NULL,
  `totp_algorithm` varchar(50) NOT NULL,
  `totp_digits` smallint(6) NOT NULL,
  `totp_period` smallint(6) NOT NULL);