-- match archive table to prevent truncation errors
ALTER TABLE `favorites` CHANGE `BN` `BN` VARCHAR(255);
ALTER TABLE `measurementTypeDeleted` CHANGE `typeDisplayName` `typeDisplayName` VARCHAR(255);

-- without UNIQUE indices this can only be run once

INSERT INTO `measurementType`( `type`, `typeDisplayName`, `typeDescription`, `measuringInstruction`, `validation`, `createDate`) 
SELECT 'CRL', 'CRL', 'CRL', 'in mm', `validations`.`id`, '2024-01-01 00:00:01'
FROM `validations`
WHERE `validations`.`name` = "Numeric Value: 0 to 100"
ON DUPLICATE KEY UPDATE `type`=`type`;

INSERT INTO `measurementType`( `type`, `typeDisplayName`, `typeDescription`, `measuringInstruction`, `validation`, `createDate`) 
SELECT 'ECTP', 'Ectopic Pregnancies', 'ECTP', 'number', `validations`.`id`, '2024-01-01 00:00:01'
FROM `validations`
WHERE `validations`.`name` = "Numeric Value: 0 to 100"
ON DUPLICATE KEY UPDATE `type`=`type`;

INSERT INTO `measurementType`( `type`, `typeDisplayName`, `typeDescription`, `measuringInstruction`, `validation`, `createDate`) 
SELECT 'PRET', 'Preterm deliveries', 'PRET', 'number', `validations`.`id`, '2024-01-01 00:00:01'
FROM `validations`
WHERE `validations`.`name` = "Numeric Value: 0 to 100"
ON DUPLICATE KEY UPDATE `type`=`type`;

INSERT INTO `measurementType`( `type`, `typeDisplayName`, `typeDescription`, `measuringInstruction`, `validation`, `createDate`) 
SELECT 'TERM', 'Term Pregnancies', 'TERM', 'number', `validations`.`id`, '2024-01-01 00:00:01'
FROM `validations`
WHERE `validations`.`name` = "Numeric Value: 0 to 100"
ON DUPLICATE KEY UPDATE `type`=`type`;

INSERT INTO `measurementType`( `type`, `typeDisplayName`, `typeDescription`, `measuringInstruction`, `validation`, `createDate`) 
SELECT 'TOP', 'Termination of Preg', 'TOP', 'number', `validations`.`id`, '2024-01-01 00:00:01'
FROM `validations`
WHERE `validations`.`name` = "Numeric Value: 0 to 100"
ON DUPLICATE KEY UPDATE `type`=`type`;

INSERT INTO `measurementType`( `type`, `typeDisplayName`, `typeDescription`, `measuringInstruction`, `validation`, `createDate`) 
SELECT 'CAT', 'CAT', 'CAT score', 'score', `validations`.`id`, '2020-01-01 00:00:01'
FROM `validations`
WHERE `validations`.`name` = "Numeric Value: 0 to 100"
ON DUPLICATE KEY UPDATE `type`=`type`;

INSERT INTO `measurementType`( `type`, `typeDisplayName`, `typeDescription`, `measuringInstruction`, `validation`, `createDate`) 
SELECT 'MDRC', 'Med Rec', 'Med Rec', 'Completed', `validations`.`id`, '2020-01-01 00:00:01'
FROM `validations`
WHERE `validations`.`name` = "Yes/No"
ON DUPLICATE KEY UPDATE `type`=`type`;

INSERT INTO `measurementType`( `type`, `typeDisplayName`, `typeDescription`, `measuringInstruction`, `validation`, `createDate`) 
SELECT 'CV19', 'COVID', 'COVID 19 test', 'Result', `validations`.`id`, '2020-11-01 00:00:01'
FROM `validations`
WHERE `validations`.`name` = "No Validations"
ON DUPLICATE KEY UPDATE `type`=`type`;

INSERT INTO `measurementType`( `type`, `typeDisplayName`, `typeDescription`, `measuringInstruction`, `validation`, `createDate`) 
SELECT 'SCRD', 'SCRD', 'SCRD', 'SCRD', `validations`.`id`, '2020-01-01 00:00:01'
FROM `validations`
WHERE `validations`.`name` = "Numeric Value: 0 to 100"
ON DUPLICATE KEY UPDATE `type`=`type`;

