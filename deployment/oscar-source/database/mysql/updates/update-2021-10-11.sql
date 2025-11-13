ALTER TABLE `DemographicContact` ADD `best_contact` VARCHAR(30) AFTER `mrp`;
ALTER TABLE `DemographicContact` ADD `health_care_team` BOOLEAN AFTER `best_contact`;