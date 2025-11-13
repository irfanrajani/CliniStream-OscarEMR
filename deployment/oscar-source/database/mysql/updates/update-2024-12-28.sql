-- update-2024-12-28.sql
-- add Inpatient MIP and Private Billing PRI service code billing forms
-- these form servicetype s are optional but necessary for complete functioning of the Ontario Billing page

DELIMITER $$

DROP PROCEDURE IF EXISTS `AddMIPbillingForm` $$
CREATE PROCEDURE `AddMIPbillingForm`()
theStart:BEGIN
    DECLARE FormIsThere INTEGER;

    SELECT COUNT(1) INTO FormIsThere
    FROM `ctl_billingservice`
    WHERE `servicetype` = "MIP";

    IF FormIsThere = 0 THEN
		SET @sqlstmt = "INSERT INTO `ctl_billingservice` (`servicetype_name`, `servicetype`, `service_code`, `service_group_name`, `service_group`, `status`, `service_order`) VALUES
		('Inpatients', 'MIP', 'E084A', 'Hospital', 'Group1', 'A', 1),
		('Inpatients', 'MIP', 'E083A', 'Hospital', 'Group1', 'A', 2),
		('Inpatients', 'MIP', 'E082A', 'Hospital', 'Group1', 'A', 3),
		('Inpatients', 'MIP', 'C933A', 'Hospital', 'Group1', 'A', 4),
		('Inpatients', 'MIP', 'C122A', 'Hospital', 'Group1', 'A', 5),
		('Inpatients', 'MIP', 'C123A', 'Hospital', 'Group1', 'A', 6),
		('Inpatients', 'MIP', 'C124A', 'Hospital', 'Group1', 'A', 7),
		('Inpatients', 'MIP', 'C007A', 'Hospital', 'Group1', 'A', 8),
		('Inpatients', 'MIP', 'C002A', 'Hospital', 'Group1', 'A', 9),
		('Inpatients', 'MIP', 'C008A', 'Hospital', 'Group1', 'A', 10),
		('Inpatients', 'MIP', 'C009A', 'Hospital', 'Group1', 'A', 11),
		('Inpatients', 'MIP', 'C010A', 'Hospital', 'Group1', 'A', 12),
		('Inpatients', 'MIP', 'H007A', 'Hospital', 'Group1', 'A', 13),
		('Inpatients', 'MIP', 'H001A', 'Hospital', 'Group1', 'A', 14),
		('Inpatients', 'MIP', 'K121A', 'Hospital', 'Group1', 'A', 15),
		('Inpatients', 'MIP', 'K023A', 'Hospital', 'Group1', 'A', 16),
		('Inpatients', 'MIP', 'C882A', 'Hospital', 'Group1', 'A', 17),
		('Inpatients', 'MIP', 'C903A', 'Hospital', 'Group1', 'A', 18),
		('Inpatients', 'MIP', 'C990A', 'Special Visit', 'Group2', 'A', 1),
		('Inpatients', 'MIP', 'C991A', 'Special Visit', 'Group2', 'A', 2),
		('Inpatients', 'MIP', 'C997A', 'Special Visit', 'Group2', 'A', 3),
		('Inpatients', 'MIP', 'C996A', 'Special Visit', 'Group2', 'A', 4),
		('Inpatients', 'MIP', 'C995A', 'Special Visit', 'Group2', 'A', 5),
		('Inpatients', 'MIP', 'C994A', 'Special Visit', 'Group2', 'A', 6),
		('Inpatients', 'MIP', 'C993A', 'Special Visit', 'Group2', 'A', 7),
		('Inpatients', 'MIP', 'C992A', 'Special Visit', 'Group2', 'A', 8),
		('Inpatients', 'MIP', 'C882A', 'Special Visit', 'Group2', 'A', 9),
		('Inpatients', 'MIP', 'W121A', 'Nursing Home', 'Group3', 'A', 1),
		('Inpatients', 'MIP', 'W994A', 'Nursing Home', 'Group3', 'A', 2),
		('Inpatients', 'MIP', 'W996A', 'Nursing Home', 'Group3', 'A', 3),
		('Inpatients', 'MIP', 'W992A', 'Nursing Home', 'Group3', 'A', 4),
		('Inpatients', 'MIP', 'W990A', 'Nursing Home', 'Group3', 'A', 5),
		('Inpatients', 'MIP', 'W010A', 'Nursing Home', 'Group3', 'A', 6),
		('Inpatients', 'MIP', 'W021A', 'Nursing Home', 'Group3', 'A', 7),
		('Inpatients', 'MIP', 'W022A', 'Nursing Home', 'Group3', 'A', 8),
		('Inpatients', 'MIP', 'W023A', 'Nursing Home', 'Group3', 'A', 9);";
		PREPARE st FROM @sqlstmt;
		EXECUTE st;
		DEALLOCATE PREPARE st;
	END IF;

END $$
DELIMITER ;

CALL AddMIPbillingForm();


DELIMITER $$

DROP PROCEDURE IF EXISTS `AddPRIbillingForm` $$
CREATE PROCEDURE `AddPRIbillingForm`()
theStart:BEGIN
    DECLARE FormIsThere INTEGER;

    SELECT COUNT(1) INTO FormIsThere
    FROM `ctl_billingservice`
    WHERE `servicetype` = "PRI";

    IF FormIsThere = 0 THEN
		SET @sqlstmt = "INSERT INTO `ctl_billingservice` (`servicetype_name`, `servicetype`, `service_code`, `service_group_name`, `service_group`, `status`, `service_order`) VALUES
		('Private Billing', 'PRI', 'A007A', 'ChangeMe', 'Group1', 'A', 1),
		('Private Billing', 'PRI', 'A007A', 'ChangeMe', 'Group2', 'A', 1),
		('Private Billing', 'PRI', 'A007A', 'ChangeMe', 'Group3', 'A', 1);";
		PREPARE st FROM @sqlstmt;
		EXECUTE st;
		DEALLOCATE PREPARE st;
	END IF;

END $$
DELIMITER ;

CALL AddPRIbillingForm();