INSERT INTO `measurementType`( `type`, `typeDisplayName`, `typeDescription`, `measuringInstruction`, `validation`, `createDate`) 
SELECT 'PBNP', 'NTproBNP', 'NTproBNP', 'number', `validations`.`id`, '2024-01-01 00:00:01'
FROM `validations`
WHERE `validations`.`name` = "Numeric Value: 0 to 100"
ON DUPLICATE KEY UPDATE `type`=`type`;

INSERT INTO `measurementType`( `type`, `typeDisplayName`, `typeDescription`, `measuringInstruction`, `validation`, `createDate`) 
SELECT 'Zn', 'Serum Zinc', 'Zn', 'number', `validations`.`id`, '2024-01-01 00:00:01'
FROM `validations`
WHERE `validations`.`name` = "Numeric Value: 0 to 100"
ON DUPLICATE KEY UPDATE `type`=`type`;

INSERT INTO `measurementType`( `type`, `typeDisplayName`, `typeDescription`, `measuringInstruction`, `validation`, `createDate`) 
SELECT 'VANC', 'Vancomycin Serum', 'Vanco', 'level', `validations`.`id`, '2024-01-01 00:00:01'
FROM `validations`
WHERE `validations`.`name` = "Numeric Value: 0 to 100"
ON DUPLICATE KEY UPDATE `type`=`type`;

INSERT INTO `measurementType`( `type`, `typeDisplayName`, `typeDescription`, `measuringInstruction`, `validation`, `createDate`) 
SELECT 'VALP', 'Valproic Acid Serum', 'Valproate', 'level', `validations`.`id`, '2024-01-01 00:00:01'
FROM `validations`
WHERE `validations`.`name` = "Numeric Value: 0 to 100"
ON DUPLICATE KEY UPDATE `type`=`type`;

INSERT INTO `measurementType`( `type`, `typeDisplayName`, `typeDescription`, `measuringInstruction`, `validation`, `createDate`) 
SELECT 'BHCG', 'HCG Serum', 'HCG', 'level', `validations`.`id`, '2024-01-01 00:00:01'
FROM `validations`
WHERE `validations`.`name` = "Numeric Value: 0 to 100"
ON DUPLICATE KEY UPDATE `type`=`type`;

INSERT INTO `measurementType`( `type`, `typeDisplayName`, `typeDescription`, `measuringInstruction`, `validation`, `createDate`) 
SELECT 'TEST', 'Testosterone (total)', 'testosterone', 'number', `validations`.`id`, '2024-01-01 00:00:01'
FROM `validations`
WHERE `validations`.`name` = "Numeric Value: 0 to 100"
ON DUPLICATE KEY UPDATE `type`=`type`;

INSERT INTO `measurementType`( `type`, `typeDisplayName`, `typeDescription`, `measuringInstruction`, `validation`, `createDate`) 
SELECT 'PROL', 'Prolactin', 'Prolactin', 'number', `validations`.`id`, '2024-01-01 00:00:01'
FROM `validations`
WHERE `validations`.`name` = "Numeric Value: 0 to 100"
ON DUPLICATE KEY UPDATE `type`=`type`;

INSERT INTO `measurementType`( `type`, `typeDisplayName`, `typeDescription`, `measuringInstruction`, `validation`, `createDate`) 
SELECT 'PROG', 'Progesterone', 'Progesterone', 'number', `validations`.`id`, '2024-01-01 00:00:01'
FROM `validations`
WHERE `validations`.`name` = "Numeric Value: 0 to 100"
ON DUPLICATE KEY UPDATE `type`=`type`;

INSERT INTO `measurementType`( `type`, `typeDisplayName`, `typeDescription`, `measuringInstruction`, `validation`, `createDate`) 
SELECT 'LH', 'Luteinizing hormone', 'LH', 'number', `validations`.`id`, '2024-01-01 00:00:01'
FROM `validations`
WHERE `validations`.`name` = "Numeric Value: 0 to 100"
ON DUPLICATE KEY UPDATE `type`=`type`;

