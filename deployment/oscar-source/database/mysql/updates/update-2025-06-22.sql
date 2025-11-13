-- update-2025-06-22.sql fixes some database truncation errors
ALTER TABLE `billing` CHANGE `total` `total` VARCHAR(7) ;

-- the following is a BC specific billing table
ALTER TABLE `billingmaster` CHANGE `oin_postalcode` `oin_postalcode` VARCHAR(7) ;