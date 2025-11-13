-- PHC per Earl W and Eugene R, speed up eforms  2022-12-02
DELIMITER $$

DROP PROCEDURE IF EXISTS `CreateIndex` $$
CREATE PROCEDURE `CreateIndex`
(
    given_table    VARCHAR(64),
    given_index    VARCHAR(64),
    given_columns  VARCHAR(64)

)
theStart:BEGIN

    DECLARE TableIsThere INTEGER;
    DECLARE IndexIsThere INTEGER;

    SELECT COUNT(1) INTO TableIsThere
    FROM INFORMATION_SCHEMA.STATISTICS
    WHERE table_schema = DATABASE()
    AND   table_name   = given_table;

    IF TableIsThere = 0 THEN
        SELECT CONCAT(given_database,'.',given_table, 
	' does not exist.  Unable to add ', given_index) CreateIndexMessage;
	LEAVE theStart;
    ELSE

	    SELECT COUNT(1) INTO IndexIsThere
	    FROM INFORMATION_SCHEMA.STATISTICS
	    WHERE table_schema = DATABASE()
	    AND   table_name   = given_table
	    AND   index_name   = given_index;

	    IF IndexIsThere = 0 THEN
		SET @sqlstmt = CONCAT('CREATE INDEX ',given_index,' ON ',
		DATABASE(),'.',given_table,' (',given_columns,')');
		PREPARE st FROM @sqlstmt;
		EXECUTE st;
		DEALLOCATE PREPARE st;
	    ELSE
		SELECT CONCAT('Index ',given_index,' Already Exists ON Table ',
		DATABASE(),'.',given_table) CreateIndexMessage;
	    END IF;

	END IF;

END $$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `DeleteIndex` $$
CREATE PROCEDURE DeleteIndex(
    given_table    VARCHAR(64),
    given_idx      VARCHAR(64)
)

theStart:BEGIN

    DECLARE TableIsThere INTEGER;
    DECLARE IdxIsThere INTEGER;

    SELECT COUNT(1) INTO TableIsThere
    FROM INFORMATION_SCHEMA.STATISTICS
    WHERE table_schema = DATABASE()
    AND   table_name   = given_table;

    IF TableIsThere = 0 THEN
        SELECT CONCAT(DATABASE(),'.',given_table, 
	' does not exist.  Unable to delete ', given_idx) DeleteIndexMessage;
	LEAVE theStart;
    ELSE
        SET IdxIsThere = (  SELECT COUNT(*) 
                    FROM INFORMATION_SCHEMA.STATISTICS
                    WHERE   TABLE_SCHEMA = DATABASE() AND 
                            TABLE_NAME = given_table AND 
                            INDEX_NAME = given_idx );
        IF IdxIsThere = 1 THEN
 		    SET @sqlstmt = CONCAT('ALTER TABLE ',DATABASE(),'.',given_table,' DROP INDEX ',given_idx);
		    PREPARE st FROM @sqlstmt;
		    EXECUTE st;
		    DEALLOCATE PREPARE st;
	    ELSE
		    SELECT CONCAT('Index ',given_idx,' doesnt exist ON Table ',
		    DATABASE(),'.',given_table) DeleteIndexMessage;
	    END IF;
	 END IF;

END $$
DELIMITER ;


CALL CreateIndex('eform_data','idx_eform_data_fid_status_demo','`fid`, `status`, `demographic_no`');
CALL DeleteIndex('eform_data','idx_eform_data_fid');
CALL DeleteIndex('eform_data','id');
CALL DeleteIndex('eform_data','idx_eform_data_fid');
CALL DeleteIndex('eform_data','idx_eform_data_status');
CALL DeleteIndex('eform_data','patient_independentIndex');


CALL CreateIndex('eform_values','idx_eform_values_demo_varname_varvalue','`demographic_no`, `var_name`, `var_value`(30)');
CALL CreateIndex('eform_values','idx_eform_values_fdid_varname','`fdid`, `var_name`');
CALL DeleteIndex('eform_values','fdidIndex');
CALL DeleteIndex('eform_values','eform_values_varname_varvalue');