INSERT INTO `measurementType`( `type`, `typeDisplayName`, `typeDescription`, `measuringInstruction`, `validation`, `createDate`) 
SELECT 'PHEN', 'Phenobarbitol', 'Phenobarbitol', 'number', `validations`.`id`, '2024-01-01 00:00:01'
FROM `validations`
WHERE `validations`.`name` = "Numeric Value: 0 to 100"
ON DUPLICATE KEY UPDATE `type`=`type`;

INSERT INTO `measurementType`( `type`, `typeDisplayName`, `typeDescription`, `measuringInstruction`, `validation`, `createDate`) 
SELECT 'LIPA', 'Lipase', 'Lipase', 'number', `validations`.`id`, '2024-01-01 00:00:01'
FROM `validations`
WHERE `validations`.`name` = "Numeric Value: 0 to 100"
ON DUPLICATE KEY UPDATE `type`=`type`;

INSERT INTO `measurementType`( `type`, `typeDisplayName`, `typeDescription`, `measuringInstruction`, `validation`, `createDate`) 
SELECT 'Fe', 'Serum Iron', 'Iron', 'number', `validations`.`id`, '2024-01-01 00:00:01'
FROM `validations`
WHERE `validations`.`name` = "Numeric Value: 0 to 100"
ON DUPLICATE KEY UPDATE `type`=`type`;

INSERT INTO `measurementType`( `type`, `typeDisplayName`, `typeDescription`, `measuringInstruction`, `validation`, `createDate`) 
SELECT 'TIBC', 'Total Iron Binding Capacity', 'TIBC', 'number', `validations`.`id`, '2024-01-01 00:00:01'
FROM `validations`
WHERE `validations`.`name` = "Numeric Value: 0 to 100"
ON DUPLICATE KEY UPDATE `type`=`type`;

INSERT INTO `measurementType`( `type`, `typeDisplayName`, `typeDescription`, `measuringInstruction`, `validation`, `createDate`) 
SELECT 'GENT', 'Serum Gentamycin', 'Gentamycin', 'number', `validations`.`id`, '2024-01-01 00:00:01'
FROM `validations`
WHERE `validations`.`name` = "Numeric Value: 0 to 100"
ON DUPLICATE KEY UPDATE `type`=`type`;

INSERT INTO `measurementType`( `type`, `typeDisplayName`, `typeDescription`, `measuringInstruction`, `validation`, `createDate`) 
SELECT 'FSH', 'Follicle Stimulating Hormone', 'FSH', 'number', `validations`.`id`, '2024-01-01 00:00:01'
FROM `validations`
WHERE `validations`.`name` = "Numeric Value: 0 to 100"
ON DUPLICATE KEY UPDATE `type`=`type`;

INSERT INTO `measurementType`( `type`, `typeDisplayName`, `typeDescription`, `measuringInstruction`, `validation`, `createDate`) 
SELECT 'ESDL', 'Estradiol', 'E2', 'number', `validations`.`id`, '2024-01-01 00:00:01'
FROM `validations`
WHERE `validations`.`name` = "Numeric Value: 0 to 100"
ON DUPLICATE KEY UPDATE `type`=`type`;

INSERT INTO `measurementType`( `type`, `typeDisplayName`, `typeDescription`, `measuringInstruction`, `validation`, `createDate`) 
SELECT 'CORT', 'AM Cortisol', 'cortisol', 'number', `validations`.`id`, '2024-01-01 00:00:01'
FROM `validations`
WHERE `validations`.`name` = "Numeric Value: 0 to 100"
ON DUPLICATE KEY UPDATE `type`=`type`;

INSERT INTO `measurementType`( `type`, `typeDisplayName`, `typeDescription`, `measuringInstruction`, `validation`, `createDate`) 
SELECT 'CARB', 'Carbamazepine level', 'Carbamazepine', 'level', `validations`.`id`, '2024-01-01 00:00:01'
FROM `validations`
WHERE `validations`.`name` = "Numeric Value: 0 to 100"
ON DUPLICATE KEY UPDATE `type`=`type`;

INSERT INTO `measurementType`( `type`, `typeDisplayName`, `typeDescription`, `measuringInstruction`, `validation`, `createDate`) 
SELECT 'AMYL', 'Amylase', 'Amylase', 'number', `validations`.`id`, '2024-01-01 00:00:01'
FROM `validations`
WHERE `validations`.`name` = "Numeric Value: 0 to 100"
ON DUPLICATE KEY UPDATE `type`=`type`;

