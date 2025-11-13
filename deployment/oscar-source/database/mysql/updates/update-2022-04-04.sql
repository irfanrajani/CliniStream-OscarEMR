-- update demographicArchive to better match demographic
ALTER TABLE `demographicArchive` 
ADD `pref_name` VARCHAR(30) NOT NULL AFTER `residentialPostal`, 
ADD `family_physician` VARCHAR(80) NOT NULL AFTER `pref_name`, 
ADD `consentToUseEmailForCare` TINYINT(1) NOT NULL AFTER `family_physician`;