INSERT INTO `measurementType`( `type`, `typeDisplayName`, `typeDescription`, `measuringInstruction`, `validation`, `createDate`) 
SELECT 'VITD', '1 25(OH)Vitamin D', 'Vit D', 'number', `validations`.`id`, '2024-01-01 00:00:01'
FROM `validations`
WHERE `validations`.`name` = "Numeric Value: 0 to 100"
ON DUPLICATE KEY UPDATE `type`=`type`;

INSERT INTO `measurementType`( `type`, `typeDisplayName`, `typeDescription`, `measuringInstruction`, `validation`, `createDate`) 
SELECT 'PRGT', 'PRGT', 'Pregnancy Test', 'urine', `validations`.`id`, '2024-01-01 00:00:01'
FROM `validations`
WHERE `validations`.`name` = "No Validations"
ON DUPLICATE KEY UPDATE `type`=`type`;

INSERT INTO `measurementType`( `type`, `typeDisplayName`, `typeDescription`, `measuringInstruction`, `validation`, `createDate`) 
SELECT 'HDAB', 'Hep D Virus Ab', 'Hep D Virus Antibody', 'number', `validations`.`id`, '2024-01-01 00:00:01'
FROM `validations`
WHERE `validations`.`name` = "Numeric Value: 0 to 100"
ON DUPLICATE KEY UPDATE `type`=`type`;

INSERT INTO `measurementType`( `type`, `typeDisplayName`, `typeDescription`, `measuringInstruction`, `validation`, `createDate`) 
SELECT 'Epworth', 'Epworth Sleepiness Scale', 'Epworth', 'score', `validations`.`id`, '2020-01-01 00:00:01'
FROM `validations`
WHERE `validations`.`name` = "Numeric Value: 0 to 100"
ON DUPLICATE KEY UPDATE `type`=`type`;


INSERT INTO `measurementMap` (`loinc_code`, `ident_code`, `name`, `lab_type`) VALUES ('14196-0', '-RETIC', 'RETICULOCYTE COUNT', 'MDS') ON DUPLICATE KEY UPDATE `lab_type`='MDS';
INSERT INTO `measurementMap` (`loinc_code`, `ident_code`, `name`, `lab_type`) VALUES ('14566-4', '-25VITD', '25-HYDROXY VITAMIN D', 'MDS') ON DUPLICATE KEY UPDATE `lab_type`='MDS';
INSERT INTO `measurementMap` (`loinc_code`, `ident_code`, `name`, `lab_type`) VALUES ('14639-9', '-CARB', 'CARBAMAZEPINE(TEGRETOL)', 'MDS') ON DUPLICATE KEY UPDATE `lab_type`='MDS';
INSERT INTO `measurementMap` (`loinc_code`, `ident_code`, `name`, `lab_type`) VALUES ('14656-3', '-CLOZA', 'CLOZAPINE', 'MDS') ON DUPLICATE KEY UPDATE `lab_type`='MDS';
INSERT INTO `measurementMap` (`loinc_code`, `ident_code`, `name`, `lab_type`) VALUES ('14679-5', '-CORT-1', 'CORTISOL AM', 'MDS') ON DUPLICATE KEY UPDATE `lab_type`='MDS';
INSERT INTO `measurementMap` (`loinc_code`, `ident_code`, `name`, `lab_type`) VALUES ('14683-7', '-CREAT-R', 'CREATININE-URINE', 'MDS') ON DUPLICATE KEY UPDATE `lab_type`='MDS';
INSERT INTO `measurementMap` (`loinc_code`, `ident_code`, `name`, `lab_type`) VALUES ('14684-5', '-CREA-U', 'CREATININE-24 HR URINE', 'MDS') ON DUPLICATE KEY UPDATE `lab_type`='MDS';
INSERT INTO `measurementMap` (`loinc_code`, `ident_code`, `name`, `lab_type`) VALUES ('14715-7', '-ESTRA', 'ESTRADIOL-17 BETA', 'MDS') ON DUPLICATE KEY UPDATE `lab_type`='MDS';
INSERT INTO `measurementMap` (`loinc_code`, `ident_code`, `name`, `lab_type`) VALUES ('14749-6', '-GLU-R', 'GLUCOSE-RANDOM', 'MDS') ON DUPLICATE KEY UPDATE `lab_type`='MDS';
INSERT INTO `measurementMap` (`loinc_code`, `ident_code`, `name`, `lab_type`) VALUES ('14756-1', '-GLU 1HR', '1 HR', 'MDS') ON DUPLICATE KEY UPDATE `lab_type`='MDS';
INSERT INTO `measurementMap` (`loinc_code`, `ident_code`, `name`, `lab_type`) VALUES ('14866-8', '-PTH', 'PARATHYROID HORMONE', 'MDS') ON DUPLICATE KEY UPDATE `lab_type`='MDS';
INSERT INTO `measurementMap` (`loinc_code`, `ident_code`, `name`, `lab_type`) VALUES ('14877-5', '-DILAN', 'PHENYTOIN (DILANTIN)', 'MDS') ON DUPLICATE KEY UPDATE `lab_type`='MDS';
INSERT INTO `measurementMap` (`loinc_code`, `ident_code`, `name`, `lab_type`) VALUES ('14915-3', '-THEO', 'THEOPHYLLINE', 'MDS') ON DUPLICATE KEY UPDATE `lab_type`='MDS';
INSERT INTO `measurementMap` (`loinc_code`, `ident_code`, `name`, `lab_type`) VALUES ('14920-3', '-FREET4', 'FREE THYROXINE (FREE T4)', 'MDS') ON DUPLICATE KEY UPDATE `lab_type`='MDS';
INSERT INTO `measurementMap` (`loinc_code`, `ident_code`, `name`, `lab_type`) VALUES ('14928-6', '-FT3', 'FREE TRIIODOTHYRONINE', 'MDS') ON DUPLICATE KEY UPDATE `lab_type`='MDS';
INSERT INTO `measurementMap` (`loinc_code`, `ident_code`, `name`, `lab_type`) VALUES ('14946-8', '-VALPRO', 'VALPROIC ACID (DEPAKENE)', 'MDS') ON DUPLICATE KEY UPDATE `lab_type`='MDS';
INSERT INTO `measurementMap` (`loinc_code`, `ident_code`, `name`, `lab_type`) VALUES ('15205-8', '-RA', 'RHEUMATOID FACTOR-SERUM', 'MDS') ON DUPLICATE KEY UPDATE `lab_type`='MDS';
INSERT INTO `measurementMap` (`loinc_code`, `ident_code`, `name`, `lab_type`) VALUES ('16600-9', '-CHLAMY', 'CHLAMYDIA SWAB', 'MDS') ON DUPLICATE KEY UPDATE `lab_type`='MDS';
INSERT INTO `measurementMap` (`loinc_code`, `ident_code`, `name`, `lab_type`) VALUES ('16601-7', '-CHLAM-U', 'CHLAMYDIA URINE', 'MDS') ON DUPLICATE KEY UPDATE `lab_type`='MDS';
INSERT INTO `measurementMap` (`loinc_code`, `ident_code`, `name`, `lab_type`) VALUES ('1963-8', '-CO2', 'BICARBONATE', 'MDS') ON DUPLICATE KEY UPDATE `lab_type`='MDS';
INSERT INTO `measurementMap` (`loinc_code`, `ident_code`, `name`, `lab_type`) VALUES ('1995-0', '-I-CAL', 'iCA (CORRECTED TO pH7.4)', 'MDS') ON DUPLICATE KEY UPDATE `lab_type`='MDS';
INSERT INTO `measurementMap` (`loinc_code`, `ident_code`, `name`, `lab_type`) VALUES ('21198-7', '-HCG', 'TOTAL HCG', 'MDS') ON DUPLICATE KEY UPDATE `lab_type`='MDS';
INSERT INTO `measurementMap` (`loinc_code`, `ident_code`, `name`, `lab_type`) VALUES ('2286-3', '-FSH', 'FOLLITROPIN (FSH)', 'MDS') ON DUPLICATE KEY UPDATE `lab_type`='MDS';
INSERT INTO `measurementMap` (`loinc_code`, `ident_code`, `name`, `lab_type`) VALUES ('2579-1', '-LH', 'LUTROPIN (LH)', 'MDS') ON DUPLICATE KEY UPDATE `lab_type`='MDS';
INSERT INTO `measurementMap` (`loinc_code`, `ident_code`, `name`, `lab_type`) VALUES ('30522-7', '-HS-CRP', 'HS-CRP', 'MDS') ON DUPLICATE KEY UPDATE `lab_type`='MDS';
INSERT INTO `measurementMap` (`loinc_code`, `ident_code`, `name`, `lab_type`) VALUES ('4269-7', '4269-7', 'GLUCOSE DOSE', 'MDS') ON DUPLICATE KEY UPDATE `lab_type`='MDS';
INSERT INTO `measurementMap` (`loinc_code`, `ident_code`, `name`, `lab_type`) VALUES ('14874-2', '-PHENOB', 'PHENOBARBITAL', 'MDS') ON DUPLICATE KEY UPDATE `lab_type`='MDS';
INSERT INTO `measurementMap` (`loinc_code`, `ident_code`, `name`, `lab_type`) VALUES ('24108-3', '-CA 19-9', 'CA 19-9', 'MDS') ON DUPLICATE KEY UPDATE `lab_type`='MDS';
INSERT INTO `measurementMap` (`loinc_code`, `ident_code`, `name`, `lab_type`) VALUES ('31017-7', '-TISSUE', 'TISSUE TRANSGLUTAMINASE IgA', 'MDS') ON DUPLICATE KEY UPDATE `lab_type`='MDS';
INSERT INTO `measurementMap` (`loinc_code`, `ident_code`, `name`, `lab_type`) VALUES ('57803-9', '-FIT', 'FECAL IMMUNOCHEMICAL TEST', 'MDS') ON DUPLICATE KEY UPDATE `lab_type`='MDS';
INSERT INTO `measurementMap` (`loinc_code`, `ident_code`, `name`, `lab_type`) VALUES ('33762-6', '-NTPROBNP', 'NT-PRO BNP', 'MDS') ON DUPLICATE KEY UPDATE `lab_type`='MDS';

INSERT INTO `measurementMap` (`loinc_code`, `ident_code`, `name`, `lab_type`) VALUES ('14630-8', '-BILI-IN', 'INDIRECT BILIRUBIN', 'MDS') ON DUPLICATE KEY UPDATE `lab_type`='MDS';
INSERT INTO `measurementMap` (`loinc_code`, `ident_code`, `name`, `lab_type`) VALUES ('14678-7', '-CORT-2', 'CORTISOL PM', 'MDS') ON DUPLICATE KEY UPDATE `lab_type`='MDS';
INSERT INTO `measurementMap` (`loinc_code`, `ident_code`, `name`, `lab_type`) VALUES ('16128-1', '-ANTI HCV', 'HEPATITIS C (ANTI-HCV)', 'MDS') ON DUPLICATE KEY UPDATE `lab_type`='MDS'; 
INSERT INTO `measurementMap` (`loinc_code`, `ident_code`, `name`, `lab_type`) VALUES ('16935-9', '-HBSAB', 'SURFACE ANTIBODY (ANTI-HBs)', 'MDS') ON DUPLICATE KEY UPDATE `lab_type`='MDS';
INSERT INTO `measurementMap` (`loinc_code`, `ident_code`, `name`, `lab_type`) VALUES ('22314-9', '-HAVIGM', 'IgM ANTIBODY(ANTI-HAV IgM)', 'MDS') ON DUPLICATE KEY UPDATE `lab_type`='MDS';
INSERT INTO `measurementMap` (`loinc_code`, `ident_code`, `name`, `lab_type`) VALUES ('31844-4', '-HBEAG', '\'E\' ANTIGEN (HBeAg)', 'MDS') ON DUPLICATE KEY UPDATE `lab_type`='MDS';
INSERT INTO `measurementMap` (`loinc_code`, `ident_code`, `name`, `lab_type`) VALUES ('1884-6', '-APO-B', 'APOLIPOPROTEIN B', 'MDS') ON DUPLICATE KEY UPDATE `lab_type`='MDS';
INSERT INTO `measurementMap` (`loinc_code`, `ident_code`, `name`, `lab_type`) VALUES ('1834-1', '-AFP', 'AFP ONCOLOGY', 'MDS') ON DUPLICATE KEY UPDATE `lab_type`='MDS';